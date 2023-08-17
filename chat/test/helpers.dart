import 'package:rethink_db_ns/rethink_db_ns.dart';

Future<void> createDb(RethinkDb r, Connection connection) async {
  //create db
  await r.dbCreate('test').run(connection).catchError((err) => {});
  //create table
  await r
      .db('test')
      .tableCreate('users')
      .run(connection)
      .catchError((err) => {});
}

Future<void> cleanDb(RethinkDb r, Connection connection) async {
  await r
      .table('users')
      .delete()
      .run(connection)
      .catchError((err) => {print(err)});
}
