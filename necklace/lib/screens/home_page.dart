import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/config_dialogs.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _apiService = ApiService();
  
  String _deviceStatus = "Not Connected";
  bool _isConnecting = false;
  String _deviceIp = '';
  String _devicePort = '80'; // Default HTTP port for ESP32
  String _serverIp = '';
  String _serverPort = '';
  String _apiStatus = '';
  bool _isRecordingAudio = false;
  List<int> _audioBuffer = [];
  String _transcription = "";

  Future<void> _checkDeviceConnection() async {
    if (_deviceIp.isEmpty || _devicePort.isEmpty) {
      setState(() => _deviceStatus = 'Please configure device IP first');
      return;
    }

    setState(() => _isConnecting = true);
    try {
      await _apiService.checkConnection(_deviceIp, _devicePort, isESP32: true);
      setState(() => _deviceStatus = 'Connected to $_deviceIp');
    } catch (e) {
      setState(() => _deviceStatus = 'Error: $e');
    } finally {
      setState(() => _isConnecting = false);
    }
  }

  Future<void> _getAudioFromDevice() async {
    if (_deviceIp.isEmpty || _devicePort.isEmpty) {
      setState(() => _deviceStatus = 'Please configure device first');
      return;
    }

    setState(() {
      _isRecordingAudio = true;
      _audioBuffer = [];
      _transcription = "";
      _deviceStatus = 'Starting recording...';
    });

    try {
      // First, start recording
      await _apiService.startRecording(_deviceIp, _devicePort);
      setState(() => _deviceStatus = 'Recording completed, downloading...');

      // Then, download the audio
      final audioData = await _apiService.downloadAudio(_deviceIp, _devicePort);
      setState(() {
        _audioBuffer = audioData;
        _deviceStatus = 'Audio downloaded successfully';
      });
    } catch (e) {
      setState(() => _deviceStatus = 'Error: $e');
    } finally {
      setState(() => _isRecordingAudio = false);
    }
  }

  Future<void> _transcribeAudio() async {
    if (_serverIp.isEmpty || _serverPort.isEmpty) {
      setState(() => _apiStatus = 'Please configure server first');
      return;
    }

    setState(() => _apiStatus = 'Sending audio for transcription...');
    try {
      final transcription = await _apiService.sendAudioForTranscription(
        _audioBuffer,
        _serverIp,
        _serverPort,
      );
      setState(() {
        _transcription = transcription;
        _apiStatus = 'Transcription received';
      });
    } catch (e) {
      setState(() => _apiStatus = 'Error: $e');
    }
  }

  Future<void> _showDeviceConfigDialog() async {
    final result = await ConfigDialogs.showDeviceConfig(
      context,
      _deviceIp,
      _devicePort,
    );
    if (result != null) {
      setState(() {
        _deviceIp = result['ip']!;
        _devicePort = result['port']!;
      });
      _checkDeviceConnection();
    }
  }

  Future<void> _showServerConfigDialog() async {
    final result = await ConfigDialogs.showServerConfig(
      context,
      _serverIp,
      _serverPort,
    );
    if (result != null) {
      setState(() {
        _serverIp = result['ip']!;
        _serverPort = result['port']!;
        _apiStatus = 'Checking connection...';
      });
      
      try {
        await _apiService.checkConnection(_serverIp, _serverPort);
        setState(() => _apiStatus = 'Connected');
      } catch (e) {
        setState(() => _apiStatus = 'Error: $e');
      }
    }
  }

  Future<void> _sendAudioToAPI() async {
    if (_audioBuffer.isEmpty || _serverIp.isEmpty || _serverPort.isEmpty) {
      setState(() => _apiStatus = 'No audio data or server not configured');
      return;
    }

    setState(() => _apiStatus = 'Sending audio...');
    try {
      final transcription = await _apiService.sendAudioForTranscription(
        _audioBuffer,
        _serverIp,
        _serverPort,
      );
      setState(() {
        _transcription = transcription;
        _apiStatus = 'Transcription received';
        _isRecordingAudio = false;
      });
    } catch (e) {
      setState(() {
        _apiStatus = 'Error: $e';
        _isRecordingAudio = false;
      });
    }
  }

  Future<void> _checkApiConnection() async {
    if (_serverIp.isEmpty || _serverPort.isEmpty) {
      setState(() => _apiStatus = 'Please configure server first');
      return;
    }

    try {
      await _apiService.checkConnection(_serverIp, _serverPort);
      setState(() => _apiStatus = 'Connected');
    } catch (e) {
      setState(() => _apiStatus = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6C63FF), Color(0xFF4CAF50)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                Expanded(
                  child: GlassmorphicContainer(
                    width: double.infinity,
                    height: double.infinity,
                    borderRadius: 20,
                    blur: 20,
                    alignment: Alignment.bottomCenter,
                    border: 2,
                    linearGradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.05),
                      ],
                    ),
                    borderGradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.3),
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildConnectionStatus(),
                          const SizedBox(height: 32),
                          _buildActionButtons(),
                          if (_deviceStatus.isNotEmpty)
                            _buildStatusCard(_deviceStatus),
                          const SizedBox(height: 16),
                          if (_apiStatus.isNotEmpty)
                            _buildStatusCard(_apiStatus),
                          if (_transcription.isNotEmpty)
                            _buildTranscriptionCard(),
                        ].animate(interval: 100.ms).fadeIn(duration: 500.ms).slideX(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Row(
          children: [
            _buildConfigButton(
              icon: Icons.devices,
              label: 'Device',
              onTap: _showDeviceConfigDialog,
            ),
            const SizedBox(width: 8),
            _buildConfigButton(
              icon: Icons.cloud,
              label: 'Server',
              onTap: _showServerConfigDialog,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConfigButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GlassmorphicContainer(
      width: 48,
      height: 48,
      borderRadius: 12,
      blur: 10,
      border: 1,
      linearGradient: LinearGradient(
        colors: [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.1)],
      ),
      borderGradient: LinearGradient(
        colors: [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.1)],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onTap,
        tooltip: label,
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildConnectionStatusItem(
            icon: Icons.speaker_phone,
            title: 'ESP32 Device',
            status: _deviceIp.isEmpty 
              ? 'Not Configured'
              : _isConnecting 
                ? 'Connecting...'
                : _deviceStatus.contains('Error')
                  ? 'Connection Failed'
                  : 'Connected to $_deviceIp:$_devicePort',
            isConnected: _deviceIp.isNotEmpty && !_isConnecting && !_deviceStatus.contains('Error'),
          ),
          const Divider(color: Colors.white24, height: 24),
          _buildConnectionStatusItem(
            icon: Icons.cloud,
            title: 'Transcription Server',
            status: _serverIp.isEmpty 
              ? 'Not Configured'
              : _apiStatus.contains('Error')
                ? 'Connection Failed'
                : 'Connected to $_serverIp:$_serverPort',
            isConnected: _serverIp.isNotEmpty && _apiStatus == 'Connected',
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatusItem({
    required IconData icon,
    required String title,
    required String status,
    required bool isConnected,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isConnected ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isConnected ? Colors.greenAccent : Colors.redAccent,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                status,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Icon(
          isConnected ? Icons.check_circle : Icons.error,
          color: isConnected ? Colors.greenAccent : Colors.redAccent,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _getAudioFromDevice,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Theme.of(context).primaryColor,
            minimumSize: const Size(double.infinity, 56),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mic),
              const SizedBox(width: 8),
              Text(_isRecordingAudio ? "Recording..." : "Get Audio"),
            ],
          ),
        ),
        if (_audioBuffer.isNotEmpty && !_isRecordingAudio)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: ElevatedButton(
              onPressed: _transcribeAudio,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.translate),
                  SizedBox(width: 8),
                  Text("Transcribe Audio"),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusCard(String status) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.white.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                status,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTranscriptionCard() {
    return Card(
      margin: const EdgeInsets.only(top: 24),
      color: Colors.white.withOpacity(0.15),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Transcription",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _transcription,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
