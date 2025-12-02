import Foundation

public struct TupleView2<C0: View, C1: View>: View, PrimitiveView {
  public let content: (C0, C1)

  static var size: Int? {
    if let c0 = C0.size,
      let c1 = C1.size
    {
      return c0 + c1
    }
    return nil
  }

  func buildNode(_ node: Node<Self>) {
    node.addNode(at: 0, Node(view: content.0))
    node.addNode(at: 1, Node(view: content.1))
  }

  func updateNode(_ node: Node<Self>) {
    node.view = self
    node.children[0].update(using: content.0)
    node.children[1].update(using: content.1)
  }
}

public struct TupleView3<C0: View, C1: View, C2: View>: View, PrimitiveView {
  public let content: (C0, C1, C2)

  static var size: Int? {
    if let c0 = C0.size,
      let c1 = C1.size,
      let c2 = C2.size
    {
      return c0 + c1 + c2
    }
    return nil
  }

  func buildNode(_ node: Node<Self>) {
    node.addNode(at: 0, Node(view: content.0))
    node.addNode(at: 1, Node(view: content.1))
    node.addNode(at: 2, Node(view: content.2))
  }

  func updateNode(_ node: Node<Self>) {
    node.view = self
    node.children[0].update(using: content.0)
    node.children[1].update(using: content.1)
    node.children[2].update(using: content.2)
  }
}

public struct TupleView4<C0: View, C1: View, C2: View, C3: View>: View, PrimitiveView {
  public let content: (C0, C1, C2, C3)

  static var size: Int? {
    if let c0 = C0.size,
      let c1 = C1.size,
      let c2 = C2.size,
      let c3 = C3.size
    {
      return c0 + c1 + c2 + c3
    }
    return nil
  }

  func buildNode(_ node: Node<Self>) {
    node.addNode(at: 0, Node(view: content.0))
    node.addNode(at: 1, Node(view: content.1))
    node.addNode(at: 2, Node(view: content.2))
    node.addNode(at: 3, Node(view: content.3))
  }

  func updateNode(_ node: Node<Self>) {
    node.view = self
    node.children[0].update(using: content.0)
    node.children[1].update(using: content.1)
    node.children[2].update(using: content.2)
    node.children[3].update(using: content.3)
  }
}

public struct TupleView5<C0: View, C1: View, C2: View, C3: View, C4: View>: View, PrimitiveView {
  public let content: (C0, C1, C2, C3, C4)

  static var size: Int? {
    if let c0 = C0.size,
      let c1 = C1.size,
      let c2 = C2.size,
      let c3 = C3.size,
      let c4 = C4.size
    {
      return c0 + c1 + c2 + c3 + c4
    }
    return nil
  }

  func buildNode(_ node: Node<Self>) {
    node.addNode(at: 0, Node(view: content.0))
    node.addNode(at: 1, Node(view: content.1))
    node.addNode(at: 2, Node(view: content.2))
    node.addNode(at: 3, Node(view: content.3))
    node.addNode(at: 4, Node(view: content.4))
  }

  func updateNode(_ node: Node<Self>) {
    node.view = self
    node.children[0].update(using: content.0)
    node.children[1].update(using: content.1)
    node.children[2].update(using: content.2)
    node.children[3].update(using: content.3)
    node.children[4].update(using: content.4)
  }
}

public struct TupleView6<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View>: View, PrimitiveView {
  public let content: (C0, C1, C2, C3, C4, C5)

  static var size: Int? {
    if let c0 = C0.size,
      let c1 = C1.size,
      let c2 = C2.size,
      let c3 = C3.size,
      let c4 = C4.size,
      let c5 = C5.size
    {
      return c0 + c1 + c2 + c3 + c4 + c5
    }
    return nil
  }

  func buildNode(_ node: Node<Self>) {
    node.addNode(at: 0, Node(view: content.0))
    node.addNode(at: 1, Node(view: content.1))
    node.addNode(at: 2, Node(view: content.2))
    node.addNode(at: 3, Node(view: content.3))
    node.addNode(at: 4, Node(view: content.4))
    node.addNode(at: 5, Node(view: content.5))
  }

  func updateNode(_ node: Node<Self>) {
    node.view = self
    node.children[0].update(using: content.0)
    node.children[1].update(using: content.1)
    node.children[2].update(using: content.2)
    node.children[3].update(using: content.3)
    node.children[4].update(using: content.4)
    node.children[5].update(using: content.5)
  }
}

public struct TupleView7<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View>: View, PrimitiveView {
  public let content: (C0, C1, C2, C3, C4, C5, C6)

  static var size: Int? {
    if let c0 = C0.size,
      let c1 = C1.size,
      let c2 = C2.size,
      let c3 = C3.size,
      let c4 = C4.size,
      let c5 = C5.size,
      let c6 = C6.size
    {
      return c0 + c1 + c2 + c3 + c4 + c5 + c6
    }
    return nil
  }

  func buildNode(_ node: Node<Self>) {
    node.addNode(at: 0, Node(view: content.0))
    node.addNode(at: 1, Node(view: content.1))
    node.addNode(at: 2, Node(view: content.2))
    node.addNode(at: 3, Node(view: content.3))
    node.addNode(at: 4, Node(view: content.4))
    node.addNode(at: 5, Node(view: content.5))
    node.addNode(at: 6, Node(view: content.6))
  }

  func updateNode(_ node: Node<Self>) {
    node.view = self
    node.children[0].update(using: content.0)
    node.children[1].update(using: content.1)
    node.children[2].update(using: content.2)
    node.children[3].update(using: content.3)
    node.children[4].update(using: content.4)
    node.children[5].update(using: content.5)
    node.children[6].update(using: content.6)
  }
}

public struct TupleView8<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View>: View, PrimitiveView {
  public let content: (C0, C1, C2, C3, C4, C5, C6, C7)

  static var size: Int? {
    if let c0 = C0.size,
      let c1 = C1.size,
      let c2 = C2.size,
      let c3 = C3.size,
      let c4 = C4.size,
      let c5 = C5.size,
      let c6 = C6.size,
      let c7 = C7.size
    {
      return c0 + c1 + c2 + c3 + c4 + c5 + c6 + c7
    }
    return nil
  }

  func buildNode(_ node: Node<Self>) {
    node.addNode(at: 0, Node(view: content.0))
    node.addNode(at: 1, Node(view: content.1))
    node.addNode(at: 2, Node(view: content.2))
    node.addNode(at: 3, Node(view: content.3))
    node.addNode(at: 4, Node(view: content.4))
    node.addNode(at: 5, Node(view: content.5))
    node.addNode(at: 6, Node(view: content.6))
    node.addNode(at: 7, Node(view: content.7))
  }

  func updateNode(_ node: Node<Self>) {
    node.view = self
    node.children[0].update(using: content.0)
    node.children[1].update(using: content.1)
    node.children[2].update(using: content.2)
    node.children[3].update(using: content.3)
    node.children[4].update(using: content.4)
    node.children[5].update(using: content.5)
    node.children[6].update(using: content.6)
    node.children[7].update(using: content.7)
  }
}

public struct TupleView9<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View, C8: View>: View, PrimitiveView {
  public let content: (C0, C1, C2, C3, C4, C5, C6, C7, C8)

  static var size: Int? {
    if let c0 = C0.size,
      let c1 = C1.size,
      let c2 = C2.size,
      let c3 = C3.size,
      let c4 = C4.size,
      let c5 = C5.size,
      let c6 = C6.size,
      let c7 = C7.size,
      let c8 = C8.size
    {
      return c0 + c1 + c2 + c3 + c4 + c5 + c6 + c7 + c8
    }
    return nil
  }

  func buildNode(_ node: Node<Self>) {
    node.addNode(at: 0, Node(view: content.0))
    node.addNode(at: 1, Node(view: content.1))
    node.addNode(at: 2, Node(view: content.2))
    node.addNode(at: 3, Node(view: content.3))
    node.addNode(at: 4, Node(view: content.4))
    node.addNode(at: 5, Node(view: content.5))
    node.addNode(at: 6, Node(view: content.6))
    node.addNode(at: 7, Node(view: content.7))
    node.addNode(at: 8, Node(view: content.8))
  }

  func updateNode(_ node: Node<Self>) {
    node.view = self
    node.children[0].update(using: content.0)
    node.children[1].update(using: content.1)
    node.children[2].update(using: content.2)
    node.children[3].update(using: content.3)
    node.children[4].update(using: content.4)
    node.children[5].update(using: content.5)
    node.children[6].update(using: content.6)
    node.children[7].update(using: content.7)
    node.children[8].update(using: content.8)
  }
}

public struct TupleView10<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View, C8: View, C9: View>: View, PrimitiveView {
  public let content: (C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)

  static var size: Int? {
    if let c0 = C0.size,
      let c1 = C1.size,
      let c2 = C2.size,
      let c3 = C3.size,
      let c4 = C4.size,
      let c5 = C5.size,
      let c6 = C6.size,
      let c7 = C7.size,
      let c8 = C8.size,
      let c9 = C9.size
    {
      return c0 + c1 + c2 + c3 + c4 + c5 + c6 + c7 + c8 + c9
    }
    return nil
  }

  func buildNode(_ node: Node<Self>) {
    node.addNode(at: 0, Node(view: content.0))
    node.addNode(at: 1, Node(view: content.1))
    node.addNode(at: 2, Node(view: content.2))
    node.addNode(at: 3, Node(view: content.3))
    node.addNode(at: 4, Node(view: content.4))
    node.addNode(at: 5, Node(view: content.5))
    node.addNode(at: 6, Node(view: content.6))
    node.addNode(at: 7, Node(view: content.7))
    node.addNode(at: 8, Node(view: content.8))
    node.addNode(at: 9, Node(view: content.9))
  }

  func updateNode(_ node: Node<Self>) {
    node.view = self
    node.children[0].update(using: content.0)
    node.children[1].update(using: content.1)
    node.children[2].update(using: content.2)
    node.children[3].update(using: content.3)
    node.children[4].update(using: content.4)
    node.children[5].update(using: content.5)
    node.children[6].update(using: content.6)
    node.children[7].update(using: content.7)
    node.children[8].update(using: content.8)
    node.children[9].update(using: content.9)
  }
}
