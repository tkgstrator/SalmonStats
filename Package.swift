// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SalmonStats",
    platforms:  [
        .iOS(.v14), .macOS(.v10_15)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SalmonStats",
            targets: ["SalmonStats"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/tkgstrator/SplatNet2.git", from: "0.3.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SalmonStats",
            dependencies: ["SplatNet2"],
            resources: [.copy("Resources/coop.json")]
            ),
        .testTarget(
            name: "SalmonStatsTests",
            dependencies: ["SalmonStats", "SplatNet2"],
            resources: [.copy("Resources/coop.json")]
            )
    ]
)
