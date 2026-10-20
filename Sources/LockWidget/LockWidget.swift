import AppKit

@main
final class AppDelegate: NSObject, NSApplicationDelegate {
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.setActivationPolicy(.accessory) // Runs without Dock icon, purely background/menu bar
        app.run()
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        LockWidgetCoordinator.shared.start()
    }
}
