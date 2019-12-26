import Foundation

struct HotelConfig {
    static let shared = HotelConfig(readConfig()!)

    private static func readConfig() -> [String: AnyObject]? {
        do {
            let data = try Data(
                contentsOf: URL(
                    fileURLWithPath: ".hotel/conf.json",
                    relativeTo: URL(fileURLWithPath: NSHomeDirectory())
                ),
                options: .mappedIfSafe
            )
            if data.count == 0 {
                return [:]
            } else {
                let jsonResult = try JSONSerialization.jsonObject(with: data)
                return jsonResult as? Dictionary<String, AnyObject>
            }
        } catch {
            print(error)
            // handle error
            return nil
        }
    }

    let port: UInt16
    let host: Host
    let timeout: TimeInterval
    let tld: String
    let proxy: Bool
    private init(_ config: Dictionary<String, AnyObject>) {
        port = config["port"] as? UInt16 ?? 2000
        host = Host(address: config["address"] as? String ?? "127.0.0.1")
        timeout = (config["timeout"] as? Double ?? 5000) / 1000
        tld = config["tld"] as? String ?? "localhost"
        proxy = config["proxy"] as? Bool ?? false
    }

    var url: URL { URL(string: "http://\(host.address!):\(port)")! }
}
