import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';

class ApiService {
  Future<void> checkConnection(String ip, String port, {bool isESP32 = false}) async {
    final endpoint = isESP32 ? '/' : '/';
    final response = await http.get(Uri.parse('http://$ip:$port$endpoint'));
    
    if (response.statusCode != 200) {
      throw Exception('Failed to connect: ${response.statusCode}');
    }
  }

  Future<String> sendAudioForTranscription(
    List<int> audioBuffer,
    String ip,
    String port,
  ) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/temp_audio.mp3');
    await file.writeAsBytes(audioBuffer);

    var uri = Uri.parse('http://$ip:$port/transcribe');
    var request = http.MultipartRequest('POST', uri);
    
    var multipartFile = await http.MultipartFile.fromPath(
      'file',
      file.path,
      contentType: MediaType('audio', 'mpeg'),
    );
    request.files.add(multipartFile);

    final response = await request.send();
    final responseData = await response.stream.bytesToString();
    final jsonResponse = jsonDecode(responseData);

    if (response.statusCode != 200) {
      throw Exception('Failed to transcribe: ${response.statusCode}');
    }

    return jsonResponse['transcription'] ?? '';
  }

  Future<String> getAndTranscribeAudio(String deviceIp, String devicePort, String serverIp, String serverPort) async {
    // Get audio from ESP32
    final response = await http.get(Uri.parse('http://$deviceIp:$devicePort/get_audio'));
    
    if (response.statusCode != 200) {
      throw Exception('Failed to get audio: ${response.statusCode}');
    }
    
    // Send audio to transcription server
    return sendAudioForTranscription(response.bodyBytes, serverIp, serverPort);
  }

  Future<void> startRecording(String deviceIp, String devicePort) async {
    final response = await http.get(Uri.parse('http://$deviceIp:$devicePort/record'));
    
    if (response.statusCode != 200) {
      throw Exception('Failed to start recording: ${response.statusCode}');
    }
  }

  Future<List<int>> downloadAudio(String deviceIp, String devicePort) async {
    final response = await http.get(Uri.parse('http://$deviceIp:$devicePort/download'));
    
    if (response.statusCode != 200) {
      throw Exception('Failed to download audio: ${response.statusCode}');
    }
    
    return response.bodyBytes;
  }
}
