import Foundation
import CCassandraKit
import OrderedCollections

/// A Cassandra session.
@available(macOS 11, iOS 15, tvOS 15, watchOS 8, *)
public class CassandraSession {
  var session = cass_session_new()
  var cluster: CassandraCluster
  var connect_future: OpaquePointer!
  
  /// Creates a new Cassandra session for the specified cluster.
  public init(cluster: CassandraCluster) {
    self.cluster = cluster
  }
  
  deinit {
    cass_future_free(connect_future)
    cass_session_free(session)
  }
  
  /// Connects the session to the cluster.
  public func connect() throws {
    connect_future = cass_session_connect(session, cluster.cluster)
    if cass_future_error_code(connect_future) != CASS_OK {
      var message_pointer: UnsafePointer<CChar>? = nil
      var message_length: Int = 0
      let code = cass_future_error_code(connect_future)
      cass_future_error_message(connect_future, &message_pointer, &message_length)
      let message = String(cString: message_pointer!)
      //print("[CassandraClient] connect error: " + message)
      throw CassandraError(code: code, message: message)
    }
  }
  
  // TODO: split this up
  /// Executes a CQL statement and returns the result.
  public func execute(_ statementSource: String) throws -> [OrderedDictionary<String, Any?>] {
    var dictionaries = [OrderedDictionary<String, Any?>]()
    let statement = cass_statement_new(statementSource, 0)
    let result_future = cass_session_execute(session, statement)
    
    if cass_future_error_code(result_future) == CASS_OK {
      let result = cass_future_get_result(result_future)
      //          let row = cass_result_first_row(result)
      //      print(cass_result_row_count(result))
      //      print(cass_result_column_count(result))
      
      let iterator = cass_iterator_from_result(result)
      while cass_iterator_next(iterator) == cass_true {
        var dictionary = OrderedDictionary<String, Any?>()
        
        let row = cass_iterator_get_row(iterator)
        let column_iterator = cass_iterator_from_row(row)
        var column_index = 0
        while cass_iterator_next(column_iterator) == cass_true {
          let column = cass_iterator_get_column(column_iterator)
          let column_type = cass_result_column_type(result, column_index)
          
          //          print(column_type)
          
          var name_pointer: UnsafePointer<CChar>? = nil
          var name_length: Int = 0
          //          cass_column_meta_name(column_meta, &name_pointer, &name_length)
          cass_result_column_name(result, column_index, &name_pointer, &name_length)
          let name = String(cString: name_pointer!)
          //          print(name)
          
          var value: AnyObject? = nil
          switch column_type {
          case .blob:
            var value_pointer: UnsafePointer<cass_byte_t>? = nil
            var value_length: Int = 0
            cass_value_get_bytes(column, &value_pointer, &value_length)
            value = Data(bytes: value_pointer!, count: value_length) as AnyObject
            
          case .boolean:
            var value_pointer: cass_bool_t = cass_false
            cass_value_get_bool(column, &value_pointer)
            value = Bool(value_pointer == cass_true) as AnyObject
            
          case .double:
            var value_pointer: Double = 0
            cass_value_get_double(column, &value_pointer)
            value = value_pointer as AnyObject
            
          case .float:
            var value_pointer: Float = 0
            cass_value_get_float(column, &value_pointer)
            value = value_pointer as AnyObject
            
          case .int:
            var value_pointer: Int32 = 0
            cass_value_get_int32(column, &value_pointer)
            //            print(value_pointer)
            value = value_pointer as AnyObject
            
          case .smallint, .tinyint:
            var value_pointer: Int64 = 0
            cass_value_get_int64(column, &value_pointer)
            //            print(value_pointer)
            value = value_pointer as AnyObject
            
          case .text, .varchar, .inet:
            var value_pointer: UnsafePointer<CChar>? = nil
            var value_length: Int = 0
            cass_value_get_string(column, &value_pointer, &value_length)
            value = String(cString: value_pointer!) as AnyObject
            
          case .uuid, .timeuuid:
            var uuid = CassUuid()
            cass_value_get_uuid(column, &uuid)
            var data = Data(capacity: Int(CASS_UUID_STRING_LENGTH))
            data.withUnsafeMutableBytes { cass_uuid_string(uuid, $0) }
            //            print(data.withUnsafeBytes { NSUUID(uuidBytes: $0) })
            //            print(data.withUnsafeBytes { NSUUID(uuidBytes: $0) } as UUID)
            value = data.withUnsafeBytes { NSUUID(uuidBytes: $0) } as AnyObject
            
            //          case .date:
            //            cass_value_get_
            
          case .date:
            var output: UInt32 = 0
            cass_value_get_uint32(column, &output)
            let timestamp = cass_date_time_to_epoch(output, 0)
            value = Date(timeIntervalSince1970: TimeInterval(timestamp)) as AnyObject
            
          case .time:
            break
            
          case .duration:
            //            break
            var months: Int32 = 0
            var days: Int32 = 0
            var nanoseconds: Int64 = 0
            cass_value_get_duration(column, &months, &days, &nanoseconds)
            value = DateComponents(month: Int(months), day: Int(days), nanosecond: Int(nanoseconds)) as AnyObject
            
          case .list:
            cass_iterator_from_collection(column)
            
          case .map:
            cass_iterator_from_map(column)
            
          case .set:
            cass_iterator_from_collection(column)
            
          case .udt:
            let column_data_type = cass_result_column_data_type(result, column_index)
            var type_name_pointer: UnsafePointer<CChar>? = nil
            var type_name_length: Int = 0
            // cass_column_meta_type_name(column_meta, &type_name_pointer, &type_name_length)
            cass_data_type_type_name(column_data_type, &type_name_pointer, &type_name_length)
            let _ = String(cString: type_name_pointer!)
            // print(type_name)
            
          case .tuple:
            cass_iterator_from_tuple(column)
            
            //            var value_pointer: UnsafePointer<CChar>? = nil
            //            var value_length: Int = 0
            //            cass_value_get_string(column, &value_pointer, &value_length)
            //            value = String(cString: value_pointer!) as AnyObject
            
          default:
            break
          }
          
          dictionary[name] = value
          column_index += 1
        }
        
        cass_iterator_free(column_iterator)
        
        dictionaries.append(dictionary)
        //        let column = cass_row_get_column_by_name(row, "keyspace_name")
        //        var value_pointer: UnsafePointer<CChar>? = nil
        //        var value_length: Int = 0
        //        cass_value_get_string(column, &value_pointer, &value_length)
        //        let value = String(cString: value_pointer!)
        //        print("keyspace_name: " + value)
        //        dictionaries.append(dictionary)
      }
      
      cass_iterator_free(iterator)
      cass_result_free(result)
    } else {
      var message_pointer: UnsafePointer<CChar>? = nil
      var message_length: Int = 0
      cass_future_error_message(result_future, &message_pointer, &message_length)
      let message = String(cString: message_pointer!)
      print("query error: " + message)
    }
    
    cass_statement_free(statement)
    cass_future_free(result_future)
    
    return dictionaries
  }
}
