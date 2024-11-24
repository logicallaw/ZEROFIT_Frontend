import 'package:flutter/material.dart';
import 'package:ma_app_zerofit/main.dart';
import 'package:provider/provider.dart';
import 'password_reset_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ma_app_zerofit/store.dart';

class AccountManagementScreen extends StatefulWidget {
  const AccountManagementScreen({super.key});

  @override
  State<AccountManagementScreen> createState() => _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<AccountManagementScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            '안녕',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(context.watch<Store1>().userEmail),
          const SizedBox(height: 20),
          const Divider(),
          ListTile(
            title: const Text('비밀번호 재설정'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PasswordResetScreen(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('공지'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // 다음 화면으로 이동
            },
          ),
          ListTile(
            title: const Text('가이드북'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // 다음 화면으로 이동
            },
          ),
          ListTile(
            title: const Text('개인정보 및 보안'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // 다음 화면으로 이동
            },
          ),
        ],
      ),
    );
  }
}
