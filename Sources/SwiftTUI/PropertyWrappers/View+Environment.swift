import Foundation

extension View {
  func setupEnvironmentProperties(node: Node<Self>) {
    // TODO: Use reflection API
    for (_, value) in Mirror(reflecting: self).children {
      if let environmentValue = value as? AnyEnvironment {
        environmentValue.valueReference.node = node
      }
    }
  }
}
