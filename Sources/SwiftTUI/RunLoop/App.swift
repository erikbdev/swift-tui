import Foundation

// The root of the application.
public protocol App: View {
  init()
}

extension App {
  public static func main() {
    let application = Application(rootView: Self())
    application.start()
  }
}
