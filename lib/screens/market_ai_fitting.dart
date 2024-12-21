import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class MarketAiFitting extends StatefulWidget {
  const MarketAiFitting({super.key, this.image_name});
  final image_name;

  @override
  State<MarketAiFitting> createState() => _MarketAiFittingState();
}

class _MarketAiFittingState extends State<MarketAiFitting> {
  final ApiService _apiService = ApiService();
  var fitImage;
  var personImage;

  getAiFitting(String image_name) async {
    print(image_name);

    var result = await _apiService.getAiFitting(
      personImage: personImage,
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
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: personImage == null ? IconButton(
                  onPressed: () async {
                    var picker = ImagePicker();
                    var image = await picker.pickImage(source: ImageSource.gallery);
                    if(image == null)
                      return;
                    setState(() {
                      personImage = File(image.path);
                    });
                    getAiFitting(widget.image_name.toString());
                  },
                  icon: Icon(Icons.image),
                  color: Colors.white,
                  iconSize: 100,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                ) : Image.file(
                  personImage!,
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
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
      ),
    );
  }
}
