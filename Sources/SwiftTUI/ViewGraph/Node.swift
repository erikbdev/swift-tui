import Foundation

#if os(macOS)
  import Combine
#endif

protocol AnyNode: AnyObject {
  var parent: AnyNode? { get set }
  var children: [AnyNode] { get }
  var application: Application? { get set }
  var control: Control? { get set }

  var size: Int { get }
  var offset: Int { get }
  var index: Int { get set }

  var state: [String: Any] { get set }
  var environment: ((inout EnvironmentValues) -> Void)? { get set }

  func control(at offset: Int) -> Control
  func build()
  func invalidate()
}

extension AnyNode {
  var root: AnyNode { parent?.root ?? self }
}

extension AnyNode {
  func update<T: View>(using view: T) {
    build()

    guard let node = self as? Node<T> else {
      log("AnyNode cast not accurate. Expected: \(Node<T>.self), got: \(Self.self)")
      return
    }
    view.updateNode(node)
  }
}

/// The node of a view graph.
///
/// The view graph is the runtime representation of the views in an application.
/// Every view corresponds to a node. If a view is used in multiple places, in
/// each of the places it is used it will have a seperate node.
///
/// Once (a part of) the node tree is built, views can update the node tree, as
/// long as their type match. This is done by the views themselves.
///
/// Note that the control tree more closely resembles the layout hierarchy,
/// because structural views (ForEach, etc.) have their own node.
final class Node<T: View>: AnyNode {
  var view: T

  // TODO: Use Reflection API
  var properties: [Int: Any] = [:]
  var state: [String: Any] = [:]
  var environment: ((inout EnvironmentValues) -> Void)?
  #if os(macOS)
    var subscriptions: [String: AnyCancellable] = [:]
  #endif

  var control: Control?
  weak var application: Application?

  /// For modifiers only, references to the controls
  var controls: WeakSet<Control>?

  weak var parent: AnyNode?
  var children: [AnyNode] = []
  var index: Int = 0

  private(set) var built = false

  init(view: T) {
    self.view = view
  }

  func invalidate() {
    build()
    view.updateNode(self)
  }

  /// The total number of controls in the node.
  /// The node does not need to be fully built for the size to be computed.
  var size: Int {
    if let size = T.size { return size }
    build()
    return children.map(\.size).reduce(0, +)
  }

  /// The number of controls in the parent node _before_ the current node.
  var offset: Int {
    var offset = 0
    for i in 0..<index {
      offset += parent?.children[i].size ?? 0
    }
    return offset
  }

  func build() {
    if !built {
      self.view.buildNode(self)
      built = true
      if !(view is OptionalView), let container = view as? (any LayoutRootView) {
        func _loadData<L: LayoutRootView>(_ container: L) {
          container.loadData(node: unsafeDowncast(self, to: Node<L>.self))
        }
        _loadData(container)
      }
    }
  }

  // MARK: - Changing nodes

  func addNode<S>(at index: Int, _ node: Node<S>) {
    guard node.parent == nil else { 
      log("Node is already in tree"); 
      return 
    }
    children.insert(node, at: index)
    node.parent = self
    for i in index..<children.count {
      children[i].index = i
    }
    if built {
      for i in 0..<node.size {
        insertControl(at: node.offset + i)
      }
    }
  }

  func removeNode(at index: Int) {
    if built {
      for i in (0..<children[index].size).reversed() {
        removeControl(at: children[index].offset + i)
      }
    }
    children[index].parent = nil
    children.remove(at: index)
    for i in index..<children.count {
      children[i].index = i
    }
  }

  // MARK: - Container data source

  func control(at offset: Int) -> Control {
    build()
    if offset == 0, let control = self.control { return control }
    var i = 0
    for child in children {
      let size = child.size
      if (offset - i) < size {
        let control = child.control(at: offset - i)
        if !(view is OptionalView), let modifier = self.view as? any ModifierView {
          func _passControl<M: ModifierView>(_ modifier: M) -> Control {
            modifier.passControl(control, node: unsafeDowncast(self, to: Node<M>.self))
          }
          return _passControl(modifier)
        }
        return control
      }
      i += size
    }
    fatalError("Out of bounds")
  }

  // MARK: - Container changes

  fileprivate func insertControl(at offset: Int) {
    if !(view is OptionalView), let container = view as? any LayoutRootView {
      func _insertControl<L: LayoutRootView>(_ container: L) {
        container.insertControl(at: offset, node: unsafeDowncast(self, to: Node<L>.self))
      }
      return _insertControl(container)
    }

    (parent as? _NodeLayoutRootView)?.insertControl(at: offset + self.offset)
  }

  fileprivate func removeControl(at offset: Int) {
    if !(view is OptionalView), let container = view as? any LayoutRootView {
      func _removeControl<L: LayoutRootView>(_ container: L) {
        container.removeControl(at: offset, node: unsafeDowncast(self, to: Node<L>.self))
      }
      _removeControl(container)
    }
    (parent as? _NodeLayoutRootView)?.removeControl(at: offset + self.offset)
  }
}


private protocol _NodeLayoutRootView {
  func insertControl(at offset: Int)
  func removeControl(at offset: Int)
}

extension Node: _NodeLayoutRootView where T: LayoutRootView {}
