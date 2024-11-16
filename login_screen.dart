import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'find_password_screen.dart';
import 'main_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isChecked = false;

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
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
                  decoration: InputDecoration(
                    hintText: 'Dosamarvis@gmail.com',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('비밀번호', style: TextStyle(color: Colors.grey)),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: '••••••••',
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
                    onPressed: () {
                      // 로그인 버튼 클릭 시 MainHomeScreen으로 이동
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MainHomeScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB1B1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text('로그인'),
                  ),
                ),
                const SizedBox(height: 20),
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
                  decoration: InputDecoration(
                    hintText: '신민희',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('이메일 주소', style: TextStyle(color: Colors.grey)),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'name@email.com',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('비밀번호 (8자 이상)',
                    style: TextStyle(color: Colors.grey)),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: '비밀번호를 입력해주세요.',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: const Icon(Icons.visibility_off),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: '비밀번호 확인',
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
                  decoration: InputDecoration(
                    hintText: '의류 거래를 원하시는 주소를 입력해주세요.',
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
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB1B1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text('회원가입'),
                  ),
                ),
                const SizedBox(height: 20),
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
