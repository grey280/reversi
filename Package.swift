// swift-tools-version:5.2
import PackageDescription

var dependencies: [Package.Dependency] = [
    // 💧 A server-side Swift web framework.
    .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0-rc"),
    .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0-rc"),
    .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0-rc"),
    .package(url: "https://github.com/vapor/leaf.git", from: "4.0.0-rc"),
    .package(name: "Ink", url: "https://github.com/johnsundell/ink.git", from: "0.1.0"),
]
var targetDependencies: [Target.Dependency] = [
    .product(name: "Fluent", package: "fluent"),
    .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
    .product(name: "Vapor", package: "vapor"),
    .product(name: "Leaf", package: "leaf"),
    "Ink"
]

//#if os(Linux)
dependencies.append(.package(name: "OpenCombine", url: "https://github.com/broadwaylamb/OpenCombine.git", from: "0.8.0"))
targetDependencies.append("OpenCombine")
//#endif

let package = Package(
    name: "reversi",
    platforms: [
       .macOS(.v10_15)
    ],
    dependencies: dependencies,
    targets: [
        .target(name: "App", dependencies: targetDependencies),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),
        ])
    ]
)
