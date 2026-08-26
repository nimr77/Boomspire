import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()

    // Launch straight into native fullscreen - this is a desktop game, not
    // a windowed utility app.
    self.collectionBehavior.insert(.fullScreenPrimary)
    DispatchQueue.main.async { [weak self] in
      self?.toggleFullScreen(nil)
    }
  }
}
