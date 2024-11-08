import 'package:flutter/material.dart';

class SwipePage extends StatefulWidget {
  const SwipePage({super.key});

  @override
  State<SwipePage> createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage> {
  // 임시 데이터 (나중에 백엔드 API로 대체)
  final List<Map<String, String>> clothes = [
    {
      'name': '무신사 오버핏 맨투맨',
      'size': 'L',
      'price': '35,000원',
      'condition': '새상품',
      'description': '한번도 착용하지 않은 새상품입니다.',
    },
    {
      'name': '나이키 후드티',
      'size': 'M',
      'price': '45,000원',
      'condition': '중고',
      'description': '몇번 착용했지만 상태 좋습니다.',
    },
    // 더 많은 테스트 데이터...
  ];

  int currentIndex = 0;

  void nextItem() {
    if (currentIndex < clothes.length - 1) {
      setState(() {
        currentIndex++;
      });
    }
  }

  void previousItem() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1DA1F2),
        elevation: 0,
        title: const Text('ZEROFIT', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // 메인 카드
                Center(
                  child: GestureDetector(
                    onHorizontalDragEnd: (details) {
                      if (details.primaryVelocity! > 0) {
                        previousItem();
                      } else if (details.primaryVelocity! < 0) {
                        nextItem();
                      }
                    },
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 3,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // 임시 이미지 컨테이너 (나중에 백엔드 이미지로 대체)
                            Expanded(
                              flex: 4,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(10),
                                  ),
                                ),
                                child: const Center(
                                  child: Text('상품 이미지'),
                                ),
                              ),
                            ),
                            // 상품 정보
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      clothes[currentIndex]['name']!,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        _buildInfoChip(
                                            '사이즈: ${clothes[currentIndex]['size']}'),
                                        const SizedBox(width: 8),
                                        _buildInfoChip(
                                            '상태: ${clothes[currentIndex]['condition']}'),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      clothes[currentIndex]['price']!,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1DA1F2),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // 좌우 화살표 버튼
                if (currentIndex > 0)
                  Positioned(
                    left: 16,
                    top: MediaQuery.of(context).size.height / 3,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: previousItem,
                      color: Colors.grey[600],
                    ),
                  ),
                if (currentIndex < clothes.length - 1)
                  Positioned(
                    right: 16,
                    top: MediaQuery.of(context).size.height / 3,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward_ios),
                      onPressed: nextItem,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          // 하단 버튼
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(Icons.close, Colors.red, nextItem),
                _buildActionButton(Icons.favorite, Colors.green, () {
                  // 상세 페이지로 이동 로직
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1DA1F2).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF1DA1F2),
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildActionButton(
      IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.1),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 30),
        onPressed: onPressed,
      ),
    );
  }
}
