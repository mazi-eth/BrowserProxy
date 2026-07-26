// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BrowserProxy",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "BrowserProxy", targets: ["BrowserProxy"])
    ],
    targets: [
        .executableTarget(
            name: "BrowserProxy",
            swiftSettings: [
                .unsafeFlags(["-Osize"])
            ],
            linkerSettings: [
                .unsafeFlags(["-Xlinker", "-S", "-Xlinker", "-dead_strip"])
            ]
        )
    ]
)
