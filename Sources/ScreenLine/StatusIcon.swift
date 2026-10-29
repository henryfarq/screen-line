import AppKit

/// The menu bar icon: one wide card hanging from a line by two clips,
/// drawn as a template so macOS tints it for light and dark menu bars.
enum StatusIcon {
    static func image() -> NSImage {
        let image = NSImage(size: NSSize(width: 20, height: 16), flipped: false) { _ in
            NSColor.black.set()

            let rope = NSBezierPath()
            rope.move(to: NSPoint(x: 0.5, y: 13.8))
            rope.curve(to: NSPoint(x: 19.5, y: 13.8),
                       controlPoint1: NSPoint(x: 6, y: 10.4), controlPoint2: NSPoint(x: 14, y: 10.4))
            rope.lineWidth = 1.1
            rope.lineCapStyle = .round
            rope.stroke()

            // The card hangs a little crooked, held by a clip at each end.
            let transform = NSAffineTransform()
            transform.translateX(by: 10, yBy: 11.4)
            transform.rotate(byDegrees: -4)
            transform.translateX(by: -10, yBy: -11.4)
            transform.concat()

            NSBezierPath(roundedRect: NSRect(x: 3.2, y: 2.4, width: 13.6, height: 9),
                         xRadius: 2, yRadius: 2).fill()
            for x in [5.2, 13.2] as [CGFloat] {
                NSBezierPath(roundedRect: NSRect(x: x, y: 10, width: 1.6, height: 3.8),
                             xRadius: 0.8, yRadius: 0.8).fill()
            }
            return true
        }
        image.isTemplate = true
        return image
    }
}
