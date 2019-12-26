import SwiftUI
import LaunchAtLogin

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let launchAtLoginItem = NSMenuItem(title: "Launch at Login", action: #selector(toggleLaunchAtLogin), keyEquivalent: "")
    var logWindow: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let button = statusItem.button {
            button.title = "H"
            let font = NSFont.systemFont(ofSize: 18, weight: .bold)
            button.font = font
        }

        if LaunchAtLogin.isEnabled {
            launchAtLoginItem.state = .on
        }

        let menu = NSMenu()
        menu.delegate = self

        [
            NSMenuItem.separator(),
            launchAtLoginItem,
            NSMenuItem(title: "Open Hotel…", action: #selector(openHotel), keyEquivalent: ""),
            NSMenuItem(title: "About…", action: #selector(showAbout), keyEquivalent: ""),
            NSMenuItem(title: "Quit", action: #selector(NSApp.terminate), keyEquivalent: "q"),
        ].forEach(menu.addItem(_:))
        statusItem.menu = menu
        renderMenu()

        NotificationCenter.default.addObserver(self, selector: #selector(renderMenu), name: Hotel.serverListUpdatedNoticationName, object: Hotel.shared)
    }
    
    @objc func showAbout() {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.orderFrontStandardAboutPanel(self)
    }
    
    @objc func toggleLaunchAtLogin() {
        if launchAtLoginItem.state == .on {
            launchAtLoginItem.state = .off
            LaunchAtLogin.isEnabled = false
        } else {
            launchAtLoginItem.state = .on
            LaunchAtLogin.isEnabled = true
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        NotificationCenter.default.removeObserver(self)
    }
    
    func onMainThread(block: () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            print("maining")
            DispatchQueue.main.sync(execute: block)
        }
    }

    @objc func renderMenu() {
        onMainThread {
        let menu: NSMenu = statusItem.menu!
        let sepIdx = {
            menu.items.firstIndex { $0.isSeparatorItem }!
        }

        if Hotel.shared.servers.isEmpty {
            for _ in 0 ..< sepIdx() {
                menu.removeItem(at: 0)
            }
            let item = menu.insertItem(withTitle: "No servers", action: nil, keyEquivalent: "", at: 0)
            item.isEnabled = false
        } else {
            menu.cleanServerMenu(Hotel.shared.servers.map { $0.name })
            Hotel.shared.servers.forEach { server in
                if let idx = menu.items.firstIndex(where: { item in item.representedObject as? String == server.name }) {
                    let item = menu.items[idx]
                    (item.view as! MenuItemView<MonitorView>).contentView.monitor.value = server
                    (item.submenu!.items.first!.view as! MenuItemView<LogView>).contentView.monitor.value = server
                    item.state = server.status == .running ? .on : .off
                } else {
                    let item = menu.insertItem(withTitle: server.name, action: nil, keyEquivalent: "",
                                               at: sepIdx())
                    item.representedObject = server.name
                    item.view = MenuItemView(MonitorView(server))
                    let submenu = NSMenu()
                    let logItem = submenu.addItem(withTitle: "", action: nil, keyEquivalent: "")
                    logItem.isEnabled = false
                    logItem.view = MenuItemView(LogView(server))
                    item.submenu = submenu

                    item.state = server.status == .running ? .on : .off
                }
            }
            }}
    }
    
    @objc func openHotel() {
        NSWorkspace.shared.open(URL(string: "http://hotel.\(HotelConfig.shared.tld)")!)
    }
}

extension AppDelegate: NSMenuDelegate {
    func menu(_ menu: NSMenu, willHighlight item: NSMenuItem?) {
        for item in menu.items {
            if item.isSeparatorItem { return }
            item.view?.setNeedsDisplay(item.view!.frame)
        }
    }
}
