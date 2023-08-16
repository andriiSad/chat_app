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
    expect(userWithId.id, isNotEmpty);
  });

  test('get online users', () async {
    final user = User(
      username: 'test',
      photoUrl: 'url',
      active: true,
      lastSeen: DateTime.now(),
    );
    //arrange
    await sut.connect(user);
    //act
    final users = await sut.online();
    //assert
    expect(users.length, 1);
  });

  // test('disconnects a user', () async {
  //   final user = User(
  //     username: 'test',
  //     photoUrl: 'url',
  //     active: true,
  //     lastSeen: DateTime.now(),
  //   );

  //   // arrange
  //   final connectedUser = await sut.connect(user);

  //   // act
  //   await sut.disconnect(connectedUser);

  //   // try to fetch the disconnected user
  //   final users = await sut.online();

  //   // assert
  //   expect(users.length, 0);
  // });
}
