// Makes the Screen Line app icon from Assets/icon-source.png: the picture
// is cropped to a rounded square on the macOS icon grid (824pt square with a
// 100pt margin) with a soft shadow.
// Usage: swift scripts/make-icon.swift Assets/icon-source.png out.png
import AppKit

let size: CGFloat = 1024
let args = Array(CommandLine.arguments.dropFirst())
guard args.count == 2, let source = NSImage(contentsOfFile: args[0]) else {
    FileHandle.standardError.write(Data("usage: make-icon.swift source.png out.png\n".utf8))
    exit(1)
}

let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(size), pixelsHigh: Int(size),
                           bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                           colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

let body = NSRect(x: 100, y: 100, width: 824, height: 824)
let shape = NSBezierPath(roundedRect: body, xRadius: 185, yRadius: 185)

NSGraphicsContext.saveGraphicsState()
let shadow = NSShadow()
shadow.shadowColor = NSColor(white: 0, alpha: 0.28)
shadow.shadowBlurRadius = 22
shadow.shadowOffset = NSSize(width: 0, height: -10)
shadow.set()
NSColor.white.setFill()
shape.fill()
NSGraphicsContext.restoreGraphicsState()

shape.addClip()
source.draw(in: body, from: .zero, operation: .sourceOver, fraction: 1)
NSGraphicsContext.restoreGraphicsState()

try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: args[1]))
