import Foundation

extension Node {
  /// Log the tree underneath the current node.
  /// ```
  /// → ContentView
  ///   → VStack<Text>
  ///     → Text
  /// ```
  func logTree() {
    logTree(level: 0)
  }

  fileprivate func logTree(level: Int) {
    let indent = Array(repeating: " ", count: level * 2).joined()
    log("\(indent)→ \(type(of: self.view))")
    for child in children {
      if let child = child as? (any _NodeLogging) {
        child.logTree(level: level + 1)
      }
    }
  }
}

private protocol _NodeLogging {
  associatedtype T

  func logTree(level: Int)
}

extension Node: _NodeLogging {
}
