import EventSource

struct Monitor {
    let name: String
    let status: ServerStatus
    let crashes: UInt
    let command: [String]
    let cwd: URL
    let env: [String: String]

    func start(_ completion: @escaping () -> Void = {}) {
        if status == .stopped || status == .stopping {
            post("/_/servers/\(name)/start", completion)
        } else {
            completion()
        }
    }

    func stop(_ completion: @escaping () -> Void = {}) {
        if status == .running {
            post("/_/servers/\(name)/stop", completion)
        } else {
            completion()
        }
    }
}

enum ServerStatus: String {
    case running
    case stopping
    case stopped
}

class Hotel {
    static let shared = Hotel()
    static let serverListUpdatedNoticationName = NSNotification.Name("hotel server list updated")

    let source = EventSource(url: URL(string: "/_/events", relativeTo: HotelConfig.shared.url)!)

    private(set) var servers: [Monitor] = []

    private init() {
        source.onMessage { _, _, str in
            if let dict = try? JSONSerialization.jsonObject(with: Data(str!.utf8)) as? [String: [String: AnyObject]] {
                self.servers = dict.map { (name, value) -> Monitor in
                    var env = value["env"] as! [String: AnyObject]
                    if let port = env["PORT"] {
                        env["PORT"] = String(describing: port) as AnyObject
                    }
                    return Monitor(
                        name: name,
                        status: ServerStatus(rawValue: value["status"] as! String)!,
                        crashes: value["crashes"] as! UInt,
                        command: value["command"] as! [String],
                        cwd: URL(fileURLWithPath: value["cwd"] as! String),
                        env: env as! [String: String]
                    )
                }.sorted(by: { $0.name < $1.name })
                NotificationCenter.default.post(name: Hotel.serverListUpdatedNoticationName, object: self)
            }
        }
        source.connect()
    }

    deinit {
        source.disconnect()
    }
}

func post(_ route: String, _ completion: @escaping () -> Void) {
    var request = URLRequest(url: URL(string: route, relativeTo: HotelConfig.shared.url)!)
    request.httpMethod = "POST"
    URLSession.shared.dataTask(with: request) { data, _, err in
        if data != nil {
            completion()
        } else {
            print(err as Any)
        }
    }.resume()
}
