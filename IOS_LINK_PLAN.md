# Véda Link on the iPhone: plan (2026-11-11)

Goal: the Véda apps on one iPhone exchange the same things they exchange on Android (see
`BRIDGE.md`), with nothing leaving the phone, so Routine on iPhone gets the Skin tab, the master
backup works, and one Patron membership is recognised by every app (except Cycle, which never
joins).

## What has to work on the iPhone (the same calls as Android)

The Dart side (`LinkBridge`, `RestoreInbox`, Véda's master backup) already talks to the native side
through one method channel, `com.aryavedics.veda_ui/link`. The iPhone gets the same four calls:

| Call | What it does |
|---|---|
| `publish(feed, blocked)` | save this app's feed (null removes it) and the list of apps the person unlinked |
| `read(authority)` | read another app's feed; answers `ok`, `empty` (sharing off), `missing`, `old_version`, `denied` |
| `openApp(package)` | open another Véda app (a custom URL scheme, since iOS has no package launch) |
| `deviceInfo` | app version, build, phone model, iOS version, for a support email |

Plus what Android does through `openFile`: the master backup (`backup` read, `restore` write), and
the new **Patron flag**.

## Design

**A shared App Group.** One App Group, `group.com.aryavedics.veda`, that only apps from our Apple
developer team that have the capability can open. Cycle never gets it, so it cannot see or be seen.

```
<App Group container>/link/
    <app id>/feed.json       the app's published feed (veda-link/1), written atomically
    <app id>/blocked.txt     apps the person unlinked from this one, one per line
    <app id>/backup.json     a copy of the app's data file, ONLY for the master backup (see below)
    patron.json              {"active": true, "until": "...", "by": "<app id>"}  (see below)
restore/<app id>.json        a restore Véda leaves for an app to apply when it next opens
```

- **Who may read:** any app with the App Group, which only our team's apps can have. Android pins
  certificates; on iPhone the entitlement does that job. The "unlinked" list is honoured by our own
  code, as everything in the group is ours.
- **Atomic writes:** a side file, then a rename, as for the Android feed.
- **Backups:** the group folder is flagged as excluded from iCloud and computer backups.
- **"Installed?"** `read` finds out by checking the other app's custom URL scheme
  (`vedalink-<id>://`, declared in Info.plist `LSApplicationQueriesSchemes`), because an iPhone app
  cannot list installed apps.
- **Master backup on iPhone:** Android reads the companion's file on demand. An iPhone app cannot
  read another app's sandbox, so, **only while "Include in Véda's master backup" is on**, each
  companion keeps a copy in `backup.json` (not a standing copy otherwise), and Véda reads it; a
  restore is the file Véda leaves in `restore/`, applied by `RestoreInbox` on the next open.
- **Patron flag (new, both platforms):** any app that sees an active Patron membership writes
  `patron.json` (active, date it runs to, which app); every app reads it and treats a still-valid
  one as "member", so ads are off in all of them. It names nothing about the person, never leaves
  the phone, and does NOT need the readings-sharing switch (it is not personal data). On Android the
  same entry travels as one more path on each app's provider.
- **Véda's own code:** Véda does not use the `veda_ui` plugin (it has its own copy of the Android
  provider). On iPhone it gets the same small Swift file by copy, kept in step.

## Order of work (so Apple signing never breaks)

Entitlements make Codemagic's signing demand a provisioning profile that includes the App Group.
If an app's entitlements are changed before the profile is regenerated, **the build fails at
signing**. So:

1. **You, in Apple's developer account** (steps below). Nothing in the apps changes yet.
2. **Me, no entitlement yet:** the Swift plugin and the Dart changes in `veda_ui` (compiles, does
   nothing without the group); tests with a fake channel.
3. **You tell me step 1 is done.** Then I add `Runner.entitlements` with the App Group to Routine
   (and to Véda for its update), and Routine goes to TestFlight again.
4. **A friend with an iPhone** tests: Véda and Routine both installed, Link on, readings appear in
   Routine's Skin tab; Patron flag; then the master backup and restore.
5. Fix what breaks; Véda ships an update (App Group, the Patron flag, Link switch visible) with or
   before Routine.

## Your steps in Apple's developer account (step 1)

Sign in at developer.apple.com, Account, **Certificates, Identifiers & Profiles**.

1. **Identifiers**, the blue **+**, choose **App Groups**, Continue. Description "Véda family",
   Identifier **`group.com.aryavedics.veda`**. Register.
2. For **each app that will link on iPhone**, Identifiers, open its App ID, tick **App Groups**,
   click **Configure** and tick `group.com.aryavedics.veda`, Save (confirm if it warns that the
   profiles need regenerating). Now: Véda (`com.aryavedics.skin`) and Routine
   (`com.aryavedics.vedaRoutine`). Kitchen, Lifestyle and Sun later, each when its iPhone version is
   made. **Not Cycle.**
3. **Profiles:** for each of those App IDs, open the App Store Connect (distribution) profile, Edit,
   choose the same existing Apple Distribution certificate (do not create a new one: Apple allows
   three and two exist), Save, Download.
4. **Codemagic:** for each app, Code signing identities, upload the regenerated profile (replacing
   the old one); the certificate beside it should show a green check.
5. Tell me. Véda's build 117, now in review, is not affected: nothing changes in it.

## Risks

- None of the Swift can be run here (no Mac, no iPhone): the first real test is a TestFlight build
  with a friend. Expect several rounds.
- The master-backup copy on iPhone is the one place a second copy of someone's data exists; it is
  kept only while that option is on, in the backup-excluded group folder, and removed when it is
  turned off or "Delete everything" is used.
