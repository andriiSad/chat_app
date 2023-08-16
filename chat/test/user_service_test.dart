import 'package:chat/src/models/user.dart';
import 'package:chat/src/services/user_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

import 'helpers.dart';

void main() {
  final RethinkDb r = RethinkDb();
  late Connection connection;
  late UserService sut;

  setUp(() async {
    connection = await r.connect(host: '127.0.0.1');
    await createDb(r, connection);
    sut = UserService(r, connection);
  });

  tearDown(() async {
    await cleanDb(r, connection);
  });

  test('creates a new user document in database', () async {
    final user = User(
      username: 'test',
      photoUrl: 'url',
      active: true,
      lastSeen: DateTime.now(),
    );
    final userWithId = await sut.connect(user);
    print(userWithId.id);
    expect(userWithId.id, isNotEmpty);
  });
}
