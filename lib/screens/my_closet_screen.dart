import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'account_management_screen.dart';
import '../services/api_service.dart';
import 'image_masking.dart';
import 'dart:typed_data';
import 'dart:async';
import 'ai_fitting.dart';

class MyClosetScreen extends StatefulWidget {
  const MyClosetScreen({Key? key}) : super(key: key);

  @override
  _MyClosetScreenState createState() => _MyClosetScreenState();
}

class _MyClosetScreenState extends State<MyClosetScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  var userImage;
  final ApiService _apiService = ApiService();

  List<dynamic>? items;

  getClothes() async{
    var result = await _apiService.getClothesInfo();
    if(result == null)
      return;

    setState(() {
      items =  List<dynamic>.from(result);
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    getClothes();
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
          color: Colors.black87,
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
                    getClothes();
                    _tabController.animateTo(0);
                  },
                  child: Tab(text: "나의 옷장"),
                ),
                Tab(text: "AI 피팅"),
                Tab(text: "옷 등록" ),
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
                child: items == null ?  Text('옷을 등록해주세요!', style: TextStyle(color: Colors.grey),)
                 : GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 두 줄씩 배치
                    crossAxisSpacing: 16.0, // 아이템 간 가로 간격
                    mainAxisSpacing: 16.0, // 아이템 간 세로 간격
                    childAspectRatio: 3 / 4, // 아이템의 가로세로 비율 조정
                  ),
                  itemCount: items!.length,
                  itemBuilder: (context, index) {
                    final item = items![index];
                    final Uint8List imageBytes = base64Decode(item['base64_image']!);
                    return _buildItem(imageBytes, item['clothes_name'].toString(), item['clothes_type'].join('#'));
                  },
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: IconButton(
                      onPressed: () async {
                        var picker = ImagePicker();
                        var image = await picker.pickImage(source: ImageSource.gallery);
                        if(image == null)
                          return;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AiFitting(personImage: File(image.path), items : items),
                          ),
                        );
                      },
                      icon: Icon(Icons.image),
                      color: Colors.white,
                      iconSize: 100,
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
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black87,
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
                            builder: (context) => Upload(userImage: userImage, getClothes: getClothes),
                          ),
                        );
                      },
                      icon: Icon(Icons.image),
                      color: Colors.white,
                      iconSize: 100,
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

Widget _buildItem(Uint8List imageBytes, String title, String subtitle) {
  return Container(

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
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Text(
            "#" + subtitle,
            style: TextStyle(color: Colors.white, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}



class Upload extends StatefulWidget {
  const Upload({super.key, this.userImage, this.getClothes});
  final File? userImage;
  final getClothes;

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
              widget.getClothes(); // 여기 에러 가능 주의
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
          icon: Icon(Icons.keyboard_arrow_left),
          color: Colors.black87,
        ),
        title: Text(
          '옷 등록',
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
        color: Colors.white,
        child: SingleChildScrollView(
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
                      color: Colors.black87,
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
                    backgroundColor: Colors.black87,
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
            ? Colors.black87
            : Colors.grey,
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
        style: TextStyle(
            color: isSelected
            ? Colors.white
            : Colors.black87,
            fontSize: 12),
      ),
    );
  }
}

