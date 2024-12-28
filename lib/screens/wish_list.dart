import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.keyboard_arrow_left),
          color: Colors.black87,
        ),
        title: const Text('위시리스트',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            )),
        centerTitle: true,
        shape: Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 0.1,
          ),
        ),
      ),

      body: Container(
        color: Colors.white,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: items == null
                ? SpinKitWave(
              // 색상을 파란색으로 설정
              color: Colors.black87,
              // 크기를 50.0으로 설정
              size: 50.0,
              // 애니메이션 수행 시간을 2초로 설정
              duration: Duration(seconds: 2),
            )
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
          color: Colors.black87,
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
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "가격 : ${subtitle}원",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                  TextButton(
                    onPressed: () {
                      print("구매 버튼 클릭: $index");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PurchasePage(
                            item: items[index],
                          ),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      minimumSize: Size(0, 0), // 최소 크기 제거
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap, // 버튼 크기 축소
                      backgroundColor: Colors.white,
                    ),
                    child: Text(
                      "구매",
                      style: TextStyle(
                        color:Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PurchasePage extends StatefulWidget {
  const PurchasePage({super.key, this.item});
  final item;
  @override
  State<PurchasePage> createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {
  var itemImage;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final Uint8List imageBytes =
    base64Decode(widget.item['base64_image']!);
    itemImage = imageBytes;
  }

  void purchase() {
    if(widget.item == null)
      return;



      Navigator.pop(context);
      showPurchaseDialog(context);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("옷 구매", style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        )),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.keyboard_arrow_left), color: Colors.black87,),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지와 상품 정보
            Container(
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Image.memory(
                    itemImage, // 상품 이미지 URL 대체
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item["price"].toString() +"원  " +  widget.item["sale_type"].toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          widget.item["post_name"],
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // "구매 수단" 제목
            Text(
              "구매 수단",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),

            // 신용카드 결제 선택
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Radio(
                          value: true,
                          groupValue: true,
                          onChanged: (value) {},
                        ),
                        Text("신용카드 결제"),
                      ],
                    ),
                    Divider(),
                    // 카드 리스트
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: "신한카드",
                        items: [
                          DropdownMenuItem(
                            value: "신한카드",
                            child: Text("신한카드 xxxx xxxx 1234"),
                          ),
                          DropdownMenuItem(
                            value: "Visa",
                            child: Text("Visa xxxx xxxx 9876"),
                          ),
                        ],
                        onChanged: (value) {
                          print(value); // 선택한 카드 확인
                        },
                      ),
                    ),
                    SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        print("새로운 카드 등록");
                      },
                      child: Text(
                        "+ 새로운 카드 등록하기",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // 토스페이 선택
            Row(
              children: [
                Radio(
                  value: false,
                  groupValue: true,
                  onChanged: (value) {},
                ),
                Text("토스페이"),
              ],
            ),
            Divider(),

            // 계좌이체 선택
            Row(
              children: [
                Radio(
                  value: false,
                  groupValue: true,
                  onChanged: (value) {},
                ),
                Text("계좌이체 (판매자 계좌번호)"),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: 50,
          child: ElevatedButton(
            onPressed: () {
                purchase();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87, // 버튼 배경색
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // 버튼 모서리 둥글게
              ),
              padding:
              EdgeInsets.symmetric(vertical: 12, horizontal: 24), // 버튼 높이 조정
            ),
            child: Text(
              '구매',
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

  void showPurchaseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          content: SizedBox(
            width: 200,
            height: 150,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "구매 완료!",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // 버튼 배경색
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                    child: Text(
                      "확인",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
