import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../services/api_service.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> with SingleTickerProviderStateMixin{
  late TabController _tabController;
  var userImage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _tabController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "의류 장터",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.keyboard_arrow_left),
          highlightColor: Colors.transparent,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
            },
            highlightColor: Colors.transparent,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48),
          child: Container(
            color: Color.fromRGBO(255, 182, 163, 0.5),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              indicatorPadding: EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 4,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black,
              tabs: [
                Tab(text: "의류 구매"),
                Tab(text: "의류 판매"),
              ],
              splashFactory: NoSplash.splashFactory,
              overlayColor: MaterialStateProperty.all(Colors.transparent),
              dividerColor: Colors.transparent,
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: TabBarView(
          controller: _tabController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            Text("의류 구매"),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(255, 182, 163, 0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: IconButton(
                      onPressed: () async {
                        var picker = ImagePicker();
                        var image = await picker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          setState(() {
                            userImage = File(image.path);
                          });
                        }
                        if(userImage == null){
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Upload(userImage: userImage),
                          ),
                        );
                      },
                      icon: Icon(Icons.image),
                      color: Colors.white,
                      iconSize: 80,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "의류 판매를 위한 촬영",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "구겨진 옷은 반드시 펴서 촬영해주세요\n1. 옷을 입고 찍기\n2. 옷을 펴서 찍기",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
      ),

    );
  }
}

class Upload extends StatefulWidget {
  const Upload({super.key, this.userImage, this.getClothes});
  final File? userImage;
  final getClothes;

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {


  List<String> selectedClothingStyle = [];
  int selectedRating = 0; // 선택된 별 개수 (만족도 수)
  final TextEditingController _clothingNameController = TextEditingController(); // 옷 이름 입력 컨트롤러
  final TextEditingController _accountNumber = TextEditingController();
  final TextEditingController _price = TextEditingController();
  final TextEditingController _postName = TextEditingController();
  bool isClothingNameEmpty = false;
  bool isRatingEmpty = false;
  bool isClothingTypeEmpty = false;
  bool isClothingStyleEmpty = false;
  bool isPostNameEmpty = false;
  final ApiService _apiService = ApiService();



  void _validateAndSubmit() {
    setState(() {
      // 입력 값 확인 및 상태 업데이트
      isClothingNameEmpty = _clothingNameController.text.isEmpty;
      isRatingEmpty = _accountNumber.text.isEmpty;
      isClothingTypeEmpty = _price.text.isEmpty;
      if(selectedClothingStyle == null) {
        isClothingStyleEmpty = true;
      }
      isPostNameEmpty = _postName.text.isEmpty;
    });

    if (!isClothingNameEmpty && !isRatingEmpty && !isClothingTypeEmpty && !isClothingStyleEmpty && !isPostNameEmpty) {

      // 모든 필드가 입력되었을 때 동작
      print("옷 이름: ${_clothingNameController.text}");
      print("거래 종류: $selectedClothingStyle");
      print("거래 가격: ${_price.text}");
      print("계좌 번호: ${_accountNumber.text}");
      print("게시 글: ${_postName.text}");
      // 여기서 등록 로직을 추가하세요
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.close),
        ),
        title: Text(
          '의류 장터 옷 등록',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Image.file(
                    widget.userImage!,
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
            Text(
              '옷 이름',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isClothingNameEmpty ? Colors.red : Colors.black,
              ),
              textAlign: TextAlign.left,
            ),
            TextField(
              controller: _clothingNameController,
              decoration: InputDecoration(
                hintText: '옷 이름을 입력하세요',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none, // Border 제거
              ),
            ),
            SizedBox(height: 12),
            Text(
              '거래 종류',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isClothingStyleEmpty ? Colors.red : Colors.black,
              ),
            ),
            Wrap(
              spacing: 8,
              children: [
                _buildSelectableButton('택배'),
                _buildSelectableButton('직거래'),
              ],
            ),
            SizedBox(height: 20),
            Text('거래 가격 (택배비는 가격에 포함해주세요)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isClothingTypeEmpty ? Colors.red : Colors.black,
              ),
            ),
            Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                maxLines: 1,
                controller: _price,
                keyboardType: TextInputType.number, // 숫자 키보드 사용
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // 숫자만 허용
                ],
                decoration: InputDecoration(
                  hintText: '판매 가격을 입력해주세요.',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text('계좌번호 등록',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isRatingEmpty ? Colors.red : Colors.black,
              ),
            ),
            Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                maxLines: 1,
                controller: _accountNumber,
                keyboardType: TextInputType.number, // 숫자 키보드 사용
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // 숫자만 허용
                ],
                decoration: InputDecoration(
                  hintText: '계좌번호를 입력해주세요.',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text('게시글' , style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isPostNameEmpty ? Colors.red : Colors.black,
            )),
            Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                maxLines: 1,
                controller: _postName,
                decoration: InputDecoration(
                  hintText: '게시글을 입력해주세요',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _validateAndSubmit,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  child: Text(
                    '의류 장터에 등록하기',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectableButton(String label) {
    bool isSelected = selectedClothingStyle.contains(label);

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        backgroundColor: isSelected
            ? Color.fromRGBO(255, 182, 163, 1) // 선택된 상태 색상
            : Color.fromRGBO(255, 182, 163, 0.5), // 비선택 상태 색상
        minimumSize: Size(60, 36),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      onPressed: () {
        setState(() {
          if (isSelected) {
            // 이미 선택된 경우 리스트에서 제거
            selectedClothingStyle.remove(label);
          } else {
            // 선택되지 않은 경우 리스트에 추가
            selectedClothingStyle.add(label);
          }
        });
      },
      child: Text(
        label,
        style: TextStyle(color: Colors.black, fontSize: 12),
      ),
    );
  }
}


