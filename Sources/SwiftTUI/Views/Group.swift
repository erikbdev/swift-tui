import Foundation

public struct Group<Content: View>: View, PrimitiveView {
  public let content: Content

  public init(@ViewBuilder _ content: () -> Content) {
    self.content = content()
  }

  static var size: Int? { Content.size }

  func buildNode(_ node: Node<Self>) {
    node.addNode(at: 0, Node(view: content))
  }

  func updateNode(_ node: Node<Self>) {
    node.view = self
    node.children[0].update(using: content)
  }

}
