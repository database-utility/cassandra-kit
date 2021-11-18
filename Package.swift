// swift-tools-version:5.5
import PackageDescription

let package = Package(
  name: "libcassandra",
  platforms: [
    .macOS(.v12),
    .iOS(.v15),
    .watchOS(.v8),
    .tvOS(.v15),
  ],
  products: [
    .library(name: "CCassandra", targets: ["CCassandra"]),
    .library(name: "libcassandra", targets: ["libcassandra"]),
  ],
  targets: [
    .target(name: "CCassandra", dependencies: ["libcassandra"]),
    .binaryTarget(name: "libcassandra", path: "Sources/libcassandra/libcassandra.xcframework"),
  ]
)
