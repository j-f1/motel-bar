import EventSource

class LogWatcher {
    static let shared = LogWatcher()

    let source = EventSource(url: URL(string: "/_/events/output", relativeTo: HotelConfig.shared.url)!)
    var logs = [String: String]()
    let center = NotificationCenter()
    private init() {
        source.onMessage { _, _, str in
            if let dict = try? JSONSerialization.jsonObject(with: Data(str!.utf8)) as? [String: String] {
                let name = dict["id"]!
                let str = dict["output"]!
                self.logs[name] = (self.logs[name] ?? "") + str
                self.center.post(name: NSNotification.Name(name), object: self)
            }
        }
        source.connect()
    }

    deinit {
        source.disconnect()
    }
}
