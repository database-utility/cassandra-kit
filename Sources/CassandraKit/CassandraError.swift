import Foundation
import CCassandraKit

/// A Cassandra error.
@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
public struct CassandraError: LocalizedError {
  let code: CassError
  let message: String
  //  init(code: CassError, message: String) {}
}
