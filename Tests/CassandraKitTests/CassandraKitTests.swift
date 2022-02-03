import XCTest
@testable import CassandraKit

private final class CassandraKitTests: XCTestCase {
  let url = URL(string: "cassandra://localhost")!
  let urlWithInvalidHost = URL(string: "cassandra://invalid")!
  let urlWithInvalidPassword = URL(string: "cassandra://:invalid@")!

  func testConnection() throws {
    let session = CassandraSession(cluster: CassandraCluster(url: url))
    try session.connect()
  }
  
  func testConnectionWithInvalidHost() throws {
    let session = CassandraSession(cluster: CassandraCluster(url: urlWithInvalidHost))
    XCTAssertThrowsError(try session.connect())
  }
  
  func testConnectionWithInvalidPassword() throws {
    let session = CassandraSession(cluster: CassandraCluster(url: urlWithInvalidPassword))
    XCTAssertThrowsError(try session.connect())
  }

  func testExecution() throws {
    let session = CassandraSession(cluster: CassandraCluster(url: url))
    try session.connect()
    
    let keyspaces = try session.execute("select * from system_schema.keyspaces")
    print(keyspaces as NSArray)
    XCTAssertTrue(keyspaces.contains { $0["keyspace_name"] as! String == "system" })
  }
}
