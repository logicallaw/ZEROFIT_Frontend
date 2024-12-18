import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../services/api_service.dart';

class WishList extends StatefulWidget {
  const WishList({super.key});

  @override
  State<WishList> createState() => _WishListState();
}

class _WishListState extends State<WishList> {
  final ApiService _apiService = ApiService();
  var items;
  int? selectedIndex;

  getWishListItem() async {
    var result = await _apiService.getWishListInfo();
    if(result == null)
      return;

    setState(() {
      items =  List<dynamic>.from(result);
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getWishListItem();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.keyboard_arrow_left),
          color: Color.fromRGBO(255, 182, 163, 0.5),
        ),
        title: const Text('위시리스트',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            )),
        centerTitle: true,
      ),

      body: Container(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: items == null
                ? Text('로딩중')
                : GridView.builder(
              gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 두 줄씩 배치
                crossAxisSpacing: 16.0, // 아이템 간 가로 간격
                mainAxisSpacing: 16.0, // 아이템 간 세로 간격
                childAspectRatio: 3 / 4, // 아이템의 가로세로 비율 조정
              ),
              itemCount: items!.length,
              itemBuilder: (context, index) {
                final item = items![index];
                print(item['base64_image']!.runtimeType);
                final Uint8List imageBytes =
                base64Decode(item['base64_image']!);
                return _buildItem(
                  imageBytes,
                  item['clothes_name'].toString(),
                  item['price'].toString(),
                  index,
                );
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: 50,
          child: ElevatedButton(
            onPressed: () {
              if (selectedIndex != null) {
                print("Selected Item Index: $selectedIndex");
                String image_name =
                items[selectedIndex]['image_name'].toString();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("먼저 아이템을 선택해주세요.")),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF5A4033), // 버튼 배경색
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // 버튼 모서리 둥글게
              ),
              padding:
              EdgeInsets.symmetric(vertical: 12, horizontal: 24), // 버튼 높이 조정
            ),
            child: Text(
              '옷 구매',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildItem(
      Uint8List imageBytes, String title, String subtitle, int index) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedIndex = index; // 선택된 버튼의 인덱스를 저장
        });
        print("Selected Item Index: $index");
      },
      child: Container(
        decoration: BoxDecoration(
          color: selectedIndex == index
              ? Color.fromRGBO(255, 182, 163, 0.5) // 선택된 경우 더 진한 색상
              : Color.fromRGBO(255, 182, 163, 0.3),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.memory(
                imageBytes,
                fit: BoxFit.cover,
                height: 150,
                width: double.infinity,
              ),
            ),
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "가격 : ${subtitle}원",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Icon(
                        Icons.favorite,
                        color: selectedIndex == index
                            ? Color.fromRGBO(255, 182, 163, 1)
                            : Colors.grey.withOpacity(0.5),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

