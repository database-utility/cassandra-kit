import XCTest
@testable import CassandraKit

private final class CassandraKitTests: XCTestCase {
  func testConnection() async throws {
    let session = CassandraSession()
    try await session.connect()
  }
  
  func testExecution() async throws {
    let session = CassandraSession()
    try await session.connect()
    let keyspaces = try session.execute("select * from system_schema.keyspaces")
    XCTAssertTrue(keyspaces.contains { $0["keyspace_name"] as! String == "system" })
  }
}
