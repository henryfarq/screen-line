import AppKit
import SwiftUI

/// The eye lives in a small window of its own, so it can be dragged anywhere
/// on the screen. Let go and it is pulled to the nearer side, left or right.
final class EyePanel: NSPanel {
    static let size: CGFloat = 44
    private static let margin: CGFloat = 10

    /// A click, as opposed to a drag.
    var onClick: (() -> Void)?

    private var screenOfEye: NSScreen?

    init(line: Line) {
        super.init(contentRect: NSRect(x: 0, y: 0, width: Self.size, height: Self.size),
                   styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        // Above the line, so a photo never covers it.
        level = NSWindow.Level(rawValue: NSWindow.Level.floating.rawValue + 1)
        collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenAuxiliary]
        hidesOnDeactivate = false
        isMovable = false

        let host = NSHostingView(rootView: EyeControlView(line: line))
        host.sizingOptions = []
        let content = EyeContentView(frame: NSRect(x: 0, y: 0, width: Self.size, height: Self.size))
        host.frame = content.bounds
        host.autoresizingMask = [.width, .height]
        content.addSubview(host)
        content.panel = self
        contentView = content
    }

    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }

    // MARK: Where it sits

    private var onRight: Bool {
        get { UserDefaults.standard.string(forKey: "eyeSide") == "right" }
        set { UserDefaults.standard.set(newValue ? "right" : "left", forKey: "eyeSide") }
    }

    /// How far the eye sits below the top of the screen.
    private var distanceFromTop: CGFloat {
        get {
            UserDefaults.standard.object(forKey: "eyeTop") == nil
                ? 18 : CGFloat(UserDefaults.standard.double(forKey: "eyeTop"))
        }
        set { UserDefaults.standard.set(Double(newValue), forKey: "eyeTop") }
    }

    /// Puts the eye at its saved place on that screen.
    func place(on screen: NSScreen?) {
        guard !moved, let screen = screen ?? screenOfEye ?? NSScreen.main else { return }
        screenOfEye = screen
        let target = restingFrame(on: screen)
        if frame != target { setFrame(target, display: true) }
    }

    private func restingFrame(on screen: NSScreen) -> NSRect {
        let visible = screen.visibleFrame
        let y = min(max(visible.maxY - distanceFromTop - Self.size, visible.minY), visible.maxY - Self.size)
        let x = onRight ? screen.frame.maxX - Self.margin - Self.size : screen.frame.minX + Self.margin
        return NSRect(x: x, y: y, width: Self.size, height: Self.size)
    }

    // MARK: Dragging

    private var dragStartMouse = NSPoint.zero
    private var dragStartOrigin = NSPoint.zero
    private var moved = false

    fileprivate func beginDrag() {
        dragStartMouse = NSEvent.mouseLocation
        dragStartOrigin = frame.origin
        moved = false
    }

    fileprivate func drag() {
        let mouse = NSEvent.mouseLocation
        let dx = mouse.x - dragStartMouse.x, dy = mouse.y - dragStartMouse.y
        if !moved, hypot(dx, dy) < 4 { return }
        moved = true
        var origin = NSPoint(x: dragStartOrigin.x + dx, y: dragStartOrigin.y + dy)
        // Stays on a screen.
        if let screen = NSScreen.screens.first(where: { NSMouseInRect(mouse, $0.frame, false) }) ?? screenOfEye {
            let f = screen.frame
            origin.x = min(max(origin.x, f.minX), f.maxX - Self.size)
            origin.y = min(max(origin.y, f.minY), f.maxY - Self.size)
        }
        setFrameOrigin(origin)
    }

    fileprivate func endDrag() {
        guard moved else { onClick?(); return }
        moved = false
        let center = NSPoint(x: frame.midX, y: frame.midY)
        guard let screen = NSScreen.screens.first(where: { NSMouseInRect(center, $0.frame, false) })
                ?? screenOfEye ?? NSScreen.main else { return }
        screenOfEye = screen
        onRight = center.x > screen.frame.midX
        distanceFromTop = screen.visibleFrame.maxY - frame.maxY
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            context.timingFunction = CAMediaTimingFunction(controlPoints: 0.2, 0.9, 0.3, 1.0)
            animator().setFrame(restingFrame(on: screen), display: true)
        }
    }
}

/// Catches the mouse for the whole window: the hosted SwiftUI view only draws.
private final class EyeContentView: NSView {
    weak var panel: EyePanel?

    override func hitTest(_ point: NSPoint) -> NSView? { bounds.contains(point) ? self : nil }
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
    override func mouseDown(with event: NSEvent) { panel?.beginDrag() }
    override func mouseDragged(with event: NSEvent) { panel?.drag() }
    override func mouseUp(with event: NSEvent) { panel?.endDrag() }
}

/// An open eye while the line stays down (click to hide it); a closed eye
/// once it is hidden (click to keep it down).
private struct EyeControlView: View {
    @ObservedObject var line: Line

    var body: some View {
        Image(systemName: line.isAlwaysDown ? "eye" : "eye.slash")
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(.primary)
            .frame(width: 28, height: 28)
            .glassFrame(circle: true)
            .shadow(color: .black.opacity(0.15), radius: 6, y: 3)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
