import 'package:flutter/material.dart';

class ConfigDialogs {
  static Future<Map<String, String>?> showDeviceConfig(
    BuildContext context,
    String currentIp,
    String currentPort,
  ) {
    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        String tempIp = currentIp;
        String tempPort = currentPort;
        
        return AlertDialog(
          title: const Text('Device Configuration'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Device IP'),
                onChanged: (value) => tempIp = value,
                controller: TextEditingController(text: currentIp),
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Device Port (default: 81)'),
                onChanged: (value) => tempPort = value,
                controller: TextEditingController(text: currentPort),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(
                context,
                {'ip': tempIp, 'port': tempPort},
              ),
              child: const Text('Connect'),
            ),
          ],
        );
      },
    );
  }

  static Future<Map<String, String>?> showServerConfig(
    BuildContext context,
    String currentIp,
    String currentPort,
  ) {
    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        String tempIp = currentIp;
        String tempPort = currentPort;
        
        return AlertDialog(
          title: const Text('Server Configuration'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Server IP'),
                onChanged: (value) => tempIp = value,
                controller: TextEditingController(text: currentIp),
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Server Port'),
                onChanged: (value) => tempPort = value,
                controller: TextEditingController(text: currentPort),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(
                context,
                {'ip': tempIp, 'port': tempPort},
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
