//
//  LogView.swift
//  MotelBar
//
//  Created by Jed Fox on 12/23/19.
//  Copyright © 2019 Jed Fox. All rights reserved.
//

import SwiftUI

fileprivate let size = CGSize(width: 450, height: 250)

/// Work around a Swift compiler crash. ref: `FB7506105`
class LogStateHelper {
    let name: String
    var update: ((String) -> Void)?
    init(_ name: String) {
        self.name = name
        LogWatcher.shared.center.addObserver(self, selector: #selector(updateState), name: Notification.Name(name), object: nil)
    }

    @objc func updateState() {
        update?(LogWatcher.shared.logs[name]!)
    }
}

class LogState: PubState<String> {
    let helper: LogStateHelper
    init(name: String) {
        helper = LogStateHelper(name)
        super.init(LogWatcher.shared.logs[name] ?? "")
        helper.update = { self.value = $0 }
    }
}

struct SizedButton: View {
    let title: String
    let action: () -> Void
    let width: CGFloat
    init(_ title: String, width: CGFloat, action: @escaping () -> Void) {
        self.title = title
        self.action = action
        self.width = width
    }

    var body: some View {
        Button(action: action) {
            Text(title).frame(width: width)
        }
    }
}

struct LogView: View {
    @ObservedObject var monitor: PubState<Monitor>
    @ObservedObject var log: LogState
    @State var text = "hi"
    init(_ monitor: Monitor) {
        self.monitor = PubState(monitor)
        log = LogState(name: monitor.name)
    }

    private var buttonTitle: String {
        switch monitor.value.status {
        case .running:
            return "Stop"
//        case .stopping:
//            return "Stopping…"
        case .stopping, .stopped:
            return "Start"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                SizedButton(buttonTitle, width: 30) {
                    if self.monitor.value.status == .running {
                        self.monitor.value.stop()
                    } else {
                        self.monitor.value.start()
                    }
                }
                showIf(monitor.value.status == .running) {
                    SizedButton("Restart", width: 45) {
                        self.monitor.value.stop {
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now().advanced(by: .milliseconds(100))) {
                                self.monitor.value.start()
                            }
                        }
                    }
                }
                HStack {
                    Spacer()
                    Text("\(monitor.value.name) Logs")
                    Spacer()
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                .padding(.trailing, self.monitor.value.status == .running ? 77 : 0)
                Button(action: {
                    self.monitor.value.start {
                        NSWorkspace.shared.open(URL(string: "http://\(self.monitor.value.name).\(HotelConfig.shared.tld)")!)
                    }
                }) {
                    Image(nsImage: NSImage(named: NSImage.touchBarOpenInBrowserTemplateName)!)
                        .frame(height: 20)
                }.buttonStyle(BorderlessButtonStyle())
                SizedButton("Clear", width: 45) {
                    LogWatcher.shared.logs[self.monitor.value.name] = ""
                    self.log.helper.updateState()
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, 4)
            LogDisplay(content: $log.value)
                .frame(width: size.width, height: size.height)
        }
    }
}

func showIf<T>(_ cond: Bool, cb: () -> T) -> T? {
    cond ? cb() : nil
}

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
        textView.usesFindBar = true
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

struct LogView_Previews: PreviewProvider {
    static var previews: some View {
        LogView(Monitor(name: "app-name", status: .running, crashes: 0, command: ["ls", "-l"], cwd: URL(fileURLWithPath: "/foo/bar/baz"), env: [:]))
    }
}
