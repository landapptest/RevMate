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

  // 이미지 업로드 후 OCR 적용 로직
  Future<void> _uploadImageAndRunOCR(File imageFile) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. 이미지 업로드
      await _reserveController.uploadImage(imageFile);

      // 2. 이미지 업로드 후 OCR 처리
      final ocrText = await _reserveController.runOCR(imageFile.path);
      setState(() {
        _ocrText = ocrText;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _ocrText = '이미지 업로드 및 OCR 실패: $e';
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
            DropdownButton<String>(
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
            const SizedBox(height: 24.0),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('STEP2 도면 등록', style: headerTextStyle),
            ),
            ElevatedButton(
              onPressed: () async {
                final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  // 3. 업로드 및 OCR 실행
                  await _uploadImageAndRunOCR(File(pickedFile.path));
                }
              },
              child: const Text('도면 이미지 선택'),
            ),
            if (_isLoading) const CircularProgressIndicator(),
            if (_ocrText != null) Text('인식된 출력 예상시간: $_ocrText'),
            const SizedBox(height: 24.0),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('STEP3 예약 옵션 선택', style: headerTextStyle),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_selectedEquipment != null && _ocrText != null) {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => AvailableTimesPage(
                          equipment: _selectedEquipment!,
                          duration: int.parse(_ocrText!.split(':')[0]),
                        ),
                      ));
                    }
                  },
                  child: const Text('가장 빠른 일자'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_selectedEquipment != null && _ocrText != null) {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => DeadlineWidget(
                          equipment: _selectedEquipment!,
                          ocrText: _ocrText!,
                        ),
                      ));
                    }
                  },
                  child: const Text('마감 우선'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_selectedEquipment != null && _ocrText != null) {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => RevisedPage(
                          equipment: _selectedEquipment!,
                        ),
                      ));
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
