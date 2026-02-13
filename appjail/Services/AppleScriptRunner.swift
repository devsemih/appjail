import Foundation

enum AppleScriptRunner {
    nonisolated static func execute(_ source: String) -> String? {
        let script = NSAppleScript(source: source)
        var error: NSDictionary?
        let result = script?.executeAndReturnError(&error)
        if let error {
            print("AppleScript error: \(error)")
            return nil
        }
        return result?.stringValue
    }

    @discardableResult
    nonisolated static func executeIgnoringResult(_ source: String) -> Bool {
        let script = NSAppleScript(source: source)
        var error: NSDictionary?
        script?.executeAndReturnError(&error)
        return error == nil
    }
}
