import Foundation

public struct ForEach<Data, ID, Content>: View, PrimitiveView where Data : RandomAccessCollection, ID : Hashable, Content : View {
    public var data: Data
    public var content: (Data.Element) -> Content
    private var id: KeyPath<Data.Element, ID>

    public init(_ data: Data, @ViewBuilder content: @escaping (Data.Element) -> Content) where Data.Element: Identifiable, ID == Data.Element.ID {
        self.data = data
        self.content = content
        id = \.id
    }

    public init(_ data: Data, id: KeyPath<Data.Element, ID>, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.id = id
        self.content = content

    }

    static var size: Int? { nil }

    func buildNode(_ node: ViewNode<Self>) {
        let views: [Content] = data.map(content)
        for (i, view) in views.enumerated() {
            node.addNode(at: i, ViewNode(view: view))
        }
    }

    func updateNode(_ node: ViewNode<Self>) {
        let last = node.view
        node.view = self
        let diff = data.difference(from: last.data, by: { $0[keyPath: id] == $1[keyPath: last.id] })
        var needsUpdate = Set<Int>(0 ..< data.count)
        for change in diff {
            switch change {
            case .remove(let offset, _, _):
                node.removeNode(at: offset)
            case .insert(let offset, let element, _):
                node.addNode(at: offset, ViewNode(view: content(element)))
                needsUpdate.remove(offset)
            }
        }
        for i in needsUpdate {
            node.children[i].update(using: content(data[data.index(data.startIndex, offsetBy:i)]))
        }
    }
}
