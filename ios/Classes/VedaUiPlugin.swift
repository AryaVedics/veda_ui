// Véda Link on the iPhone: the same four calls as the Android plugin
// (android/.../VedaUiPlugin.kt), over the same method channel, for the Dart side
// in lib/src/link_bridge.dart. See IOS_LINK_PLAN.md for the design.
//
// The apps share small files through an App Group folder that only apps from
// our Apple developer team with the App Groups capability can open. Without that
// capability (an app that is not part of the family, or one whose profile does not
// have the group yet) the folder is nil and every call answers "nothing there":
// nothing crashes and nothing is shared.
//
//   <group>/link/<app id>/feed.json     the app's published feed
//   <group>/link/<app id>/blocked.txt   the apps the person unlinked from it
//   <group>/link/patron/<app id>.json   "this phone has Patron", from any app
//
// Never a network call: the data goes from one app's file into another app.

import Flutter
import UIKit

public class VedaUiPlugin: NSObject, FlutterPlugin {
  /// Must match the App Group registered in the Apple developer account.
  static let groupId = "group.com.aryavedics.veda"

  /// Every app's id is its Android package's last word ("skin", "routine", ...).
  static let packagePrefix = "com.aryavedics."

  private let queue = DispatchQueue(label: "com.aryavedics.veda_ui.link", qos: .userInitiated)

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "com.aryavedics.veda_ui/link",
      binaryMessenger: registrar.messenger()
    )
    registrar.addMethodCallDelegate(VedaUiPlugin(), channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any] ?? [:]
    switch call.method {
    case "publish":
      queue.async {
        let answer = self.publish(args)
        DispatchQueue.main.async { result(answer) }
      }
    case "read":
      queue.async {
        let answer = self.read(args)
        DispatchQueue.main.async { result(answer) }
      }
    case "publishPatron":
      queue.async {
        let answer = self.publishPatron(args)
        DispatchQueue.main.async { result(answer) }
      }
    case "readPatron":
      queue.async {
        let answer = self.readPatron()
        DispatchQueue.main.async { result(answer) }
      }
    case "openApp":
      openApp(args, result: result)
    default:
      // deviceInfo and the rest: the Dart side already copes on an iPhone
      // (the build gives it the version through --dart-define=APP_VERSION).
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: Folders

  /// The shared folder, flagged out of iCloud and computer backups; nil when this
  /// app has no App Group.
  private func linkRoot() -> URL? {
    guard
      var root = FileManager.default.containerURL(
        forSecurityApplicationGroupIdentifier: VedaUiPlugin.groupId
      )?.appendingPathComponent("link", isDirectory: true)
    else { return nil }
    do {
      try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
      var values = URLResourceValues()
      values.isExcludedFromBackup = true
      try root.setResourceValues(values)
    } catch {
      // still usable; the flag is a nicety
    }
    return root
  }

  /// An app id is a few lowercase letters: nothing that can climb out of the folder.
  private func isSafeId(_ id: String?) -> Bool {
    guard let id = id else { return false }
    return id.range(of: "^[a-z]{2,20}$", options: .regularExpression) != nil
  }

  /// "com.aryavedics.skin.link" or "com.aryavedics.skin" -> "skin".
  private func appId(fromName name: String?) -> String? {
    guard var s = name, s.hasPrefix(VedaUiPlugin.packagePrefix) else { return nil }
    s = String(s.dropFirst(VedaUiPlugin.packagePrefix.count))
    if s.hasSuffix(".link") { s = String(s.dropLast(5)) }
    return isSafeId(s) ? s : nil
  }

  // MARK: Calls

  /// Saves this app's feed (null removes it, so a switched-off app serves nothing)
  /// and the list of apps the person unlinked.
  private func publish(_ args: [String: Any]) -> Any {
    guard let app = args["app"] as? String, isSafeId(app), let root = linkRoot() else {
      return FlutterError(code: "no_group", message: "No App Group for this app", details: nil)
    }
    let fm = FileManager.default
    let dir = root.appendingPathComponent(app, isDirectory: true)
    do {
      try fm.createDirectory(at: dir, withIntermediateDirectories: true)
      let feedFile = dir.appendingPathComponent("feed.json")
      if let feed = args["feed"] as? String {
        try feed.write(to: feedFile, atomically: true, encoding: .utf8)
      } else if fm.fileExists(atPath: feedFile.path) {
        try fm.removeItem(at: feedFile)
      }
      let blocked = (args["blocked"] as? [String]) ?? []
      let blockedFile = dir.appendingPathComponent("blocked.txt")
      if blocked.isEmpty {
        if fm.fileExists(atPath: blockedFile.path) { try fm.removeItem(at: blockedFile) }
      } else {
        try blocked.joined(separator: "\n").write(to: blockedFile, atomically: true, encoding: .utf8)
      }
      return true
    } catch {
      return FlutterError(code: "publish_failed", message: error.localizedDescription, details: nil)
    }
  }

  /// Another family app's feed. Never fails: the answer says what is wrong.
  private func read(_ args: [String: Any]) -> [String: Any] {
    guard let target = appId(fromName: args["authority"] as? String) else {
      return ["status": "missing"]
    }
    // An iPhone app cannot list what is installed; it can ask whether the other
    // app answers to its own link scheme (declared in Info.plist).
    var installed = false
    DispatchQueue.main.sync {
      if let url = URL(string: "vedalink-\(target)://") {
        installed = UIApplication.shared.canOpenURL(url)
      }
    }
    guard installed else { return ["status": "missing"] }
    guard let root = linkRoot() else { return ["status": "missing"] }
    let dir = root.appendingPathComponent(target, isDirectory: true)
    // Unlinked by the person in that app: the same as sharing being off.
    if let me = args["as"] as? String, isSafeId(me),
      let text = try? String(contentsOf: dir.appendingPathComponent("blocked.txt"), encoding: .utf8),
      text.split(separator: "\n").map(String.init).contains(VedaUiPlugin.packagePrefix + me)
    {
      return ["status": "empty"]
    }
    let feedFile = dir.appendingPathComponent("feed.json")
    guard let feed = try? String(contentsOf: feedFile, encoding: .utf8) else {
      return ["status": "empty"]
    }
    let modified =
      (try? FileManager.default.attributesOfItem(atPath: feedFile.path)[.modificationDate]
        as? Date) ?? Date()
    return ["status": "ok", "feed": feed, "updated_at": Int(modified.timeIntervalSince1970 * 1000)]
  }

  /// Whether Patron is active, from this app: written when the app sees a
  /// membership, removed when it does not. Says nothing about the person.
  private func publishPatron(_ args: [String: Any]) -> Any {
    guard let app = args["app"] as? String, isSafeId(app), let root = linkRoot() else {
      return FlutterError(code: "no_group", message: "No App Group for this app", details: nil)
    }
    let fm = FileManager.default
    let dir = root.appendingPathComponent("patron", isDirectory: true)
    let file = dir.appendingPathComponent("\(app).json")
    do {
      try fm.createDirectory(at: dir, withIntermediateDirectories: true)
      if (args["active"] as? Bool) == true {
        var entry: [String: Any] = ["active": true, "by": app]
        if let until = args["until"] as? String { entry["until"] = until }
        let data = try JSONSerialization.data(withJSONObject: entry)
        try data.write(to: file, options: .atomic)
      } else if fm.fileExists(atPath: file.path) {
        try fm.removeItem(at: file)
      }
      return true
    } catch {
      return FlutterError(code: "publish_failed", message: error.localizedDescription, details: nil)
    }
  }

  /// True if any family app on this phone has written a membership that has not run out.
  private func readPatron() -> Bool {
    guard let root = linkRoot() else { return false }
    let dir = root.appendingPathComponent("patron", isDirectory: true)
    guard let files = try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)
    else { return false }
    for file in files where file.pathExtension == "json" {
      guard
        let data = try? Data(contentsOf: file),
        let entry = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
        (entry["active"] as? Bool) == true
      else { continue }
      // A date that cannot be read counts as run out: never a free membership.
      if let until = entry["until"] as? String {
        guard let date = parseDate(until), date >= Date() else { continue }
      }
      return true
    }
    return false
  }

  /// Dart writes dates like 2026-11-11T12:00:00.000Z (with milliseconds); accept
  /// that and the plain form.
  private func parseDate(_ text: String) -> Date? {
    let withFraction = ISO8601DateFormatter()
    withFraction.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    if let d = withFraction.date(from: text) { return d }
    return ISO8601DateFormatter().date(from: text)
  }

  /// Opens another Véda app by its link scheme.
  private func openApp(_ args: [String: Any], result: @escaping FlutterResult) {
    DispatchQueue.main.async {
      guard
        let id = self.appId(fromName: args["package"] as? String),
        let url = URL(string: "vedalink-\(id)://open"),
        UIApplication.shared.canOpenURL(url)
      else {
        result("missing")
        return
      }
      UIApplication.shared.open(url, options: [:]) { ok in
        result(ok ? "opened" : "missing")
      }
    }
  }
}
