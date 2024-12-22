import 'dart:io';
import 'package:flutter/material.dart';

class ImageMaskingScreen extends StatefulWidget {
  final File image;
  final Function({
  required Offset includePoint,
  required Offset excludePoint,
  }) onSubmit;

  const ImageMaskingScreen({
    super.key,
    required this.image,
    required this.onSubmit,
  });

  @override
  State<ImageMaskingScreen> createState() => _ImageMaskingScreenState();
}

class _ImageMaskingScreenState extends State<ImageMaskingScreen> {
  Offset? _includePoint;
  Offset? _excludePoint;

  @override
  void initState() {
    super.initState();
  }

  void _onImageTap(TapUpDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localOffset = box.globalToLocal(details.localPosition);

    setState(() {
      if (_includePoint == null) {
        _includePoint = localOffset;
      } else if (_excludePoint == null) {
        _excludePoint = localOffset;
      }
    });
  }

  void _resetPoints() {
    setState(() {
      _includePoint = null;
      _excludePoint = null;
    });
  }

  void _submit() {
    if (_includePoint == null || _excludePoint == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("마스킹 포인트를 설정해주세요!")),
      );
      print("Error: Masking points are null. Cannot proceed.");
      return;
    }
    print(_includePoint);
    print(_excludePoint);
    widget.onSubmit(
      includePoint: _includePoint!,
      excludePoint: _excludePoint!,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("성공적으로 저장 되었습니다!")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '마스킹 영역 선택',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.white, // 기존 앱바 색상 유지
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.keyboard_arrow_left),
          color: Colors.black87,
        ),
        shape: Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 0.1,
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // AppBar와 이미지 사이의 공간에 텍스트 추가
            Padding(
              padding: const EdgeInsets.only(top: 15.0, bottom: 10.0),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  children: [
                    TextSpan(text: "옷을 착용할 영역은 "),
                    TextSpan(
                      text: "녹색포인터",
                      style: TextStyle(color: Colors.green),
                    ),
                    TextSpan(text: "\n그렇지 않은 부분은 "),
                    TextSpan(
                      text: "빨간색 포인터",
                      style: TextStyle(color: Colors.red),
                    ),
                    TextSpan(text: "로 표시해주세요."),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  GestureDetector(
                    onTapUp: _onImageTap,
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(
                          maxWidth: 300, // 원하는 최대 너비
                          maxHeight: 400, // 원하는 최대 높이
                        ),
                        margin: const EdgeInsets.only(bottom: 110),
                        child: Image.file(
                          widget.image,
                          fit: BoxFit.contain, // 이미지 비율 유지
                        ),
                      ),
                    ),
                  ),

                  if (_includePoint != null)
                    Positioned(
                      left: _includePoint!.dx,
                      top: _includePoint!.dy,
                      child: const Icon(Icons.circle, color: Colors.green, size: 12),
                    ),
                  if (_excludePoint != null)
                    Positioned(
                      left: _excludePoint!.dx,
                      top: _excludePoint!.dy,
                      child: const Icon(Icons.circle, color: Colors.red, size: 12),
                    ),
                  Positioned(
                    bottom: 80,
                    left: 16,
                    right: 16,
                    child: ElevatedButton(
                      onPressed: _resetPoints,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.black87,
                      ),
                      child: const Text(
                        '포인터 새로 지정하기',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.black87,
                      ),
                      child: const Text(
                        '포인터 저장',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
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
