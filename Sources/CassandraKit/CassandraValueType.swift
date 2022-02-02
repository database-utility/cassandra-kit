import CCassandraKit

typealias CassandraValueType = CassValueType_

public extension CassandraValueType {
  static var custom: Self { .init(0x0000) }
  static var ascii: Self { .init(0x0001) } // org.apache.cassandra.db.marshal.AsciiType
  static var bigint: Self { .init(0x0002) } // org.apache.cassandra.db.marshal.LongType
  static var blob: Self { .init(0x0003) } // org.apache.cassandra.db.marshal.BytesType
  static var boolean: Self { .init(0x0004) } // org.apache.cassandra.db.marshal.BooleanType
  static var counter: Self { .init(0x0005) } // org.apache.cassandra.db.marshal.CounterColumnType
  static var decimal: Self { .init(0x0006) } // org.apache.cassandra.db.marshal.DecimalType
  static var double: Self { .init(0x0007) } // org.apache.cassandra.db.marshal.DoubleType
  static var float: Self { .init(0x0008) } // org.apache.cassandra.db.marshal.FloatType
  static var int: Self { .init(0x0009) } // org.apache.cassandra.db.marshal.Int32Type
  static var text: Self { .init(0x000A) } // org.apache.cassandra.db.marshal.UTF8Type
  static var timestamp: Self { .init(0x000B) } // org.apache.cassandra.db.marshal.TimestampType
  static var uuid: Self { .init(0x000C) } // org.apache.cassandra.db.marshal.UUIDType
  static var varchar: Self { .init(0x000D) }
  static var varint: Self { .init(0x000E) } // org.apache.cassandra.db.marshal.IntegerType
  static var timeuuid: Self { .init(0x000F) } // org.apache.cassandra.db.marshal.TimeUUIDType
  static var inet: Self { .init(0x0010) } // org.apache.cassandra.db.marshal.InetAddressType
  static var date: Self { .init(0x0011) } // org.apache.cassandra.db.marshal.SimpleDateType
  static var time: Self { .init(0x0012) } // org.apache.cassandra.db.marshal.TimeType
  static var smallint: Self { .init(0x0013) } // org.apache.cassandra.db.marshal.ShortType
  static var tinyint: Self { .init(0x0014) } // org.apache.cassandra.db.marshal.ByteType
  static var duration: Self { .init(0x0015) } // org.apache.cassandra.db.marshal.DurationType
  static var list: Self { .init(0x0020) } // org.apache.cassandra.db.marshal.ListType
  static var map: Self { .init(0x0021) } // org.apache.cassandra.db.marshal.MapType
  static var set: Self { .init(0x0022) } // org.apache.cassandra.db.marshal.SetType
  static var udt: Self { .init(0x0030) }
  static var tuple: Self { .init(0x0031) } // org.apache.cassandra.db.marshal.TupleType

  var typeName: String {
    switch self {
    case .custom: return "custom"
    case .ascii: return "ascii"
    case .bigint: return "bigint"
    case .blob: return "blob"
    case .boolean: return "boolean"
    case .counter: return "counter"
    case .decimal: return "decimal"
    case .double: return "double"
    case .float: return "float"
    case .int: return "int"
    case .text: return "text"
    case .timestamp: return "timestamp"
    case .uuid: return "uuid"
    case .varchar: return "varchar"
    case .varint: return "varint"
    case .timeuuid: return "timeuuid"
    case .inet: return "inet"
    case .date: return "date"
    case .time: return "time"
    case .smallint: return "smallint"
    case .tinyint: return "tinyint"
    case .duration: return "duration"
    case .list: return "list"
    case .map: return "map"
    case .set: return "set"
    case .udt: return "udt"
    case .tuple: return "tuple"
    default: return "unknown_type_\(rawValue)"
    }
  }
}

extension CassandraValueType: CustomStringConvertible {
  public var description: String { "CassandraValueType(\(typeName))" }
  // public var debugDescription: String { "CassandraValueType(\(typeName))" }
}
