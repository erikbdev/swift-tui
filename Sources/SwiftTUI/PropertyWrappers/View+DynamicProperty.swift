extension View {
  func setupDynamicProperties(node: Node<Self>) {
    self.setupStateProperties(node: node)
    self.setupEnvironmentProperties(node: node)
    #if os(macOS)
      self.setupObservedObjectProperties(node: node)
    #endif
  }
}
