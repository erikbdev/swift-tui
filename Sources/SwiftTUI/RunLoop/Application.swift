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
  var sigWinChSource: DispatchSourceSignal?
  var sigIntSource: DispatchSourceSignal?

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
      control.layout(size: window.layer.frame.size)
      renderer.draw()

      stdInSource = DispatchSource.makeReadSource(fileDescriptor: STDIN_FILENO, queue: .main)
      stdInSource?.setEventHandler { [weak self] in
        self?.handleInput(String(data: FileHandle.standardInput.availableData, encoding: .utf8) ?? "")
      }
      stdInSource?.resume()

      sigWinChSource = DispatchSource.makeSignalSource(signal: SIGWINCH, queue: .main)
      sigWinChSource?.setEventHandler { [weak self] in
        self?.handleWindowSizeChange()
      }
      sigWinChSource?.resume()

      signal(SIGINT, SIG_IGN)
      sigIntSource = DispatchSource.makeSignalSource(signal: SIGINT, queue: .main)
      sigIntSource?.setEventHandler { [weak self] in
        self?.stop()
      }
      sigIntSource?.resume()

    #if os(macOS)
      switch Application.runLoopType {
      case .dispatch:
        dispatchMain()
      case .cocoa:
        NSApplication.shared.setActivationPolicy(.accessory)
        NSApplication.shared.run()
      }
    #else
      dispatchMain()
    #endif
    } else {
      control.layout(size: window.layer.frame.size)
      renderer.draw()
    }
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
    guard !updateScheduled else { return }
    updateScheduled = true
    self.update()
  }

  private func update() {
    for node in invalidatedNodes {
      node.invalidate()
    }
    invalidatedNodes.removeAll(keepingCapacity: true)

    control.layout(size: window.layer.frame.size)
    renderer.update()
    updateScheduled = false
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
    // control.layer.invalidate()
    // update()
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
      log("Could not get window size")
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
