package com.aryavedics.veda_ui

import android.content.Context
import android.net.Uri
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
                    result.success(true)
                } catch (e: Exception) {
                    result.error("publish_failed", e.message, null)
                }
            }

            "read" -> {
                val authority = call.argument<String>("authority")
                if (authority == null) {
                    result.error("bad_args", "authority is required", null)
                    return
                }
                try {
                    val cursor = context.contentResolver.query(
                        Uri.parse("content://$authority/feed"), null, null, null, null
                    )
                    if (cursor == null) {
                        // The provider is not there: the app is not installed.
                        result.success(mapOf("status" to "missing"))
                        return
                    }
                    cursor.use {
                        if (it.moveToFirst()) {
                            result.success(
                                mapOf(
                                    "status" to "ok",
                                    "feed" to it.getString(0),
                                    "updated_at" to it.getLong(1)
                                )
                            )
                        } else {
                            // Installed and allowed, but the person has sharing off.
                            result.success(mapOf("status" to "empty"))
                        }
                    }
                } catch (e: SecurityException) {
                    // Installed, but signed with a different key: not allowed.
                    result.success(mapOf("status" to "denied"))
                } catch (e: Exception) {
                    result.success(mapOf("status" to "missing"))
                }
            }

            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
