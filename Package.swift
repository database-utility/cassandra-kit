// swift-tools-version:5.3
import PackageDescription

let package = Package(
  name: "libcassandra",
  platforms: [
    .macOS(.v11),
    .iOS(.v14),
    .watchOS(.v7),
    .tvOS(.v14),
  ],
  products: [
    .library(name: "libcassandra", targets: ["libcassandra"]),
  ],
  targets: [
    .binaryTarget(name: "libcassandra", path: "libcassandra.xcframework"),
  ]
)
