import Cocoa

class LogViewController: NSViewController {
    @objc var serverName: String = ""
    @IBOutlet var textView: NSTextView!
    @IBOutlet weak var titleLabel: NSTextField!
    override func viewWillAppear() {
        view.window!.level = .floating
        textView.textContainerInset = NSSize(width: 0, height: 8)
        titleLabel.stringValue = "Logs for \(serverName)"

        LogWatcher.shared.center.addObserver(self, selector: #selector(updateOutput), name: NSNotification.Name(serverName), object: nil)
    }

    override func viewWillDisappear() {
        LogWatcher.shared.center.removeObserver(self)
    }

    @objc func updateOutput() {
        let font = NSFont(name: "Fira Code", size: NSFont.systemFontSize) ?? NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
        textView.textStorage!.setAttributedString(try! LogWatcher.shared.logs[serverName]!.ansified(using: font))
    }

    @IBAction func clear(_: NSButton) {
        updateOutput()
    }
}
