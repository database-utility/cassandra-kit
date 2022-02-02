import XCTest
@testable import CassandraKit

private final class CassandraKitTests: XCTestCase {
  func testConnection() throws {
    let session = CassandraSession()
    try session.connect()
  }
  
  func testExecution() throws {
    let session = CassandraSession()
    try session.connect()
    let keyspaces = try session.execute("select * from system_schema.keyspaces")
    XCTAssertTrue(keyspaces.contains { $0["keyspace_name"] as! String == "system" })
  }
}
