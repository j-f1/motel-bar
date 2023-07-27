import SwiftUI

let indicatorSize: CGFloat = 8

let triangleHeight = indicatorSize / CGFloat(3.squareRoot() / 2)
let triangle = Path { path in
    path.move(to: .zero)
    path.addLine(to: .init(x: indicatorSize, y: triangleHeight / 2))
    path.addLine(to: .init(x: 0, y: triangleHeight))
    path.closeSubpath()
}
let triangleStroke = Path { path in
    path.move(to: .init(x: 0.5, y: 1))
    path.addLine(to: .init(x: indicatorSize - 1, y: triangleHeight / 2))
    path.addLine(to: .init(x: 0.5, y: triangleHeight - 1))
    path.closeSubpath()
}

struct MonitorView: Highlightable, View {
    @ObservedObject var monitor: PubState<Monitor>
    @ObservedObject var highlighted = PubState(false)
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    /* @Environment(\.accessibilityDifferentiateWithoutColor) */ var differentiateWithoutColor = true

    init(_ monitor: Monitor) {
        self.monitor = PubState(monitor)
    }

    private var statusColor: Color {
        switch monitor.value.status {
        case .running: return .green
        case .stopping: return .yellow
        case .stopped: return .gray
        case .crashed: return .red
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

    @ViewBuilder private var statusSymbolStroke: some View {
        let circle = Circle()
            .stroke(textColor.opacity(0.25))
            .frame(width: indicatorSize - 1, height: indicatorSize - 1)
        
        if !differentiateWithoutColor {
            circle
        } else {
            switch monitor.value.status {
            case .running:
                triangleStroke.stroke(textColor.opacity(0.25))
            case .stopping:
                circle
            case .stopped:
                Rectangle().stroke(textColor.opacity(0.25))
                    .frame(width: indicatorSize - 1, height: indicatorSize - 1)
            case .crashed:
                triangleStroke
                    .rotation(.degrees(-90), anchor: .center)
                    .stroke(textColor.opacity(0.25))
            }
        }
    }
    private var statusSymbolFill: AnyView {
        let circle = AnyView(Circle().fill(statusColor.opacity(0.75)))
        if !differentiateWithoutColor {
            return circle
        } else {
            switch monitor.value.status {
            case .running:
                return AnyView(triangle.foregroundColor(statusColor.opacity(0.75)))
            case .stopping:
                return circle
            case .stopped:
                return AnyView(Rectangle().foregroundColor(statusColor.opacity(0.75)))
            case .crashed:
                return AnyView(triangle.rotation(.degrees(-90), anchor: .center).foregroundColor(statusColor.opacity(0.75)))
            }
        }
    }

    var body: some View {
        HStack(alignment: .center, spacing: 5) {
            statusSymbolFill
                .frame(width: indicatorSize, height: indicatorSize)
                .overlay(
                    statusSymbolStroke
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
        Group {
            MonitorView(Monitor(name: "app-name", status: .running, crashes: 0, command: ["ls", "-l"], cwd: URL(fileURLWithPath: "/foo/bar/baz"), env: [:]))
            MonitorView(Monitor(name: "app-name", status: .running, crashes: 1, command: ["ls", "-l"], cwd: URL(fileURLWithPath: "/foo/bar/baz"), env: [:]))
            MonitorView(Monitor(name: "app-name-2", status: .running, crashes: 42, command: ["ls", "-l"], cwd: URL(fileURLWithPath: "/foo/bar/baz"), env: [:]))
            MonitorView(Monitor(name: "app-name-3", status: .stopping, crashes: 0, command: ["ls", "-l"], cwd: URL(fileURLWithPath: "/foo/bar/baz"), env: [:]))
            MonitorView(Monitor(name: "app-name-4", status: .stopped, crashes: 0, command: ["ls", "-l"], cwd: URL(fileURLWithPath: "/foo/bar/baz"), env: [:]))
            MonitorView(Monitor(name: "app-name-2", status: .crashed, crashes: 42, command: ["ls", "-l"], cwd: URL(fileURLWithPath: "/foo/bar/baz"), env: [:]))
        }.frame(width: 168)
    }
}
