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
    // 초기 상태: 좌표는 null
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
        const SnackBar(content: Text("Please select all required points")),
      );
      print("Error: Masking points are null. Cannot proceed.");
      return;
    }

    widget.onSubmit(
      includePoint: _includePoint!,
      excludePoint: _excludePoint!,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Masking points saved successfully!")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Masking Points'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          GestureDetector(
            onTapUp: _onImageTap,
            child: Stack(
              children: [
                Image.file(
                  widget.image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
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
              ],
            ),
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
              ),
              child: const Text('Reset Points', style: TextStyle(fontSize: 18)),
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
              ),
              child: const Text('Save Points', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}

