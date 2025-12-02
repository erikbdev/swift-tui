import Foundation

#if os(macOS)
  import AppKit
#elseif os(Linux)
  import Glibc
#endif

private let systemWrite = write

public class Application: @unchecked Sendable {
  private let node: AnyNode
  private let window: Window
  private let control: Control
  private let renderer: Renderer

  private var arrowKeyParser = ArrowKeyParser()

  private var invalidatedNodes: [AnyNode] = []
  private var updateScheduled = false
  private var writeCallback: (String) -> Void

  private let readFromStd: Bool

  public init<I: View>(rootView: I, writer: ((String) -> Void)? = nil) {
    node = Node(view: VStack(content: rootView))
    node.build()

    control = node.control!

    window = Window()
    window.addControl(control)

    window.firstResponder = control.firstSelectableElement
    window.firstResponder?.becomeFirstResponder()

    renderer = Renderer(layer: window.layer)
    window.layer.renderer = renderer

    readFromStd = writer == nil
    writeCallback = writer ?? { str in
      str.withCString { _ = systemWrite(STDOUT_FILENO, $0, strlen($0)) }
    }

    node.application = self
    renderer.application = self
  }

  var stdInSource: DispatchSourceRead?

  #if os(macOS)
    public nonisolated(unsafe) static var runLoopType = RunLoopType.dispatch

    public enum RunLoopType {
      /// The default option, using Dispatch for the main run loop.
      case dispatch
      /// This creates and runs an NSApplication with an associated run loop. This allows you
      /// e.g. to open NSWindows running simultaneously to the terminal app. This requires macOS
      /// and AppKit.
      case cocoa
    }
  #endif

  public func start() {
    if readFromStd {
      setInputMode()
      updateWindowSize()
      let stdInSource = DispatchSource.makeReadSource(fileDescriptor: STDIN_FILENO, queue: .main)
      stdInSource.setEventHandler(qos: .default, flags: []) { [weak self] in
        self?.handleInput(FileHandle.standardInput.availableData)
      }
      stdInSource.resume()
      self.stdInSource = stdInSource

      let sigWinChSource = DispatchSource.makeSignalSource(signal: SIGWINCH, queue: .main)
      sigWinChSource.setEventHandler(qos: .default, flags: []) { [weak self] in
        self?.handleWindowSizeChange()
      }
      sigWinChSource.resume()

      signal(SIGINT, SIG_IGN)
      let sigIntSource = DispatchSource.makeSignalSource(signal: SIGINT, queue: .main)
      sigIntSource.setEventHandler(qos: .default, flags: []) { [weak self] in
        self?.stop()
      }
      sigIntSource.resume()
    }

    control.layout(size: window.layer.frame.size)
    renderer.draw()

    #if os(macOS)
      switch runLoopType {
      case .dispatch:
        dispatchMain()
      case .cocoa:
        NSApplication.shared.setActivationPolicy(.accessory)
        NSApplication.shared.run()
      }
    #else
      dispatchMain()
    #endif
  }

  public func handleInput(_ data: Data) {
    guard let string = String(data: data, encoding: .utf8) else {
      return
    }

    handleInput(string)
  }

  public func handleInput(_ string: String) {
    for char in string {
      if arrowKeyParser.parse(character: char) {
        guard let key = arrowKeyParser.arrowKey else { continue }
        arrowKeyParser.arrowKey = nil
        if key == .down {
          if let next = window.firstResponder?.selectableElement(below: 0) {
            window.firstResponder?.resignFirstResponder()
            window.firstResponder = next
            window.firstResponder?.becomeFirstResponder()
          }
        } else if key == .up {
          if let next = window.firstResponder?.selectableElement(above: 0) {
            window.firstResponder?.resignFirstResponder()
            window.firstResponder = next
            window.firstResponder?.becomeFirstResponder()
          }
        } else if key == .right {
          if let next = window.firstResponder?.selectableElement(rightOf: 0) {
            window.firstResponder?.resignFirstResponder()
            window.firstResponder = next
            window.firstResponder?.becomeFirstResponder()
          }
        } else if key == .left {
          if let next = window.firstResponder?.selectableElement(leftOf: 0) {
            window.firstResponder?.resignFirstResponder()
            window.firstResponder = next
            window.firstResponder?.becomeFirstResponder()
          }
        }
      } else if char == ASCII.EOT {
        stop()
      } else {
        window.firstResponder?.handleEvent(char)
      }
    }
  }

  func invalidateNode(_ node: AnyNode) {
    invalidatedNodes.append(node)
    scheduleUpdate()
  }

  func scheduleUpdate() {
    if !updateScheduled {
      self.update()
      updateScheduled = true
    }
  }

  private func update() {
    updateScheduled = false

    for node in invalidatedNodes {
      node.invalidate()
    }
    invalidatedNodes = []

    control.layout(size: window.layer.frame.size)
    renderer.update()
  }


  public func stop() {
    renderer.stop()
    if readFromStd {
      resetInputMode()  // Fix for: https://github.com/rensbreur/SwiftTUI/issues/25
      exit(0)
    } else {
      // TODO: send empty string?
    }
  }

  func write(_ str: String) {
    writeCallback(str)
  }

  public func changeWindowsSize(to size: Size) {
    window.layer.frame.size = size
    renderer.setCache()
    control.layer.invalidate()
    update()
  }

  private func handleWindowSizeChange() {
    updateWindowSize()
    control.layer.invalidate()
    update()
  }

  private func updateWindowSize() {
    var size = winsize()
    guard ioctl(STDOUT_FILENO, UInt(TIOCGWINSZ), &size) == 0,
      size.ws_col > 0, size.ws_row > 0
    else {
      assertionFailure("Could not get window size")
      return
    }
    window.layer.frame.size = Size(width: Extended(Int(size.ws_col)), height: Extended(Int(size.ws_row)))
    renderer.setCache()
  }

  private func setInputMode() {
    var tattr = termios()
    tcgetattr(STDIN_FILENO, &tattr)
    tattr.c_lflag &= ~tcflag_t(ECHO | ICANON)
    tcsetattr(STDIN_FILENO, TCSAFLUSH, &tattr)
  }

  /// Fix for: https://github.com/rensbreur/SwiftTUI/issues/25
  private func resetInputMode() {
    // Reset ECHO and ICANON values:
    var tattr = termios()
    tcgetattr(STDIN_FILENO, &tattr)
    tattr.c_lflag |= tcflag_t(ECHO | ICANON)
    tcsetattr(STDIN_FILENO, TCSAFLUSH, &tattr)
  }
}
