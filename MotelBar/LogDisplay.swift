import SwiftUI

final class LogDisplay: NSViewRepresentable {
    typealias NSViewType = NSScrollView

    let content: Binding<String>
    init(content: Binding<String>) {
        self.content = content
    }

    func makeNSView(context: NSViewRepresentableContext<LogDisplay>) -> NSViewType {
        let scrollView = NSTextView.scrollableTextView()
        let textView = scrollView.documentView as! NSTextView

        scrollView.drawsBackground = false
        textView.isEditable = false
        textView.isSelectable = false
        textView.drawsBackground = false
        textView.textContainerInset = NSSize(width: 4, height: 0)

        return scrollView
    }

    func updateNSView(_ scrollView: NSViewType, context: NSViewRepresentableContext<LogDisplay>) {
        let font = NSFont(name: "Fira Code", size: NSFont.systemFontSize) ?? NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
        let textView = scrollView.documentView as! NSTextView
        if let attStr = try? content.wrappedValue.ansified(using: font) {
            let oldVal = textView.textStorage!.attributedString()
            textView.textStorage!.setAttributedString(attStr)
            if attStr != oldVal {
                DispatchQueue.main.async {
                    let y = textView.frame.height - scrollView.contentSize.height
                    NSAnimationContext.beginGrouping()
                    NSAnimationContext.current.duration = 0.2
                    scrollView.contentView.animator().setBoundsOrigin(NSPoint(x: 0, y: y))
                    scrollView.reflectScrolledClipView(scrollView.contentView)
                    NSAnimationContext.endGrouping()
                }
            }
        }
    }
}

