// swift-tools-version:5.5
import PackageDescription

let package = Package(
  name: "cassandra-kit",
  platforms: [
    .macOS(.v11),
    .iOS(.v15),
    .tvOS(.v15),
    .watchOS(.v8),
  ],
  products: [
    .library(name: "CassandraKit", targets: ["CassandraKit"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-collections.git", from: "0.0.4"),
  ],
  targets: [
    .target(
      name: "CassandraKit",
      dependencies: ["CCassandraKit", .product(name: "OrderedCollections", package: "swift-collections")]
    ),
    .target(
      name: "CCassandraKit",
      dependencies: ["libcassandra", "libcrypto", "libssl", "libuv", "libz"]
    ),
    .binaryTarget(name: "libcassandra", path: "libcassandra.xcframework"),
    .binaryTarget(name: "libcrypto", path: "libcrypto.xcframework"),
    .binaryTarget(name: "libssl", path: "libssl.xcframework"),
    .binaryTarget(name: "libuv", path: "libuv.xcframework"),
    .binaryTarget(name: "libz", path: "libz.xcframework"),
    .testTarget(name: "CassandraKitTests", dependencies: ["CassandraKit"]),
  ]
)
