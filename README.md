# CassandraKit (🚧 Work in Progress 🚧)

Proof of concept prototype of an Apache Cassandra client library for Apple platforms.


## Installation

```swift
.package(url: "https://github.com/database-utility/cassandra-kit.git", branch: "main")
```

```swift
import CassandraKit
```


## Usage

```swift
let session = CassandraSession(cluster: CassandraCluster(url: "cassandra://localhost"))
try session.connect()

let keyspaces = try session.execute("select * from system_schema.keyspaces")
print(keyspaces as NSArray)
```


## Acknowledgements

Uses [DataStax C/C++ Driver](https://docs.datastax.com/en/developer/cpp-driver/2.16/).

