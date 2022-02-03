import Foundation
import CCassandraKit

/// A Cassandra cluster.
@available(macOS 11, iOS 15, tvOS 15, watchOS 8, *)
public class CassandraCluster {
  var cluster = cass_cluster_new()
  
  public var contactPoints: [String] = [] {
    willSet {
      cass_cluster_set_contact_points(cluster, "")
      newValue.forEach { cass_cluster_set_contact_points(cluster, $0) }
    }
  }
  
  public var randomizesContactPoints = Bool(truncating: NSNumber(value: CASS_DEFAULT_USE_RANDOMIZED_CONTACT_POINTS)) {
    willSet { cass_cluster_set_use_randomized_contact_points(cluster, newValue ? cass_true : cass_false) }
  }
  
  public var port: Int32? {
    willSet { cass_cluster_set_port(cluster, newValue ?? CASS_DEFAULT_PORT) }
  }
  
  public var localAddress: String? {
    willSet { cass_cluster_set_local_address(cluster, newValue ?? "") }
  }

  public var defaultConsistency: CassConsistency = CASS_CONSISTENCY_LOCAL_ONE {
    willSet { cass_cluster_set_consistency(cluster, newValue) }
  }

  public var defaultSerialConsistency: CassConsistency = CASS_CONSISTENCY_ANY {
    willSet { cass_cluster_set_serial_consistency(cluster, newValue) }
  }

  public var applicationName: String? {
    willSet { cass_cluster_set_application_name(cluster, newValue) }
  }
  
  public var applicationVersion: String? {
    willSet { cass_cluster_set_application_name(cluster, newValue) }
  }
  
  public var connectTimeout: UInt32? {
    willSet { cass_cluster_set_connect_timeout(cluster, newValue ?? UInt32(CASS_DEFAULT_CONNECT_TIMEOUT_MS)) }
  }

  public var requestTimeout: UInt32? {
    willSet { cass_cluster_set_request_timeout(cluster, newValue ?? UInt32(CASS_DEFAULT_REQUEST_TIMEOUT_MS)) }
  }

  public var resolveTimeout: UInt32? {
    willSet { cass_cluster_set_resolve_timeout(cluster, newValue ?? UInt32(CASS_DEFAULT_RESOLVE_TIMEOUT_MS)) }
  }
  
  public var username: String? {
    willSet { cass_cluster_set_credentials(cluster, newValue ?? "", password ?? "") }
  }

  public var password: String? {
    willSet { cass_cluster_set_credentials(cluster, username ?? "", newValue ?? "") }
  }
  
  public init(url: URL) {
    contactPoints = [url.host ?? "localhost"] // FIXME: why is willSet not called here‽ 😵‍💫
    cass_cluster_set_contact_points(cluster, url.host ?? "localhost")
    if let username = url.user { self.username = username }
    if let password = url.password { self.username = password }
    if let port = url.port { self.port = Int32(port) }
  }
  
  deinit {
    cass_cluster_free(cluster)
  }
}
