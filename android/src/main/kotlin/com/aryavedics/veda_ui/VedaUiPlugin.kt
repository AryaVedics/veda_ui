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
                val blocked = call.argument<List<String>>("blocked") ?: emptyList()
                val file = VedaLinkProvider.feedFile(context)
                workers.execute {
                    try {
                        // Apps the person has unlinked: the provider turns them away.
                        val blockedFile = VedaLinkProvider.blockedFile(context)
                        if (blocked.isEmpty()) {
                            if (blockedFile.exists()) blockedFile.delete()
                        } else {
                            blockedFile.writeText(blocked.joinToString("\n"), Charsets.UTF_8)
                        }
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

            "publishPatron" -> {
                val active = call.argument<Boolean>("active") == true
                val until = call.argument<String>("until")
                val file = VedaLinkProvider.patronFile(context)
                workers.execute {
                    try {
                        if (active) {
                            val json = org.json.JSONObject()
                            json.put("active", true)
                            if (until != null) json.put("until", until)
                            val tmp = java.io.File(file.path + ".tmp")
                            tmp.writeText(json.toString(), Charsets.UTF_8)
                            tmp.renameTo(file)
                        } else if (file.exists()) {
                            file.delete()
                        }
                        main.post { result.success(true) }
                    } catch (e: Exception) {
                        main.post { result.error("publish_failed", e.message, null) }
                    }
                }
            }

            "readPatron" -> {
                workers.execute {
                    val member = readPatron()
                    main.post { result.success(member) }
                }
            }

            "deviceInfo" -> {
                // For a support email: the app, its version, and the phone.
                val pm = context.packageManager
                val pkg = pm.getPackageInfo(context.packageName, 0)
                result.success(
                    mapOf(
                        "version" to (pkg.versionName ?: ""),
                        "build" to (if (android.os.Build.VERSION.SDK_INT >= 28) pkg.longVersionCode else @Suppress("DEPRECATION") pkg.versionCode.toLong()),
                        "model" to "${android.os.Build.MANUFACTURER} ${android.os.Build.MODEL}",
                        "android" to android.os.Build.VERSION.RELEASE,
                    )
                )
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

            "openApp" -> {
                val pkg = call.argument<String>("package")
                val intent = pkg?.let { context.packageManager.getLaunchIntentForPackage(it) }
                if (intent == null) {
                    result.success("missing")
                } else {
                    intent.addFlags(android.content.Intent.FLAG_ACTIVITY_NEW_TASK)
                    context.startActivity(intent)
                    result.success("opened")
                }
            }

            else -> result.notImplemented()
        }
    }

    /**
     * True if any family app on this phone (this one included) has a Patron
     * entry that has not run out. An app that is not installed, not allowed or
     * not answering simply does not count. Never throws.
     */
    private fun readPatron(): Boolean {
        for (pkg in FamilyKeys.PACKAGES) {
            val uri = Uri.parse("content://$pkg.link/patron")
            val client = try {
                context.contentResolver.acquireUnstableContentProviderClient(uri)
            } catch (e: Exception) {
                null
            } ?: continue
            try {
                val cursor = client.query(uri, null, null, null, null) ?: continue
                val text = cursor.use { if (it.moveToFirst()) it.getString(0) else null } ?: continue
                if (patronValid(text)) return true
            } catch (e: Exception) {
                // not allowed, or it died while answering: not a member from there
            } finally {
                client.close()
            }
        }
        return false
    }

    /** A date that cannot be read counts as run out: never a free membership. */
    private fun patronValid(text: String): Boolean = try {
        val json = org.json.JSONObject(text)
        if (!json.optBoolean("active", false)) {
            false
        } else {
            val until = json.optString("until", "")
            until.isEmpty() || parseUtc(until)?.after(java.util.Date()) == true
        }
    } catch (e: Exception) {
        false
    }

    /** Dart writes 2026-11-11T12:00:00.000Z; the plain form is accepted too. Null if unreadable. */
    private fun parseUtc(text: String): java.util.Date? {
        for (pattern in arrayOf("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", "yyyy-MM-dd'T'HH:mm:ss'Z'")) {
            try {
                val f = java.text.SimpleDateFormat(pattern, java.util.Locale.US)
                f.timeZone = java.util.TimeZone.getTimeZone("UTC")
                f.isLenient = false
                return f.parse(text)
            } catch (e: Exception) {
                // try the next form
            }
        }
        return null
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
