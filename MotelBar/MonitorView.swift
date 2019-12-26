import SwiftUI

let indicatorSize: CGFloat = 11

struct MonitorView: Highlightable, View {
    @ObservedObject var monitor: PubState<Monitor>
    @ObservedObject var highlighted = PubState(false)
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    init(_ monitor: Monitor) {
        self.monitor = PubState(monitor)
    }

    private var statusColor: Color {
        switch monitor.value.status {
        case .running: return .green
        case .stopping: return .yellow
        case .stopped: return .gray
        }
    }

    private var textColor: Color {
        if colorScheme == .light && highlighted.value {
            return .white
        } else {
            return Color(NSColor.textColor)
        }
    }

    private var disclosureArrow: some View {
        let image = Image(nsImage: NSImage(named: NSImage.touchBarPlayTemplateName)!)
            .resizable()
            .frame(width: 11, height: 25)

        if colorScheme == .light && highlighted.value {
            return AnyView(image.colorInvert())

        } else {
            return AnyView(image)
        }
    }

    var body: some View {
        HStack {
            Circle()
                .foregroundColor(statusColor.opacity(0.75))
                .frame(width: indicatorSize, height: indicatorSize)
                .overlay(
                    Circle()
                        .stroke(textColor.opacity(0.25))
                        .frame(width: indicatorSize - 1, height: indicatorSize - 1)
                )
            VStack(alignment: .leading) {
                Text(monitor.value.name)
                    .foregroundColor(textColor)
                Text("\(monitor.value.crashes) crashes")
                    .foregroundColor(textColor.opacity(0.66))
                    .font(.caption)
            }
            Spacer(minLength: 16)
            disclosureArrow
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
}

struct MonitorView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: HorizontalAlignment.leading) {
            MonitorView(Monitor(name: "app-name", status: .running, crashes: 0, command: ["ls", "-l"], cwd: URL(fileURLWithPath: "/foo/bar/baz"), env: [:]))
            MonitorView(Monitor(name: "app-name-2", status: .running, crashes: 42, command: ["ls", "-l"], cwd: URL(fileURLWithPath: "/foo/bar/baz"), env: [:]))
            MonitorView(Monitor(name: "app-name-3", status: .stopping, crashes: 0, command: ["ls", "-l"], cwd: URL(fileURLWithPath: "/foo/bar/baz"), env: [:]))
            MonitorView(Monitor(name: "app-name-4", status: .stopped, crashes: 0, command: ["ls", "-l"], cwd: URL(fileURLWithPath: "/foo/bar/baz"), env: [:]))
        }.padding(8)
    }
}
