// swift-tools-version:5.5
import PackageDescription

let package = Package(
  name: "cassandra-kit",
  platforms: [
    .macOS(.v12),
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
      dependencies: [
        "CCassandraKit",
        .product(name: "OrderedCollections", package: "swift-collections"),
      ]
    ),
    .testTarget(
      name: "CassandraKitTests",
      dependencies: ["CassandraKit"]
    ),
    .target(
      name: "CCassandraKit",
      dependencies: ["libcassandra"],
      linkerSettings: [
        .unsafeFlags([
          "-L/usr/local/opt/openssl/lib",
          "-L/usr/local/opt/libuv/lib"
        ]),
        .linkedLibrary("ssl"),
        .linkedLibrary("crypto"),
        .linkedLibrary("z"),
        .linkedLibrary("uv"),
      ]
    ),
    .binaryTarget(
      name: "libcassandra",
      path: "libcassandra.xcframework"
    ),
  ]
)
