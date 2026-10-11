// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MnemonicsCore",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [.library(name: "MnemonicsCore", targets: ["MnemonicsCore"])],
    targets: [
        .target(name: "MnemonicsCore"),
        .testTarget(name: "MnemonicsCoreTests", dependencies: ["MnemonicsCore"]),
    ]
)
