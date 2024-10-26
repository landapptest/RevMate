import 'package:flutter/material.dart';
import 'package:RevMate/controllers/reserve_controller.dart';
import 'package:RevMate/models/reservation_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:RevMate/views/reservation/available_times_page.dart';
import 'package:RevMate/views/reservation/deadline_page.dart';
import 'package:RevMate/views/reservation/revised_page.dart';
import 'package:RevMate/views/widgets/styles.dart';

class ReservePage extends StatefulWidget {
  const ReservePage({super.key});

  @override
  _ReservePageState createState() => _ReservePageState();
}

class _ReservePageState extends State<ReservePage> {
  final ReserveController _reserveController = ReserveController(ReservationService());

  String? _selectedEquipment;
  String? _ocrText;
  bool _isLoading = false;
  File? _processedFile;

  List<String> get equipmentList => _reserveController.equipmentList;

  Future<void> _uploadImageAndRunOCR(File imageFile) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _reserveController.uploadImage(imageFile);

      final processedFile = await _reserveController.processImage(imageFile);
      if (processedFile != null) {
        final ocrText = await _reserveController.runOCR(processedFile.path);
        setState(() {
          _ocrText = ocrText;
          _processedFile = processedFile;
        });
      }
    } catch (e) {
      setState(() {
        _ocrText = '이미지 업로드 및 OCR 실패: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
              child: Text('STEP1 사용장비 선택', style: headerTextStyle),
            ),
            Center(
              child: DropdownButton<String>(
                items: equipmentList.map((String equipment) {
                  return DropdownMenuItem<String>(
                    value: equipment,
                    child: Text(equipment),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedEquipment = value;
                  });
                },
                value: _selectedEquipment,
                hint: const Text('장비 선택'),
              ),
            ),
            const SizedBox(height: 24.0),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('STEP2 도면 등록', style: headerTextStyle),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    await _uploadImageAndRunOCR(File(pickedFile.path));
                  }
                },
                child: const Text('도면 이미지 선택'),
              ),
            ),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
            if (_ocrText != null) Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('인식된 출력 예상시간: $_ocrText'),
            ),
            const SizedBox(height: 24.0),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('STEP3 예약 옵션 선택', style: headerTextStyle),
            ),
            _buildOptionButton(
              '가장 빠른 일자', '가까운 시간을 추천합니다.', 'assets/available_icon.png',
                  () {
                if (_selectedEquipment != null && _ocrText != null) {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AvailableTimesPage(
                      equipment: _selectedEquipment!,
                      duration: int.parse(_ocrText!.split(':')[0]),
                    ),
                  ));
                }
              },
            ),
            _buildOptionButton(
              '마감 우선', '마감일에 맞춰 자동으로 예약합니다.', 'assets/deadline_icon.png',
                  () {
                if (_selectedEquipment != null && _ocrText != null) {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => DeadlineWidget(
                      equipment: _selectedEquipment!,
                      ocrText: _ocrText!,
                    ),
                  ));
                }
              },
            ),
            _buildOptionButton(
              '자율', '자유롭게 날짜를 선택합니다.', 'assets/reivese_icon.png',
                  () {
                if (_selectedEquipment != null && _ocrText != null) {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => RevisedPage(
                      equipment: _selectedEquipment!,
                    ),
                  ));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(String title, String subtitle, String assetPath, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Stack(
        children: [
          Image.asset(
            assetPath,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 80,
          ),
          Positioned(
            left: 16.0,
            top: 16.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
