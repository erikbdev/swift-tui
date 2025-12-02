import Foundation

public struct EmptyView: View, PrimitiveView {
    public init() {}

    static var size: Int? { 0 }
    
    func buildNode(_ node: ViewNode<Self>) {}

    func updateNode(_ node: ViewNode<Self>) {}
}
