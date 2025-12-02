import Testing

@testable import SwiftTUI

@Suite
struct ViewBuildTests {
  @Test func vstack_TupleView2() throws {
    struct MyView: View {
      var body: some View {
        VStack {
          Text("One")
          Text("Two")
        }
      }
    }

    let control = try buildView(MyView())

    #expect(
      control.treeDescription == """
        → VStackControl
          → TextControl
          → TextControl
        """
    )
  }

  @Test func conditional_VStack() throws {
    struct MyView: View {
      @State var value = true

      var body: some View {
        if value {
          VStack {
            Text("One")
          }
        }
      }
    }

    let control = try buildView(MyView())

    #expect(
      control.treeDescription == """
        → VStackControl
          → TextControl
        """
    )
  }

  private func buildView<V: View>(_ view: V) throws -> Control {
    let node = ViewNode(view: VStack(content: view))
    node.build()
    return try #require(node.control?.children.first)
  }
}
