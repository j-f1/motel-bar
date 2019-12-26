import SwiftUI

class PubState<T>: ObservableObject {
    init(_ value: T) {
        self.value = value
    }

    @Published var value: T
}

protocol Highlightable {
    /// Implement with `@ObservedObject var highlighted = Highlighted(false)`
    var highlighted: PubState<Bool> { get }
}

class MenuItemView<ContentView: View>: NSView {
    private var effectView: NSVisualEffectView
    let contentView: ContentView
    let hostView: NSHostingView<ContentView>

    init(_ view: ContentView) {
        effectView = NSVisualEffectView()
        effectView.state = .active
        effectView.material = .selection
        effectView.isEmphasized = true
        effectView.blendingMode = .behindWindow

        contentView = view
        hostView = NSHostingView(rootView: contentView)

        super.init(frame: CGRect(origin: .zero, size: hostView.intrinsicContentSize))
        addSubview(effectView)
        addSubview(hostView)
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        if window != nil {
            frame = NSRect(
                origin: frame.origin,
                size: CGSize(width: enclosingMenuItem!.menu!.size.width, height: frame.height)
            )
            effectView.frame = frame
            hostView.frame = frame
        }
    }
    override func draw(_ dirtyRect: NSRect) {
        let highlighted = enclosingMenuItem!.isHighlighted
        effectView.isHidden = !highlighted
        (contentView as? Highlightable)?.highlighted.value = highlighted
        super.draw(dirtyRect)
    }
}
