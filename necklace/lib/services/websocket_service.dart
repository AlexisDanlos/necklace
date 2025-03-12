import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/material.dart';

class WebSocketService {
  WebSocketChannel? channel;
  final void Function(String) onDataReceived;
  final void Function(List<int>) onAudioData;
  final void Function(String) onError;
  final void Function() onConnectionClosed;

  WebSocketService({
    required this.onDataReceived,
    required this.onAudioData,
    required this.onError,
    required this.onConnectionClosed,
  });

  Future<void> connect(String ip, String port) async {
    try {
      final wsUrl = 'ws://$ip:$port';
      channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      channel!.stream.listen(
        (data) {
          if (data is List<int>) {
            onAudioData(data);
          } else {
            onDataReceived(data.toString());
          }
        },
        onError: (error) => onError('Connection error: $error'),
        onDone: onConnectionClosed,
      );
    } catch (e) {
      onError(e.toString());
    }
  }

  void sendGetCommand() {
    channel?.sink.add("GET\n");
  }

  void dispose() {
    channel?.sink.close();
  }
}
