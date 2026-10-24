package com.aryavedics.veda_ui

import android.content.ContentProvider
import android.content.ContentValues
import android.database.Cursor
import android.database.MatrixCursor
import android.net.Uri
import android.os.Binder
import android.os.ParcelFileDescriptor
import java.io.File
import java.io.FileNotFoundException

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
        // An app the person has unlinked from this one sees an empty feed, the
        // same as sharing being off.
        val blocked = blockedFile(ctx)
        if (blocked.exists()) {
            val off = blocked.readText(Charsets.UTF_8).lines().toSet()
            val callers = ctx.packageManager.getPackagesForUid(Binder.getCallingUid()) ?: emptyArray()
            if (callers.any { it in off }) return cursor
        }
        val file = feedFile(ctx)
        if (file.exists()) {
            cursor.addRow(arrayOf<Any?>(file.readText(Charsets.UTF_8), file.lastModified()))
        }
        return cursor
    }

    /**
     * The master backup, and nothing else: only the Véda app itself may open
     * these, never another companion app.
     *  - `/backup`  (read):  this app's data file, as Véda saves it into the
     *    one bundle the person seals with their passphrase;
     *  - `/restore` (write): a file the app applies the next time it is open
     *    (see RestoreInbox on the Dart side), after keeping what it held.
     * An app that does not list a BACKUP_FILE in its manifest (Cycle) refuses
     * both, always.
     */
    override fun openFile(uri: Uri, mode: String): ParcelFileDescriptor {
        val ctx = context ?: throw FileNotFoundException()
        val uid = Binder.getCallingUid()
        if (!FamilyKeys.isFamily(ctx, uid)) {
            throw SecurityException("Only Véda apps may use this")
        }
        val callers = ctx.packageManager.getPackagesForUid(uid) ?: emptyArray()
        if (VEDA_PACKAGE !in callers) {
            throw SecurityException("Only Véda itself may ask for a backup or send a restore")
        }
        val name = backupFileName(ctx)
            ?: throw FileNotFoundException("This app is not part of the master backup")
        return when (uri.lastPathSegment) {
            "backup" -> {
                if (mode != "r") throw SecurityException("A backup can only be read")
                val data = File(ctx.getDir("flutter", android.content.Context.MODE_PRIVATE), name)
                if (!data.exists()) throw FileNotFoundException("nothing saved yet")
                ParcelFileDescriptor.open(data, ParcelFileDescriptor.MODE_READ_ONLY)
            }
            "restore" -> {
                if (mode != "w" && mode != "wt") throw SecurityException("A restore can only be written")
                ParcelFileDescriptor.open(
                    restoreFile(ctx),
                    ParcelFileDescriptor.MODE_WRITE_ONLY or
                        ParcelFileDescriptor.MODE_CREATE or
                        ParcelFileDescriptor.MODE_TRUNCATE
                )
            }
            else -> throw FileNotFoundException()
        }
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
        const val BLOCKED_FILE = "veda_link_blocked.txt"
        const val RESTORE_FILE = "veda_restore_pending.json"
        const val VEDA_PACKAGE = "com.aryavedics.skin"
        const val BACKUP_FILE_KEY = "com.aryavedics.veda_ui.BACKUP_FILE"

        /** Where Véda drops a restore for this app to apply when it is next open. */
        fun restoreFile(context: android.content.Context): File = File(context.filesDir, RESTORE_FILE)

        /**
         * The app's data file name in its documents folder, from the manifest;
         * null for an app that is not part of the master backup (Cycle).
         */
        fun backupFileName(context: android.content.Context): String? = try {
            context.packageManager
                .getApplicationInfo(context.packageName, android.content.pm.PackageManager.GET_META_DATA)
                .metaData?.getString(BACKUP_FILE_KEY)
        } catch (e: Exception) {
            null
        }

        /** In the app's private files folder; the Dart side writes the same file. */
        fun feedFile(context: android.content.Context): File = File(context.filesDir, FEED_FILE)

        /** The packages the person has unlinked, one per line. */
        fun blockedFile(context: android.content.Context): File = File(context.filesDir, BLOCKED_FILE)
    }
}
