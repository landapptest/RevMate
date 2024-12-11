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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OCR 처리 중 오류 발생: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToPage(Widget page) {
    try {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => page));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('페이지 이동 중 오류 발생: $e')),
      );
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
                if (_selectedEquipment != null && _ocrText != null && _processedFile != null) {
                  _navigateToPage(AvailableTimesPage(
                    equipment: _selectedEquipment!,
                    duration: int.parse(_ocrText!.split(':')[0]),
                  ));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('장비와 OCR 데이터가 필요합니다.')),
                  );
                }
              },
            ),
            _buildOptionButton(
              '마감 우선', '마감일에 맞춰 자동으로 예약합니다.', 'assets/deadline_icon.png',
                  () {
                if (_selectedEquipment != null && _ocrText != null && _processedFile != null) {
                  _navigateToPage(DeadlineWidget(
                    equipment: _selectedEquipment!,
                    ocrText: _ocrText!,
                  ));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('장비와 OCR 데이터가 필요합니다.')),
                  );
                }
              },
            ),
            _buildOptionButton(
              '자율', '자유롭게 날짜를 선택합니다.', 'assets/reivese_icon.png',
                  () {
                if (_selectedEquipment != null && _ocrText != null && _processedFile != null) {
                  _navigateToPage(RevisedPage(
                    equipment: _selectedEquipment!,
                  ));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('장비와 OCR 데이터가 필요합니다.')),
                  );
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
