// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class VoiceRecordingService {
  FlutterSoundRecorder? _recorder;
  bool _isRecorderInitialized = false;
  String? _recordingPath;

  VoiceRecordingService() {
    _recorder = FlutterSoundRecorder();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    try {
      await _recorder!.openRecorder();
      _isRecorderInitialized = true;
    }
    catch(e) {
      print("Error: $e");
    }
  }

  Future<bool> requestMicrophonePermission() async {
    var status = await Permission.microphone.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied || status.isRestricted || status.isPermanentlyDenied) {
      final result = await Permission.microphone.request();
      if (result.isGranted) return true;
      if (result.isPermanentlyDenied) {
      }
    }

    return false;
  }

  Future<String?> startRecording() async {
    if (!_isRecorderInitialized) {
      await _initializeRecorder();
      if (!_isRecorderInitialized) return null;
    }

    final hasPermission = await requestMicrophonePermission();
    if (!hasPermission) {
      return null;
    }

    final Directory tempDir = await getTemporaryDirectory();
    final String filePath = "${tempDir.path}/sou_chef_recording_${DateTime.now().millisecondsSinceEpoch}.aac";
    _recordingPath = filePath;

    try {
      await _recorder!.startRecorder(
        toFile: filePath,
        codec: Codec.aacADTS,
      );
      return filePath;
    }

    catch (e) {
      _recordingPath = null;
      return null;
    }
  }

  Future<String?> stopRecording() async {
    if (!_isRecorderInitialized || !_recorder!.isRecording) {
      return null;
    }

    try {
      await _recorder!.stopRecorder();
      final tempPath = _recordingPath;
      _recordingPath = null;
      return tempPath;
    }
    catch (e) {
      return null;
    }
  }

  Future<String?> uploadAudio(String filePath) async {
    final url = Uri.parse("http://10.0.2.2:8000/api/v1/transcribe/");

    try {
      var request = http.MultipartRequest('POST', url);
      request.files.add(
        await http.MultipartFile.fromPath(
          'audio',
          filePath, 
          contentType: MediaType('audio', 'aac'),
        ),
      );

      var streamedResponse = await request.send();

      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String? transcribedText = responseData['text'];

        try {
          final file = File(filePath);
          if (await file.exists()) {
            await file.delete();
          }
        }
        catch (e) {
          print("Error deleting file: $e");
        }

        return transcribedText;
      }
      else {
        return null;
      }
    }

    catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<void> dispose() async {
    if (_recorder != null) {
      await _recorder!.closeRecorder();
      _recorder = null;
      _isRecorderInitialized = false;
    }
  }
}