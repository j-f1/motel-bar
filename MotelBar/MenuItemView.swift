//
//  MenuItemView.swift
//  MotelBar
//
//  Created by Jed Fox on 12/23/19.
//  Copyright © 2019 Jed Fox. All rights reserved.
//

import AppKit
import Foundation
import SwiftUI

protocol Highlightable {
    /// `@ObservedObject var highlighted = Highlighted(false)`
    var highlighted: PubState<Bool> { get }
}

class PubState<T>: ObservableObject {
    init(_ value: T) {
        self.value = value
    }

    @Published var value: T
}

class MenuItemView<ContentView: View>: NSView {
    private var effectView: NSVisualEffectView
    let contentView: ContentView
    private let hostView: NSHostingView<ContentView>

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

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ dirtyRect: NSRect) {
        let highlighted = enclosingMenuItem!.isHighlighted
        effectView.isHidden = !highlighted
        (contentView as? Highlightable)?.highlighted.value = highlighted
        super.draw(dirtyRect)
    }
}
