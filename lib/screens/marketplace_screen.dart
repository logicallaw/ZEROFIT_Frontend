import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import 'wish_list.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'market_ai_fitting.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> with SingleTickerProviderStateMixin{
  late TabController _tabController;
  var userImage;
  int? selectedIndex;
  List<dynamic>? items;
  final ApiService _apiService = ApiService();
  List<dynamic>? marketItems;
  List<Uint8List> decodedImages = [];
  int currentIndex = 0;
  getMarketClothes() async {
    var result = await _apiService.getMarketPlaceInfo();
    if(result == null)
      return;

    setState(() {
      marketItems = List<dynamic>.from(result);
      decodedImages = marketItems!
          .map<Uint8List>((item) {
        final base64Image = item['base64_image'] as String?;
        if (base64Image != null) {
          return base64Decode(base64Image); // Base64 디코딩
        }
        return Uint8List(0); // null 처리 (빈 데이터)
      })
          .where((decoded) => decoded.isNotEmpty)
          .toList();
      currentIndex = 0;
    });

  }

  getClothes() async{
    var result = await _apiService.getClothesInfo();
    if(result == null)
      return;

    setState(() {
      items =  List<dynamic>.from(result);
    });
  }

  uploadWishlist(int index) async {
    var result = await _apiService.uploadWishList(clothesId: marketItems![currentIndex]["clothes_id"]);
  }

  void onSwipe(String direction) {
    print('User swiped $direction');
    if(direction == 'right'){
      uploadWishlist(currentIndex);
    }
    setState(() {
      if (currentIndex < decodedImages.length - 1) {
        currentIndex++;
      } else {
        // 마지막 이미지에서 처음 이미지로 돌아가기
        currentIndex = 0;
      }
    });
    print("currentIndex : $currentIndex");
    print(marketItems![currentIndex]["image_name"]);
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    getClothes();
    getMarketClothes();
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
          color: Colors.black87,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
            },
            highlightColor: Colors.transparent,
            color: Colors.black87,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48),
          child: Container(
            color: Colors.black87,
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
              labelColor: Colors.black87,
              unselectedLabelColor: Colors.white,
              tabs: [
                GestureDetector(
                  onTap: (){
                      getMarketClothes();
                      _tabController.animateTo(0);
                  },
                      child: Tab(text: "의류 구매"),
                ),
                GestureDetector(
                  onTap: (){
                    getClothes();
                    _tabController.animateTo(1);
                  },
                  child: Tab(text: "의류 판매"),
                ),
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
            decodedImages.isEmpty
                ? SpinKitWave(
              // 색상을 파란색으로 설정
              color: Colors.black87,
              // 크기를 50.0으로 설정
              size: 50.0,
              // 애니메이션 수행 시간을 2초로 설정
              duration: Duration(seconds: 2),
            )
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // Dismissible로 이미지 부분만 감싸기
                Expanded(
                  flex: 8,
                  child: Stack(
                    children: [
                      // 이미지 부분
                      Dismissible(
                        key: ValueKey(decodedImages[currentIndex]),
                        direction: DismissDirection.horizontal,
                        onDismissed: (direction) {
                          if (direction == DismissDirection.endToStart) {
                            onSwipe('left'); // 왼쪽으로 스와이프
                          } else if (direction == DismissDirection.startToEnd) {
                            onSwipe('right'); // 오른쪽으로 스와이프
                          }
                        },
                        child: Center(
                          child: Image.memory(
                            decodedImages[currentIndex],
                            fit: BoxFit.contain, // 이미지 비율 유지
                            width: double.infinity,
                          ),
                        ),
                      ),

                      // 위시리스트 아이콘 (이미지 위 오른쪽 상단)
                      Positioned(
                        top: 16,
                        right: 16,
                        child: GestureDetector(
                          onTap: () {
                            print("위시리스트로 이동!");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const WishList(),
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              Icon(Icons.shopping_bag,
                                  size: 40, color: Colors.blueAccent),
                              Text(
                                "WishList",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),

                // 안내 문구 (화면에 고정됨)
                Text(
                  "마음에 드는 옷은 오른쪽\n그렇지 않으면 왼쪽으로 넘겨주세요!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),

                // 아이콘 영역 (화면에 고정됨)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Icon(Icons.sentiment_very_dissatisfied, size: 50, color: Colors.orange),

                      ],
                    ),
                    Column(
                      children: [
                        IconButton(onPressed: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MarketAiFitting(
                                image_name: marketItems![currentIndex]["image_name"],
                              ),
                            ),
                          );
                        }, icon: Icon(Icons.search, size: 50, color: Colors.blue)),
                      ],
                    ),
                    Column(
                      children: [
                        Icon(Icons.sentiment_very_satisfied, size: 50, color: Colors.pink),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: items == null
                    ? Text('옷을 등록해주세요!' ,style: TextStyle(color: Colors.grey))
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
                      item['clothes_type'].join('#'),
                      index,
                    );
                  },
                ),
              ),
            )
          ],
        )
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
        print("Selected Item Id: ${items![index]["clothes_id"]}");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Upload(userImage: imageBytes, clothesId: items![index]["clothes_id"],),
          ),
        );

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




class Upload extends StatefulWidget {
  const Upload({super.key, this.userImage, this.clothesId});
  final Uint8List? userImage;
  final clothesId;

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

      isRatingEmpty = _accountNumber.text.isEmpty;
      isClothingTypeEmpty = _price.text.isEmpty;
      if(selectedClothingStyle == null) {
        isClothingStyleEmpty = true;
      }
      isPostNameEmpty = _postName.text.isEmpty;
    });

    if (!isRatingEmpty && !isClothingTypeEmpty && !isClothingStyleEmpty && !isPostNameEmpty) {

      // 모든 필드가 입력되었을 때 동작
      print("옷 번호: ${widget.clothesId}");
      print("거래 종류: $selectedClothingStyle");
      print("거래 가격: ${_price.text}");
      print("계좌 번호: ${_accountNumber.text}");
      print("게시 글: ${_postName.text}");
      // 여기서 등록 로직을 추가하세요

      _apiService.SaleClothes(
          clothesId: widget.clothesId,
          postName: _postName.text,
          saleType: selectedClothingStyle,
          price: int.parse(_price.text),
          bankAccount: _accountNumber.text
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("판매 등록 성공!")),
      );
    }

    Navigator.pop(context);
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
          color: Colors.black87,
        ),
        title: Text(
          '의류 장터 옷 등록',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        shape: Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 0.1,
          ),
        ),
      ),
      body: Container(
        height: double.infinity,
        color: Colors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Image.memory(
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
                '게시글',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isPostNameEmpty ? Colors.red : Colors.black,
                ),
                textAlign: TextAlign.left,
              ),
              TextField(
                controller: _postName,
                decoration: InputDecoration(
                  hintText: '게시글을 입력해주세요',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none, // Border 제거
                ),
              ),
              SizedBox(height: 20),
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
              SizedBox(height: 4),
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
                    hintText: ' 판매 가격을 입력해주세요.',
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
              SizedBox(height: 4),
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
                  decoration: InputDecoration(
                    hintText: ' 계좌번호를 입력해주세요.',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 60),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
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
      ),

    );


  }

  Widget _buildSelectableButton(String label) {
    bool isSelected = selectedClothingStyle.contains(label);

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        backgroundColor: isSelected
            ? Colors.black87 // 선택된 상태 색상
            : Colors.grey, // 비선택 상태 색상
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
        style: TextStyle(
          color: isSelected
          ? Colors.white
          : Colors.black87,
          fontSize: 12,
        ),
      ),
    );
  }




}


