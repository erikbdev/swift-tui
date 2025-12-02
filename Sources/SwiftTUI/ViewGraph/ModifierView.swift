import Foundation

/// Modifies controls as they are passed to a container.
protocol ModifierView: PrimitiveView {
    func passControl(_ control: Control, node: ViewNode<Self>) -> Control
}
