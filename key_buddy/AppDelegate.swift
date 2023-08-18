import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("did finish launching")
        NSApp.hide(nil)
        NSApp.setActivationPolicy(.accessory)
    }
}
