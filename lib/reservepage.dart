import 'package:RevMate/deadlinewidget.dart';
import 'package:flutter/material.dart';
import 'animatedpageroute.dart';
import 'revisedpage.dart';
import 'mainpage.dart';
import 'reservation_service.dart';
import 'styles.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'dart:io';
import 'availabletimespage.dart';

class ReservePage extends StatefulWidget {
  const ReservePage({super.key});

  @override
  _ReservePageState createState() => _ReservePageState();
}

class _ReservePageState extends State<ReservePage> {
  String? _selectedEquipment;
  String? _ocrText;
  bool _isLoading = false;
  File? _processedFile;
  final ImagePicker _picker = ImagePicker();
  final ReservationService _reservationService = ReservationService();

  Future<void> runFilePicker() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final processedFile = await _processImage(File(pickedFile.path));
      if (processedFile != null) {
        setState(() {
          _processedFile = processedFile;
        });
        await _ocr(processedFile.path);
      }
    }
  }

  Future<File?> _processImage(File imageFile) async {
    final image = img.decodeImage(imageFile.readAsBytesSync());
    if (image != null) {
      final scaledImage = img.copyResize(image,
          width: image.width * 2, height: image.height * 2);
      final croppedImage =
          img.copyCrop(scaledImage, x: 0, y: 1500, width: 690, height: 74);
      final bwImage = img.grayscale(croppedImage);
      img.adjustColor(bwImage, contrast: 1.5);

      final processedFile = File('${imageFile.path}_processed.jpg')
        ..writeAsBytesSync(img.encodeJpg(bwImage));
      return processedFile;
    }
    return null;
  }

  Future<void> _ocr(String imagePath) async {
    setState(() {
      _isLoading = true;
      _ocrText = '';
    });

    try {
      String text = await FlutterTesseractOcr.extractText(imagePath,
          language: 'kor',
          args: {
            "psm": "6",
            "preserve_interword_spaces": "1",
            "tessedit_char_whitelist": "0123456789:",
            "ocr_engine_mode": "1"
          });

      RegExp regex = RegExp(r'(\d{1,2}):(\d{2})');
      Match? match = regex.firstMatch(text);

      setState(() {
        _ocrText = match != null
            ? match.group(1) ?? '출력 예상시간을 찾을 수 없습니다.'
            : '출력 예상시간을 찾을 수 없습니다.';
      });
    } catch (e) {
      setState(() {
        _ocrText = 'OCR 인식에 실패했습니다: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  int _parseDuration(String? duration) {
    if (duration == null) return 0;
    int hours = int.parse(duration.split(':')[0]);
    return hours;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('예약'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'STEP1 사용장비 선택',
                style: headerTextStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DropdownButton<String>(
                items: const [
                  DropdownMenuItem<String>(
                    value: 'S4',
                    child: Text('싱글플러스_04'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'S5',
                    child: Text('싱글플러스_05'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'S6',
                    child: Text('싱글플러스_06'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'S7',
                    child: Text('싱글플러스_07'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'cubstyle01',
                    child: Text('스타일_01'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'cubstyle02',
                    child: Text('스타일_02'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'cubstyle03',
                    child: Text('스타일_03'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'ender5_01',
                    child: Text('엔더5_01'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'ender5_02',
                    child: Text('엔더5_02'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'sin_01',
                    child: Text('신도리코_01'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'sin_02',
                    child: Text('신도리코_02'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'sin_03',
                    child: Text('신도리코_03'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'sin_04',
                    child: Text('신도리코_04'),
                  ),
                  DropdownMenuItem<String>(
                    value: '12*9',
                    child: Text('레이저커터12*9'),
                  ),
                  DropdownMenuItem<String>(
                    value: '9*6',
                    child: Text('레이저커터9*6'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedEquipment = value;
                  });
                },
                hint: const Text('장비 선택'),
                value: _selectedEquipment,
              ),
            ),
            const SizedBox(height: 24.0),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'STEP2 도면 등록',
                style: headerTextStyle,
              ),
            ),
            Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: runFilePicker,
                    child: const Text('도면 이미지 선택'),
                  ),
                  if (_isLoading) const CircularProgressIndicator(),
                  if (_processedFile != null) Image.file(_processedFile!),
                  if (_ocrText != null) Text('인식된 출력 예상시간: $_ocrText'),
                ],
              ),
            ),
            const SizedBox(height: 24.0),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'STEP3 예약 옵션 선택',
                style: headerTextStyle,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_selectedEquipment != null && _ocrText != null) {
                      int duration = _parseDuration(_ocrText);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AvailableTimesPage(
                            equipment: _selectedEquipment!,
                            duration: duration,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('장비와 도면을 선택해주세요.')),
                      );
                    }
                  },
                  child: const Text('가장 빠른 일자'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_selectedEquipment != null && _ocrText != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => DeadlineWidget(
                            selectedEquipment: _selectedEquipment!,
                            ocrText: _ocrText!,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('장비와 도면을 선택해주세요.')),
                      );
                    }
                  },
                  child: const Text('마감 우선'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_selectedEquipment != null && _ocrText != null) {
                      Navigator.of(context).push(
                        animatedPageRoute(
                          pageBuilder: (_, __, ___) =>
                              RevisedPage(equipment: _selectedEquipment),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('장비와 도면을 선택해주세요.')),
                      );
                    }
                  },
                  child: const Text('자율'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
