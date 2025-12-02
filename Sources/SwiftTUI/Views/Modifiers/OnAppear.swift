import Foundation

extension View {
  public nonisolated func onAppear(_ action: (() -> Void)? = nil) -> some View {
    OnAppear(content: self, action: action)
  }
}

private struct OnAppear<Content: View>: View, PrimitiveView, ModifierView {
  let content: Content
  let action: (() -> Void)?

  static var size: Int? { Content.size }

  func buildNode(_ node: Node<Self>) {
    node.addNode(at: 0, Node(view: content))
  }

  func updateNode(_ node: Node<Self>) {
    node.view = self
    node.children[0].update(using: content)
  }

  func passControl(_ control: Control, node: Node<Self>) -> Control {
    if let onAppearControl = control.parent { return onAppearControl }
    let onAppearControl = OnAppearControl(action: action)
    onAppearControl.addSubview(control, at: 0)
    return onAppearControl
  }

  private class OnAppearControl: Control {
    let action: (() -> Void)?
    var didAppear = false

    init(action: (() -> Void)?) {
      self.action = action
    }

    override func size(proposedSize: Size) -> Size {
      children[0].size(proposedSize: proposedSize)
    }

    override func layout(size: Size) {
      super.layout(size: size)
      children[0].layout(size: size)
      if !didAppear {
        didAppear = true
        if let action {
          action()
        }
      }
    }
  }
}
