import "package:flutter_secure_storage/flutter_secure_storage.dart";

class UserStorage {
  final _storage = FlutterSecureStorage();

  // 사용자 정보 저장
  Future<void> saveUserInfo(Map<String, dynamic> userInfo) async {
    await _storage.write(key: 'userId', value: userInfo['id'].toString());
    await _storage.write(key: 'email', value: userInfo['email']);
    await _storage.write(key: 'name', value: userInfo['name']);
    await _storage.write(key: 'authToken', value: userInfo['token']);
  }

  // 사용자 정보 가져오기
  Future<Map<String, String?>> getUserInfo() async {
    final userId = await _storage.read(key: 'userId');
    final email = await _storage.read(key: 'email');
    final name = await _storage.read(key: 'name');
    final authToken = await _storage.read(key: 'authToken');

    return {
      'userId': userId,
      'email': email,
      'name': name,
      'authToken': authToken,
    };
  }

  // 사용자 정보 삭제
  Future<void> clearUserInfo() async {
    await _storage.deleteAll();
  }
}