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
                SizedButton(title: buttonTitle, width: 30) {
                    if self.monitor.value.status == .running {
                        self.monitor.value.stop()
                    } else {
                        self.monitor.value.start()
                    }
                }
                if monitor.value.status == .running {
                    SizedButton(title: "Restart", width: 45) {
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
                SizedButton(title: "Clear", width: 45) {
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

struct LogView_Previews: PreviewProvider {
    static var previews: some View {
        LogView(Monitor(name: "app-name", status: .running, crashes: 0, command: ["ls", "-l"], cwd: URL(fileURLWithPath: "/foo/bar/baz"), env: [:]))
    }
}
