import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'find_password_screen.dart';
import 'main_home_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_service.dart';
import '../storage/user_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ma_app_zerofit/store.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isChecked = false;
  final ApiService _apiService = ApiService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordCheckController = TextEditingController();
  String _responseMessage = '';
  late final nodeUrl;

  Future<void> _signup() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
    final address = _addressController.text.trim();
    final password_check = _passwordCheckController.text.trim();

    if (email.isEmpty || password.isEmpty  || name.isEmpty || address.isEmpty || password_check.isEmpty) {
      setState(() {
        _responseMessage = '빈 공간을 채워주세요!';
      });
      return;
    }

    if(password.length < 8){
      setState(() {
        _responseMessage = '비밀번호가 너무 짧습니다.';
      });
      return;
    }

    if(password != password_check){
      setState(() {
        _responseMessage = '비밀번호가 같지 않습니다.';
      });
      return;
    }

    final result = await _apiService.signup(
      email: email,
      password: password,
      phoneNumber: "010",
      name: name,
      gender: "male",
      nickname: "noname",
      address: address,
      payment: null,
    );

    setState(() {
      _responseMessage = result;
    });
  }



  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _responseMessage = '이메일과 비밀번호를 입력해주세요!';
      });
      return;
    }

    // Node.js 서버로 로그인 요청
    final response = await _apiService.sendLoginRequest(email, password);

    setState(() {
      if(response['status']) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MainHomeScreen(),
          ),
        );
      }
      context.read<Store1>().saveUserEmail('subEmail');
      _responseMessage = response['message'];
    });
  }



  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        
        centerTitle: true,
        title: const Text(
          '여정준비',
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: ClipOval(
                child: Image.network(
                  'https://via.placeholder.com/32',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.person_outline,
                      color: Colors.grey,
                      size: 20,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.black,
          tabs: const [
            Tab(text: '로그인'),
            Tab(text: '회원가입'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 로그인 탭
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('이메일 주소', style: TextStyle(color: Colors.grey)),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Dosamarvis@gmail.com',
                    hintStyle: TextStyle(color:Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('비밀번호', style: TextStyle(color: Colors.grey)),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    hintStyle: TextStyle(color:Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FindPasswordScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    '비밀번호가 기억이 안 나요!',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text('로그인', style: TextStyle(color: Colors.white),),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    _responseMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),

          // 회원가입 탭
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('이름', style: TextStyle(color: Colors.grey)),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: '신민희',
                    hintStyle: TextStyle(color:Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('이메일 주소', style: TextStyle(color: Colors.grey)),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'name@email.com',
                    hintStyle: TextStyle(color:Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('비밀번호 (8자 이상)',
                    style: TextStyle(color: Colors.grey)),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: '비밀번호를 입력해주세요.',
                    hintStyle: TextStyle(color:Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: const Icon(Icons.visibility_off),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordCheckController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: '비밀번호 확인',
                    hintStyle: TextStyle(color:Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: const Icon(Icons.visibility_off),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('주소 입력(직거래, 택배 거래를 위한 정보 수집)',
                    style: TextStyle(color: Colors.grey)),
                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    hintText: '의류 거래를 원하시는 주소를 입력해주세요.',
                    hintStyle: TextStyle(color:Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isChecked = !isChecked; // 현재 상태의 반대값으로 토글
                    });
                  },
                  child: Row(
                    children: [
                      Checkbox(
                        value: isChecked,
                        onChanged: (value) {
                          setState(() {
                            isChecked = value ?? false;
                          });
                        },
                      ),
                      const Expanded(
                        child: Text('이용약관 및 개인정보 처리 방침에 동의 합니다.'),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _signup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text('회원가입' , style: TextStyle(color: Colors.white),),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    _responseMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
