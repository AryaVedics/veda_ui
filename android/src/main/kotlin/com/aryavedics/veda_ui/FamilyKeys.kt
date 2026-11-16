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
        "com.aryavedics.allergy",
        "com.aryavedics.curio",
        "com.aryavedics.kitchen",
    )

    /** SHA-256 fingerprints of our signing certificates, upper-case with colons. */
    val CERTS = setOf(
        // Google Play app signing key (what a phone that installed from Play has).
        "D2:EA:7E:CE:A4:E4:C5:7A:A4:CA:A4:F4:B6:DF:BF:B2:9A:7F:34:72:83:E6:5A:90:3C:C4:72:CD:A0:AB:AA:57",
        // Upload key (what builds installed straight from a file have).
        "AC:69:89:AB:D4:1A:0A:A3:11:00:B3:4F:83:69:55:BF:7F:3C:D7:57:CC:BB:D9:E7:C5:97:30:63:28:16:20:9D",
        // Véda Routine's own Google Play app signing key.
        "33:90:9C:A1:37:59:ED:A5:D0:E8:FA:81:2D:16:64:56:97:FE:99:0F:BB:7C:06:19:53:98:15:CC:AB:BF:D0:CF",
        // Véda Allergy's own Google Play app signing key.
        "F2:0A:AE:8B:4C:28:DC:64:73:BC:7C:1B:29:16:E5:32:BC:9F:6A:D4:9D:50:B1:36:7D:FD:5A:78:6E:80:AA:2D",
        // Véda Curio's own Google Play app signing key.
        "61:7D:0A:62:D7:96:70:D3:CC:09:CD:9B:3B:F9:49:7F:6D:D0:E2:35:08:B7:DE:6E:11:F0:08:9C:A8:9D:4F:EB",
        // Véda Cycle's own Google Play app signing key.
        "28:F1:31:BC:50:45:08:7F:6E:16:4B:94:04:20:7B:5B:77:23:42:72:4F:BB:CC:B3:69:75:90:55:59:32:6D:BE",
        // Véda Kitchen's own Google Play app signing key.
        "A4:CA:89:68:7B:AE:57:2F:CC:BC:A0:8B:31:6F:DE:14:77:32:30:03:E3:1E:CE:58:D9:EF:00:7C:CA:C0:15:63",
        // Véda Lifestyle's own Google Play app signing key.
        "30:8C:89:4F:D7:4B:B1:40:5C:0E:80:C1:8A:BD:FC:CC:4D:AA:E5:E9:8A:42:44:3C:10:E7:14:4F:8D:EB:BA:A4",
        // Véda Sun's own Google Play app signing key.
        "BC:65:10:DF:68:E1:94:C1:FE:97:D9:D7:0D:07:43:31:98:A4:A1:23:91:04:AE:A0:AA:F4:D4:B8:53:DB:4F:01",
    )

    /** True if [uid] belongs to an app of the family signed with one of our certificates. */
    fun isFamily(context: Context, uid: Int): Boolean {
        if (uid == android.os.Process.myUid()) return true
        val pm = context.packageManager
        val packages = pm.getPackagesForUid(uid) ?: return false
        return packages.any { it in PACKAGES && signedByUs(pm, it) }
    }

    /** What stands behind a content authority on this phone. */
    enum class Authority { NONE, OURS, OTHER }

    /**
     * The reading side of [isFamily]: before this app asks [authority] for
     * anything (a feed, a backup, a restore, a Patron flag), find out which app
     * answers for it. OURS is one of the family's apps, signed with one of our
     * certificates, answering for its own "<package>.link" authority; OTHER is
     * anything else (an app that took the name, or an authority that is not its
     * package's); NONE means nothing answers, which the caller reports as not
     * installed. Checked afresh on every call, never remembered.
     */
    fun checkAuthority(context: Context, authority: String): Authority {
        val pm = context.packageManager
        val provider = try {
            pm.resolveContentProvider(authority, 0)
        } catch (e: Exception) {
            null
        } ?: return Authority.NONE
        val pkg = provider.packageName
        if (authority != "$pkg.link") return Authority.OTHER
        if (pkg == context.packageName) return Authority.OURS
        return if (pkg in PACKAGES && signedByUs(pm, pkg)) Authority.OURS else Authority.OTHER
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
