import Foundation

extension View {
  public func background(_ color: Color) -> some View {
    Background(content: self, color: color)
  }
}

private struct Background<Content: View>: View, PrimitiveView, ModifierView {
  let content: Content
  let color: Color

  static var size: Int? { Content.size }

  func buildNode(_ node: Node<Self>) {
    node.controls = WeakSet<Control>()
    node.addNode(at: 0, Node(view: content))
  }

  func updateNode(_ node: Node<Self>) {
    node.view = self
    node.children[0].update(using: content)
    for control in node.controls?.values ?? [] {
      let control = control as! BackgroundControl
      if control.color != color {
        control.color = color
        control.layer.invalidate()
      }
    }
  }

  func passControl(_ control: Control, node: Node<Self>) -> Control {
    if let backgroundControl = control.parent { return backgroundControl }
    let backgroundControl = BackgroundControl(color: color)
    backgroundControl.addSubview(control, at: 0)
    node.controls?.add(backgroundControl)
    return backgroundControl
  }

  private class BackgroundControl: Control {
    var color: Color

    init(color: Color) {
      self.color = color
    }

    override func size(proposedSize: Size) -> Size {
      children[0].size(proposedSize: proposedSize)
    }

    override func layout(size: Size) {
      super.layout(size: size)
      children[0].layout(size: size)
    }

    override func cell(at position: Position) -> Cell? {
      Cell(char: " ", backgroundColor: color)
    }
  }
}
