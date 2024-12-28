import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AiFitting extends StatefulWidget {
  AiFitting({super.key, required this.personImage, this.items});
  final File personImage;
  final items;

  @override
  State<AiFitting> createState() => _AiFittingState();
}

class _AiFittingState extends State<AiFitting> {
  int? selectedIndex; // 선택된 버튼의 인덱스를 저장
  final ApiService _apiService = ApiService();
  var fitImage;

  getAiFitting(String image_name) async {
    var result = await _apiService.getAiFitting(
      personImage: widget.personImage,
      clothingImageName: image_name,
    );

    print(result);

    if (result == "") {
      return;
    } else {
      final Uint8List imageBytes = base64Decode(result);
      setState(() {
        fitImage = imageBytes;
      });
      return;
    }
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
        title: const Text('AI 피팅',
            style: TextStyle(
              color: Colors.black,
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
          child: fitImage != null
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "AI 피팅 결과",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 16),
              Image.memory(
                fitImage,
                fit: BoxFit.contain,
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.6,
              ),
            ],
          )
              : Padding(
            padding: const EdgeInsets.all(16.0),
            child: widget.items == null
                ? Text('옷을 등록해주세요!' ,style: TextStyle(color: Colors.grey))
                : GridView.builder(
              gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 두 줄씩 배치
                crossAxisSpacing: 16.0, // 아이템 간 가로 간격
                mainAxisSpacing: 16.0, // 아이템 간 세로 간격
                childAspectRatio: 3 / 4, // 아이템의 가로세로 비율 조정
              ),
              itemCount: widget.items!.length,
              itemBuilder: (context, index) {
                final item = widget.items![index];
                print(item['base64_image']!.runtimeType);
                final Uint8List imageBytes =
                base64Decode(item['base64_image']!);
                return _buildItem(
                  imageBytes,
                  item['clothes_name'].toString(),
                  item['clothes_type'].join('#'),
                  index,
                );
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: 50,
            child: ElevatedButton(
              onPressed: () {
                if (selectedIndex != null) {
                  print("Selected Item Index: $selectedIndex");
                  String image_name =
                  widget.items[selectedIndex]['image_name'].toString();
                  getAiFitting(image_name);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("먼저 아이템을 선택해주세요.")),
                  );
                }
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
                '옷 입어보기',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
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
              padding:
              const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "#" + subtitle,
                    style: TextStyle(color: Colors.white, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Icon(
                    Icons.favorite,
                    color: selectedIndex == index
                        ? Color(0xFFFF9990)
                        : Colors.white,
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
