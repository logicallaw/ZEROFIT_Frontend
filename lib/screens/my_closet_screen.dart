import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'account_management_screen.dart';
import '../services/api_service.dart';
import 'image_masking.dart';

class MyClosetScreen extends StatefulWidget {
  const MyClosetScreen({Key? key}) : super(key: key);

  @override
  _MyClosetScreenState createState() => _MyClosetScreenState();
}

class _MyClosetScreenState extends State<MyClosetScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  var userImage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Closet",
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AccountManagementScreen(),
                ),
              );
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
                Tab(text: "나의 옷장"),
                Tab(text: "AI 피팅"),
                Tab(text: "옷 등록"),
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
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 두 줄씩 배치
                    crossAxisSpacing: 16.0, // 아이템 간 가로 간격
                    mainAxisSpacing: 16.0, // 아이템 간 세로 간격
                    childAspectRatio: 3 / 4, // 아이템의 가로세로 비율 조정
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _buildItem(item['image']!, item['title']!, item['subtitle']!);
                  },
                ),
              ),
            ),
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
                    "AI피팅을 위한 전신사진 찍기",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "상의피팅은 전신이 아니어도 가능합니다.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
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
                    "나의 옷장을 위한 사진 찍기",
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
        ),
      ),
    );
  }
}

Widget _buildItem(String imagePath, String title, String subtitle) {
  return Container(

    decoration: BoxDecoration(
      color: Color.fromRGBO(255, 182, 163, 0.3),
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
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            height: 150,
            width: double.infinity,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Text(
            subtitle,
            style: TextStyle(color: Colors.black, fontSize: 13),
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
  );
}

final List<Map<String, String>> items = [
  {
    'image': 'assets/clot.png',
    'title': '가을 맞이 니트',
    'subtitle': '#상의 #캐주얼',
  },
  {
    'image': 'assets/clot.png',
    'title': '무난무난한 운동화',
    'subtitle': '#신발 #스포츠',
  },
  {
    'image': 'assets/clot.png',
    'title': '도넛 목걸이',
    'subtitle': '#악세사리 #포인트',
  },
  {
    'image': 'assets/clot.png',
    'title': '부츠컷 청바지',
    'subtitle': '#바지 #캐주얼',
  },
  {
    'image': 'assets/clot.png',
    'title': '가을아 가자마 코트',
    'subtitle': '#아우터 #포멀',
  },
  {
    'image': 'assets/clot.png',
    'title': '기본 맨투맨',
    'subtitle': '#상의 #캐주얼',
  },
];

class Upload extends StatefulWidget {
  const Upload({super.key, this.userImage});
  final File? userImage;

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  List<String> selectedClothingType = []; // 선택된 옷 종류들
  List<String> selectedClothingStyle = []; // 선택된 옷 스타일들
  int selectedRating = 0; // 선택된 별 개수 (만족도 수)
  final TextEditingController _clothingNameController = TextEditingController(); // 옷 이름 입력 컨트롤러
  final TextEditingController _memoController = TextEditingController();
  bool isClothingNameEmpty = false;
  bool isRatingEmpty = false;
  bool isClothingTypeEmpty = false;
  bool isClothingStyleEmpty = false;
  final ApiService _apiService = ApiService();
  late Offset _includePoint;
  late Offset _excludePoint;

  Future<void> _uploadImage() async {
    String uploadStat ='';

    final response = await _apiService.uploadImage(
      image: widget.userImage!,
      clothingName: _clothingNameController.text,
      rating: selectedRating,
      clothingTypes: selectedClothingType,
      clothingStyles: selectedClothingStyle,
      memo: _memoController.text,
      includePoint: _includePoint,
      excludePoint: _excludePoint,
    );
   setState(() {
     if(response != null){
       uploadStat = 'success';
     }
     else {
       uploadStat = 'fail';
     }
   });
    print(uploadStat);
  }

  void _validateAndSubmit() {
    setState(() {
      // 입력 값 확인 및 상태 업데이트
      isClothingNameEmpty = _clothingNameController.text.isEmpty;
      isRatingEmpty = selectedRating == 0;
      isClothingTypeEmpty = selectedClothingType.isEmpty;
      isClothingStyleEmpty = selectedClothingStyle.isEmpty;
    });

    if (!isClothingNameEmpty && !isRatingEmpty && !isClothingTypeEmpty && !isClothingStyleEmpty) {
      if(_memoController.text.isEmpty) {
        _memoController.text = "";
      }
      // 모든 필드가 입력되었을 때 동작
      print("옷 이름: ${_clothingNameController.text}");
      print("별 점수: $selectedRating");
      print("옷 종류: $selectedClothingType");
      print("옷 스타일: $selectedClothingStyle");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageMaskingScreen(
            image: widget.userImage!,
            onSubmit: ({required Offset includePoint, required Offset excludePoint}) {
              setState(() {
                _includePoint = includePoint;
                _excludePoint = excludePoint;
              });

              print("Include Point: $_includePoint");
              print("Exclude Point: $_excludePoint");
              _uploadImage();
              Navigator.pop(context);

            },
          ),
        ),
      );


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
          '옷 등록',
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
              '얼마나 만족하나요?',
              style: TextStyle(
                color: isRatingEmpty ? Colors.red : Colors.black,
              ),
              textAlign: TextAlign.left,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      // 선택된 별 수를 업데이트
                      selectedRating = index + 1;
                    });
                  },
                  child: Icon(
                    index < selectedRating ? Icons.star : Icons.star_border,
                    color: Color.fromRGBO(255, 182, 163, 1.0),
                    size: 24, // 별 크기 조절 가능
                  ),
                );
              }).map((icon) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: icon,
              )).toList(), // 별 사이의 간격을 줄이기 위해 Padding 추가
            ),
            SizedBox(height: 20),
            Text(
              '옷 종류',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isClothingTypeEmpty ? Colors.red : Colors.black,
              ),
            ),
            Wrap(
              spacing: 8,
              children: [
                _buildSelectableButton('상의', isStyle: false),
                _buildSelectableButton('하의', isStyle: false),
                _buildSelectableButton('외투', isStyle: false),
                _buildSelectableButton('원피스', isStyle: false),
                _buildSelectableButton('액세서리', isStyle: false),
              ],
            ),
            SizedBox(height: 20),
            Text(
              '옷 스타일',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isClothingStyleEmpty ? Colors.red : Colors.black,
              ),
            ),
            Wrap(
              spacing: 8,
              children: [
                _buildSelectableButton('캐주얼', isStyle: true),
                _buildSelectableButton('빈티지', isStyle: true),
                _buildSelectableButton('포멀', isStyle: true),
                _buildSelectableButton('미니멀', isStyle: true),
              ],
            ),
            SizedBox(height: 20),
            Text('옷에 대한 추가적인 메모를 작성해주세요.'),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                maxLines: 3,
                controller: _memoController,
                decoration: InputDecoration(
                  hintText: '의류 관리법을 입력하세요.',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: 20),
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
                    '옷장에 등록하기',
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

  Widget _buildSelectableButton(String label, {required bool isStyle}) {
    bool isSelected = isStyle
        ? selectedClothingStyle.contains(label)
        : selectedClothingType.contains(label);

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        backgroundColor: isSelected
            ? Color.fromRGBO(255, 182, 163, 1)
            : Color.fromRGBO(255, 182, 163, 0.5),
        minimumSize: Size(60, 36),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      onPressed: () {
        setState(() {
          if (isStyle) {
            // 선택 토글
            if (selectedClothingStyle.contains(label)) {
              selectedClothingStyle.remove(label);
            } else {
              selectedClothingStyle.add(label);
            }
          } else {
            // 선택 토글
            if (selectedClothingType.contains(label)) {
              selectedClothingType.remove(label);
            } else {
              selectedClothingType.add(label);
            }
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

