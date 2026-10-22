package com.aryavedics.veda_ui

import android.content.ContentProvider
import android.content.ContentValues
import android.database.Cursor
import android.database.MatrixCursor
import android.net.Uri
import android.os.Binder
import java.io.File

/**
 * The app's own feed, read-only to other Véda apps. The Dart side writes the
 * feed text into this app's private storage (see [feedFile]); this provider
 * only hands that text over, to Véda apps that pass FamilyKeys.isFamily. It
 * never reads another app's data, writes nothing, and returns an empty result when the person has not turned
 * sharing on (the Dart side then deletes the file).
 */
class VedaLinkProvider : ContentProvider() {

    override fun onCreate(): Boolean = true

    override fun query(
        uri: Uri,
        projection: Array<out String>?,
        selection: String?,
        selectionArgs: Array<out String>?,
        sortOrder: String?
    ): Cursor {
        val ctx = context ?: return MatrixCursor(arrayOf("feed", "updated_at"))
        // Only another Véda app, signed with one of our certificates (see FamilyKeys).
        if (!FamilyKeys.isFamily(ctx, Binder.getCallingUid())) {
            throw SecurityException("Only Véda apps may read this feed")
        }
        val cursor = MatrixCursor(arrayOf("feed", "updated_at"))
        val file = feedFile(ctx)
        if (file.exists()) {
            cursor.addRow(arrayOf<Any?>(file.readText(Charsets.UTF_8), file.lastModified()))
        }
        return cursor
    }

    override fun getType(uri: Uri): String = "vnd.android.cursor.item/vnd.aryavedics.feed"

    // Read-only: other apps cannot change this app's feed.
    override fun insert(uri: Uri, values: ContentValues?): Uri? = null
    override fun delete(uri: Uri, selection: String?, selectionArgs: Array<out String>?): Int = 0
    override fun update(
        uri: Uri,
        values: ContentValues?,
        selection: String?,
        selectionArgs: Array<out String>?
    ): Int = 0

    companion object {
        const val FEED_FILE = "veda_link_feed.json"

        /** In the app's private files folder; the Dart side writes the same file. */
        fun feedFile(context: android.content.Context): File = File(context.filesDir, FEED_FILE)
    }
}
