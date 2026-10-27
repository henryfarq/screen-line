import AppKit

/// The menu bar icon: a line with two cards hanging from it, drawn as a
/// template so macOS tints it for light and dark menu bars.
enum StatusIcon {
    static func image() -> NSImage {
        let image = NSImage(size: NSSize(width: 20, height: 16), flipped: false) { _ in
            NSColor.black.set()

            let rope = NSBezierPath()
            rope.move(to: NSPoint(x: 0.5, y: 14.6))
            rope.curve(to: NSPoint(x: 19.5, y: 14.6),
                       controlPoint1: NSPoint(x: 6, y: 10.4), controlPoint2: NSPoint(x: 14, y: 10.4))
            rope.lineWidth = 1.2
            rope.lineCapStyle = .round
            rope.stroke()

            // Each card hangs from the line by a clip, a little crooked.
            for (centre, topY, angle) in [(5.6, 12.6, 5.0), (14.4, 12.6, -5.0)] as [(CGFloat, CGFloat, CGFloat)] {
                let transform = NSAffineTransform()
                transform.translateX(by: centre, yBy: topY)
                transform.rotate(byDegrees: angle)
                transform.translateX(by: -centre, yBy: -topY)
                transform.concat()

                NSBezierPath(roundedRect: NSRect(x: centre - 3.7, y: topY - 7.2, width: 7.4, height: 7.2),
                             xRadius: 1.6, yRadius: 1.6).fill()
                NSBezierPath(roundedRect: NSRect(x: centre - 0.8, y: topY - 1, width: 1.6, height: 3.6),
                             xRadius: 0.8, yRadius: 0.8).fill()

                transform.invert()
                transform.concat()
            }
            return true
        }
        image.isTemplate = true
        return image
    }
}
