package com.aryavedics.veda_ui

import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import java.security.MessageDigest

/**
 * Who may read a Véda app's feed: only another Véda app, proven two ways.
 *
 *  1. its package name is one of the family's, and
 *  2. the certificate it is signed with is one of OUR certificates, pinned
 *     below. A certificate cannot be faked: an app signed with anyone else's
 *     key can use our package name but will never match these fingerprints.
 *
 * This replaces Android's "same signing key" permission, so each app can keep
 * its own key (Véda's is Google Play's, and cannot be exported) and still talk
 * to the others. See veda_ui/BRIDGE.md.
 *
 * Add a companion app's Play app signing certificate here when it is created
 * in Play Console. The Android debug key is deliberately NOT listed: it is a
 * test key, not one to trust inside a shipped app.
 */
object FamilyKeys {
    val PACKAGES = setOf(
        "com.aryavedics.skin",
        "com.aryavedics.sun",
        "com.aryavedics.lifestyle",
        "com.aryavedics.cycle",
        "com.aryavedics.routine",
    )

    /** SHA-256 fingerprints of our signing certificates, upper-case with colons. */
    val CERTS = setOf(
        // Google Play app signing key (what a phone that installed from Play has).
        "D2:EA:7E:CE:A4:E4:C5:7A:A4:CA:A4:F4:B6:DF:BF:B2:9A:7F:34:72:83:E6:5A:90:3C:C4:72:CD:A0:AB:AA:57",
        // Upload key (what builds installed straight from a file have).
        "AC:69:89:AB:D4:1A:0A:A3:11:00:B3:4F:83:69:55:BF:7F:3C:D7:57:CC:BB:D9:E7:C5:97:30:63:28:16:20:9D",
    )

    /** True if [uid] belongs to an app of the family signed with one of our certificates. */
    fun isFamily(context: Context, uid: Int): Boolean {
        if (uid == android.os.Process.myUid()) return true
        val pm = context.packageManager
        val packages = pm.getPackagesForUid(uid) ?: return false
        return packages.any { it in PACKAGES && signedByUs(pm, it) }
    }

    private fun signedByUs(pm: PackageManager, pkg: String): Boolean = try {
        val certs: List<ByteArray> = if (Build.VERSION.SDK_INT >= 28) {
            val info = pm.getPackageInfo(pkg, PackageManager.GET_SIGNING_CERTIFICATES)
            val signers = info.signingInfo?.apkContentsSigners ?: emptyArray()
            signers.map { it.toByteArray() }
        } else {
            @Suppress("DEPRECATION")
            val info = pm.getPackageInfo(pkg, PackageManager.GET_SIGNATURES)
            @Suppress("DEPRECATION")
            (info.signatures ?: emptyArray()).map { it.toByteArray() }
        }
        certs.isNotEmpty() && certs.all { sha256(it) in CERTS }
    } catch (e: Exception) {
        false
    }

    private fun sha256(bytes: ByteArray): String =
        MessageDigest.getInstance("SHA-256").digest(bytes)
            .joinToString(":") { "%02X".format(it) }
}
