import AppKit
import SwiftUI

@MainActor
public final class LockOverlayWindow: NSPanel {
    private let targetScreen: NSScreen
    
    public init(screen: NSScreen, verticalRatio: CGFloat = 0.14) {
        self.targetScreen = screen
        let cardWidth: CGFloat = 400
        let cardHeight: CGFloat = 134
        
        let screenRect = screen.frame
        let posX = screenRect.origin.x + (screenRect.width - cardWidth) / 2
        let posY = screenRect.origin.y + (screenRect.height * verticalRatio)
        
        let windowRect = NSRect(
            x: posX,
            y: posY,
            width: cardWidth,
            height: cardHeight
        )
        
        super.init(
            contentRect: windowRect,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = false
        self.isMovable = false
        self.ignoresMouseEvents = false
        self.acceptsMouseMovedEvents = true
        self.canBecomeVisibleWithoutLogin = true
        self.level = .init(rawValue: Int(Int32.max - 2))
        self.collectionBehavior = [
            .fullScreenAuxiliary,
            .stationary,
            .canJoinAllSpaces,
            .ignoresCycle
        ]
        
        let hostingView = NSHostingView(rootView: LockWidgetView())
        hostingView.frame = NSRect(x: 0, y: 0, width: cardWidth, height: cardHeight)
        self.contentView = hostingView
        
        self.alphaValue = 0
    }
    
    public func updateVerticalPosition(_ ratio: CGFloat) {
        let cardWidth: CGFloat = 400
        let cardHeight: CGFloat = 134
        let screenRect = targetScreen.frame
        let posX = screenRect.origin.x + (screenRect.width - cardWidth) / 2
        let posY = screenRect.origin.y + (screenRect.height * ratio)
        
        self.setFrame(
            NSRect(x: posX, y: posY, width: cardWidth, height: cardHeight),
            display: true,
            animate: false
        )
    }
    
    public override var canBecomeKey: Bool {
        false
    }
    
    public override var canBecomeMain: Bool {
        false
    }
    
    public func showWidget() {
        self.orderFrontRegardless()
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.35
            self.animator().alphaValue = 1.0
        }
    }
    
    public func hideWidget() {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.2
            self.animator().alphaValue = 0.0
        }, completionHandler: { [weak self] in
            DispatchQueue.main.async {
                self?.orderOut(nil)
            }
        })
    }
}
