package com.aryavedics.veda_ui

import android.content.Context
import android.net.Uri
import android.os.Handler
import android.os.Looper
import java.util.concurrent.Executors
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * Véda Link's two calls:
 *  - publish(feed): save this app's feed where [VedaLinkProvider] serves it
 *    (null removes it, so a switched-off app serves nothing);
 *  - read(authority): ask another family app's provider for its feed.
 */
class VedaUiPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    // Both calls touch storage or another process, so they run off the
    // platform thread. A read that waits on a sleeping or starting app used to
    // park that thread, and every later call (publish too) queued behind it,
    // which left the switches and the "checking…" lines stuck.
    private val workers = Executors.newCachedThreadPool()
    private val main = Handler(Looper.getMainLooper())

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "com.aryavedics.veda_ui/link")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "publish" -> {
                val feed = call.argument<String>("feed")
                val file = VedaLinkProvider.feedFile(context)
                workers.execute {
                    try {
                        if (feed == null) {
                            if (file.exists()) file.delete()
                        } else {
                            val tmp = java.io.File(file.path + ".tmp")
                            tmp.writeText(feed, Charsets.UTF_8)
                            tmp.renameTo(file)
                        }
                        // Anyone watching this feed is told it changed.
                        context.contentResolver.notifyChange(
                            Uri.parse("content://${context.packageName}.link/feed"), null
                        )
                        main.post { result.success(true) }
                    } catch (e: Exception) {
                        main.post { result.error("publish_failed", e.message, null) }
                    }
                }
            }

            "read" -> {
                val authority = call.argument<String>("authority")
                if (authority == null) {
                    result.error("bad_args", "authority is required", null)
                    return
                }
                workers.execute {
                    val answer = read(authority)
                    main.post { result.success(answer) }
                }
            }

            else -> result.notImplemented()
        }
    }

    /** Asks one family app's provider for its feed. Never throws. */
    private fun read(authority: String): Map<String, Any?> {
        val uri = Uri.parse("content://$authority/feed")
        // Unstable: if the other app dies while answering, this one survives.
        val client = try {
            context.contentResolver.acquireUnstableContentProviderClient(uri)
        } catch (e: Exception) {
            null
        } ?: return notThere(authority)
        return try {
            val cursor = client.query(uri, null, null, null, null)
                ?: return notThere(authority)
            cursor.use {
                if (it.moveToFirst()) {
                    mapOf(
                        "status" to "ok",
                        "feed" to it.getString(0),
                        "updated_at" to it.getLong(1)
                    )
                } else {
                    // Installed and allowed, but the person has sharing off.
                    mapOf("status" to "empty")
                }
            }
        } catch (e: SecurityException) {
            // Installed, but signed with a different key: not allowed.
            mapOf("status" to "denied")
        } catch (e: Exception) {
            mapOf("status" to "missing")
        } finally {
            client.close()
        }
    }

    /**
     * No provider answered. If the app itself is installed (the package is
     * the authority without ".link"), it is an older version that does not
     * share yet; otherwise it is not installed.
     */
    private fun notThere(authority: String): Map<String, Any?> {
        val pkg = authority.removeSuffix(".link")
        val installed = try {
            context.packageManager.getPackageInfo(pkg, 0)
            true
        } catch (e: Exception) {
            false
        }
        return mapOf("status" to if (installed) "old_version" else "missing")
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        workers.shutdown()
    }
}
