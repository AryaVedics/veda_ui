# Véda Link: how the Véda apps share with each other (decided 2026-10-22)

## The rule
**Every app publishes the one kind of entry it owns, and any Véda app can
read another app's entries when it has a use for them, with the person's
permission.** A small family network, not a hub: the apps talk to each other,
not only to Véda. Two goals decide what is read where:

1. **Charts live in the app that owns the "other thing", never in Véda,** so
   Véda stays uncluttered (Routine charts readings around a product change;
   Lifestyle charts them next to sleep; Cycle by phase; Sun by UV day).
2. **Nothing is logged twice.** If Cycle knows your period days, Véda's Cycle
   tab shows them instead of asking again; if Sun logged sunscreen, Routine's
   checklist can show it as done.

**One owner per kind of entry.** Only the owner writes it; everyone else
shows it read-only, marked with where it came from ("from Véda Cycle").
Unlinking hands the job back, and the reader may keep what it was shown as
its own copy if the person wants it.

| Kind of entry | Owner | Read by, and what for |
|---|---|---|
| Skin readings | Véda | every companion, for its charts |
| Daily check-ins (sleep, water, exercise, stress) and food | Véda Lifestyle | Véda (its Lifestyle tab and food card, so nothing is entered twice); Cycle (sleep and stress by phase) |
| Period days and estimated phase | Véda Cycle | Véda (its Cycle tab); Lifestyle (phase beside sleep and stress). Symptoms are not shared beyond Véda |
| Products started and stopped, daily checklist | Véda Routine | Sun (which sunscreen, its SPF); later Véda's Trends markers, only if it stays uncluttered |
| Sunscreen put on, UV by day | Véda Sun | Routine (tick "sunscreen" on the checklist); Lifestyle (sun days beside sleep) |

Cycle is the most sensitive: its sharing switch is off until turned on, and
even then it publishes only period days and the estimated phase.

## What crosses
From Véda: only what a chart needs, per reading: when it was taken, the
time of day (morning, midday, evening), the Skin Score, and the seven
measurements. From a companion: only the entries in the table above, in
the same shape Véda already stores them.

Never: photos, face geometry, per-region detail, raw measurement values,
account details, email, consent records. (`veda_ui/lib/src/veda_link.dart`
drops everything else on the way in, and a test checks it.)

## Where it goes
Nowhere off the phone. No server, no account, no cloud copy. The companion
keeps its own copy in `veda_readings.json` in its app storage, so its charts
work offline; "Delete everything" in the companion removes it.

## How it works: automatic, with permission
Every app publishes its own feed and can read the others' the same way.
Described below for Véda's readings; every other feed in the table works
identically (its own provider or App Group file, its own switch):

- **Véda** gets one switch in Profile: "Let my other Véda apps use my
  readings". Off by default. While on, Véda keeps a small `veda-link/1` file
  up to date (same fields as above). Turning it off deletes that file.
- **The companion** gets one switch: "Show my Véda readings here". Both
  switches must be on.
- **Android:** each app publishes its feed through a read-only content provider
  (`<applicationId>.link`). The provider checks WHO is asking at query time
  (`FamilyKeys.kt`): the caller must be one of the family's packages AND signed
  with one of OUR pinned certificates (Google Play app signing key, and the
  upload key). A certificate cannot be faked, so another app using our package
  name is refused. This replaces Android's "same signing key" permission, so
  each app keeps its own key: Véda's Play-managed key cannot be exported, and
  forcing all apps onto one key was not possible for the Play-installed Véda.
  The Android debug key is NOT pinned (a test key is not one to trust inside a
  shipped app); test builds are signed with the upload key via a local,
  uncommitted `android/key.properties` instead.
- **iPhone:** Véda writes the file into a shared App Group container
  (`group.com.aryavedics.veda`) that only Véda-family apps under the same
  Apple developer team can open.
- The companion reads it when it opens and replaces its copy. When Véda's
  switch is off, the companion forgets its copy.
- **Every other direction:** each app publishes its own feed the same way
  (its own content provider under the same signature permission, or its own
  file in the App Group), behind one switch, "Share my entries with my other
  Véda apps". Each reader lists in Profile which apps it is using, with a
  switch to stop. Véda's Cycle and
  check-in data already live only on the phone, and entries read from a
  companion stay there too: they are never sent to Véda's server.

### Decisions this forces now
- **Pinned certificates.** The two Véda fingerprints (Play app signing key and
  upload key) are in `FamilyKeys.kt` (veda_ui and Véda's own copy). When a
  companion app is created in Play Console, add ITS Play app signing
  certificate there too (Play Console, Test and release, App integrity, App
  signing key certificate, SHA-256). If a key is ever rotated, change it in
  both copies and release both.
- **Test builds** of the companions are signed with the upload key (copy
  Véda's `android/key.properties` into each companion's `android/`). A build
  made without it (a teammate's machine) works but will not link.
- **Same Apple developer team** for every app (already true), with the App
  Group capability added to each App ID (iPhone, later).

### Before Stage 2 ships
- Véda's privacy policy gets a line: if you turn the switch on, your readings
  are made available to your other Véda apps on the same phone; they never
  leave the phone. Each companion's own policy says the same from its side.
  On the lawyer list.
- Véda needs an app update (the switch, the provider, the App Group).

## Format: `veda-link/1`
```json
{
  "schema": "veda-link/1",
  "generated_at": "2026-10-22T18:00:00Z",
  "readings": [
    {
      "taken_at": "2026-10-20T14:00:00Z",
      "slot": "midday",
      "skin_score": 88.4,
      "scores": { "redness": 89, "texture": 82, "pores": 78, "spots": 100,
                  "acne": 88, "evenness": 95, "wrinkles": 90 }
    }
  ]
}
```
There is no manual import: the readings only arrive live over the link
(a hand-made import went stale with every new reading, so nobody would use it).
