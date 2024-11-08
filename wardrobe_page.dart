import 'package:flutter/material.dart';

class WardrobePage extends StatelessWidget {
  const WardrobePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: const Text(
          '나의 옷장',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5DEB3),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: _buildDoor('반팔', Icons.sports_basketball)),
                    Expanded(child: _buildDoor('긴팔', Icons.dry_cleaning)),
                    Expanded(child: _buildDoor('반바지', Icons.crop_7_5)),
                    Expanded(child: _buildDoor('긴바지', Icons.straighten)),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: _buildDoor('신발', Icons.snowshoeing)),
                    Expanded(child: _buildDoor('외투', Icons.wallet)),
                    Expanded(child: _buildDoor('모자', Icons.face)),
                    Expanded(child: _buildDoor('악세사리', Icons.diamond)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoor(String category, IconData icon) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5DEB3),
        border: Border.all(
          color: const Color(0xFFDEB887),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(4),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFF5DEB3),
            Color(0xFFDEB887),
            Color(0xFFF5DEB3),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 문 손잡이
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            width: 30,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFFCD853F),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          // 아이콘
          Icon(
            icon,
            size: 40,
            color: const Color(0xFF8B4513),
          ),
          const SizedBox(height: 12),
          // 카테고리 텍스트
          Text(
            category,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8B4513),
            ),
          ),
          // 아이템 개수
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF8B4513).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '0개',
              style: TextStyle(
                color: Color(0xFF8B4513),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // 나무 결 효과
          Expanded(
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 8,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  height: 1,
                  color: const Color(0xFFDEB887).withOpacity(0.3),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
