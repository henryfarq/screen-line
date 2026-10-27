import AppKit

/// Holds the line view and accepts screenshots and recordings dragged onto
/// the line, from Finder or the Desktop.
final class DropContainer: NSView {
    var onDrop: (([URL]) -> Void)?

    init(host: NSView) {
        super.init(frame: .zero)
        host.frame = bounds
        host.autoresizingMask = [.width, .height]
        addSubview(host)
        registerForDraggedTypes([.fileURL])
    }

    required init?(coder: NSCoder) { fatalError() }

    /// The files in a drag that can hang: images and recordings.
    static func hangable(in pasteboard: NSPasteboard) -> [URL] {
        let urls = pasteboard.readObjects(forClasses: [NSURL.self],
                                          options: [.urlReadingFileURLsOnly: true]) as? [URL] ?? []
        return urls.filter { ScreenshotWatcher.isHangable($0) }
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        Self.hangable(in: sender.draggingPasteboard).isEmpty ? [] : .copy
    }

    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        Self.hangable(in: sender.draggingPasteboard).isEmpty ? [] : .copy
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let urls = Self.hangable(in: sender.draggingPasteboard)
        guard !urls.isEmpty else { return false }
        onDrop?(urls)
        return true
    }
}
