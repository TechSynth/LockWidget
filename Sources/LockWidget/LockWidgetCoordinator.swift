import AppKit
import Foundation

@MainActor
public final class LockWidgetCoordinator {
    public static let shared = LockWidgetCoordinator()
    
    private var windows: [LockOverlayWindow] = []
    private var isLocked: Bool = false
    private var statusItem: NSStatusItem?
    
    private var verticalRatio: CGFloat {
        get {
            let val = UserDefaults.standard.double(forKey: "LockWidgetVerticalRatio")
            return val > 0 ? CGFloat(val) : 0.14
        }
        set {
            UserDefaults.standard.set(Double(newValue), forKey: "LockWidgetVerticalRatio")
            for window in windows {
                window.updateVerticalPosition(newValue)
            }
        }
    }
    
    private init() {}
    
    public func start() {
        setupStatusItem()
        setupWindows()
        registerObservers()
    }
    
    private func setupStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = item.button {
            button.image = NSImage(systemSymbolName: "music.note", accessibilityDescription: "LockWidget")
            button.image?.isTemplate = true
        }
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "LockWidget Active", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        
        let previewItem = NSMenuItem(title: "Preview Lock Widget (5s)", action: #selector(previewAction), keyEquivalent: "p")
        previewItem.target = self
        menu.addItem(previewItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let nudgeDownItem = NSMenuItem(title: "Nudge Position Down", action: #selector(nudgeDownAction), keyEquivalent: "j")
        nudgeDownItem.target = self
        menu.addItem(nudgeDownItem)
        
        let nudgeUpItem = NSMenuItem(title: "Nudge Position Up", action: #selector(nudgeUpAction), keyEquivalent: "k")
        nudgeUpItem.target = self
        menu.addItem(nudgeUpItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(title: "Quit LockWidget", action: #selector(quitAction), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        item.menu = menu
        self.statusItem = item
    }
    
    @objc private func nudgeDownAction() {
        verticalRatio = max(0.10, verticalRatio - 0.04)
        triggerQuickPreview()
    }
    
    @objc private func nudgeUpAction() {
        verticalRatio = min(0.80, verticalRatio + 0.04)
        triggerQuickPreview()
    }
    
    private func triggerQuickPreview() {
        SpotifyManager.shared.startPolling()
        for window in windows {
            window.showWidget()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            guard let self = self, !self.isLocked else { return }
            for window in self.windows {
                window.hideWidget()
            }
            SpotifyManager.shared.stopPolling()
        }
    }
    
    @objc private func previewAction() {
        SpotifyManager.shared.startPolling()
        for window in windows {
            window.showWidget()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
            guard let self = self, !self.isLocked else { return }
            for window in self.windows {
                window.hideWidget()
            }
            SpotifyManager.shared.stopPolling()
        }
    }
    
    @objc private func quitAction() {
        NSApplication.shared.terminate(nil)
    }
    
    private func setupWindows() {
        windows.removeAll()
        let ratio = self.verticalRatio
        for screen in NSScreen.screens {
            let window = LockOverlayWindow(screen: screen, verticalRatio: ratio)
            SkyLightHelper.shared.attachWindowToLockSpace(window.windowNumber)
            windows.append(window)
        }
    }
    
    private func registerObservers() {
        let dnc = DistributedNotificationCenter.default()
        
        dnc.addObserver(
            forName: NSNotification.Name("com.apple.screenIsLocked"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.handleScreenLocked()
            }
        }
        
        dnc.addObserver(
            forName: NSNotification.Name("com.apple.screenIsUnlocked"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.handleScreenUnlocked()
            }
        }
        
        let wsnc = NSWorkspace.shared.notificationCenter
        wsnc.addObserver(
            forName: NSWorkspace.screensDidWakeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                if self?.isLocked == true {
                    self?.handleScreenLocked()
                }
            }
        }
    }
    
    private func handleScreenLocked() {
        self.isLocked = true
        SpotifyManager.shared.refresh()
        
        if SpotifyManager.shared.isSpotifyRunning && SpotifyManager.shared.currentTrack != .empty {
            SpotifyManager.shared.startPolling()
            for window in windows {
                SkyLightHelper.shared.attachWindowToLockSpace(window.windowNumber)
                window.showWidget()
            }
        }
    }
    
    private func handleScreenUnlocked() {
        self.isLocked = false
        SpotifyManager.shared.stopPolling()
        for window in windows {
            window.hideWidget()
        }
    }
}
