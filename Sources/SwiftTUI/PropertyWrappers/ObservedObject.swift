#if os(macOS)
  import Foundation
  import Combine

  @propertyWrapper
  public struct ObservedObject<T: ObservableObject>: AnyObservedObject, DynamicProperty, PrimitiveDynamicProperty {
    public let initialValue: T

    public init(initialValue: T) {
      self.initialValue = initialValue
    }

    public init(wrappedValue: T) {
      self.initialValue = wrappedValue
    }

    public var wrappedValue: T {
      initialValue
    }

    func subscribe(_ action: @escaping () -> Void) -> AnyCancellable {
      initialValue.objectWillChange.sink(receiveValue: { _ in action() })
    }
  }

  protocol AnyObservedObject {
    func subscribe(_ action: @escaping () -> Void) -> AnyCancellable
  }

#endif
