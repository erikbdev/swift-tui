// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "ToDoList",
    platforms: [
        .macOS(.v11)
    ],
    dependencies: [
        .package(name: "SwiftTUI", path: "../../")
    ],
    targets: [
        .executableTarget(
            name: "ToDoList",
            dependencies: ["SwiftTUI"], 
            path: "Sources"
        ),
        .testTarget(
            name: "ToDoListTests",
            dependencies: ["ToDoList"]),
    ]
)
