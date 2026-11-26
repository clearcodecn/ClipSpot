// swift-tools-version: 5.9
import PackageDescription
let package = Package(name: "ClipSpot", platforms: [.macOS(.v13)], targets: [.executableTarget(name: "ClipSpot"), .testTarget(name: "ClipSpotTests", dependencies: ["ClipSpot"])])
