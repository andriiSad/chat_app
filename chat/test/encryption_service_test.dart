import 'package:chat/src/services/encryption/encryption_service_contract.dart';
import 'package:chat/src/services/encryption/encryption_service_impl.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Key key;
  late Encrypter encrypter;
  late IEncryptionService encryptionService;
  const originalText = 'Hello, this is a test!';
  final base64 = RegExp(
      r'^(?:[A-Za-z0-9+\/]{4})*(?:[A-Za-z0-9+\/]{2}=|[A-Za-z0-9+\/]{3}=|[A-Za-z0-9+\/]{4})$');

  setUp(() {
    key = Key.fromLength(32);
    encrypter = Encrypter(AES(key));
    encryptionService = EncryptionService(encrypter);
  });

  test('Encryption Test', () {
    final encryptedText = encryptionService.encrypt(originalText);
    expect(base64.hasMatch(encryptedText), true);
  });

  test('Decryption Test', () {
    final encryptedText = encryptionService.encrypt(originalText);
    final decryptedText = encryptionService.decrypt(encryptedText);

    expect(decryptedText, originalText);
  });
}
