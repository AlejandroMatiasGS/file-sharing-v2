import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:file_sharing_android/controllers/converter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:network_info_plus/network_info_plus.dart';

class SendPage extends StatefulWidget {
  final List<PlatformFile> files;
  const SendPage({super.key, required this.files});

  @override
  State<SendPage> createState() => _SendPageState();
}

class _SendPageState extends State<SendPage> {
  double progress = 0.0;
  final TextEditingController _controller = TextEditingController();

  void updateProgress(double p) {
    setState(() {
      progress = p;
    });
  }

  void sendFiles() async {
    int host = (int.tryParse(_controller.text)) ?? 0;

    if (host == 0) {
      return;
    }

    String ip = (await NetworkInfo().getWifiIP()) ?? '';

    if (ip == '') {
      return;
    }

    List<String> ipSplit = ip.split('.');
    ip = '${ipSplit[0]}.${ipSplit[1]}.${ipSplit[2]}.$host';

    try {
      Socket s = await Socket.connect(ip, 24500);
      int totalSize = 0;
      int totalFiles = 0;
      int totalBytesSent = 0;
      
      for (var file in widget.files) { totalSize += file.size; totalFiles++; }
      s.add(intToBytes(totalSize));
      s.add(intToBytes(totalFiles));

      for(var file in widget.files) {
        Uint8List jsonBytes = utf8.encode(jsonEncode({
          'name': file.name,
          'size': file.size
        }));
        List<int> jsonSizeBytes = intToBytes(jsonBytes.length);        
        Uint8List bytes = file.bytes!;

        s.add(jsonSizeBytes);
        s.add(jsonBytes);

        int bufferSize = 1024;
        int totalBytes = bytes.length;
        int bytesSent = 0;
        while(bytesSent < totalBytes) {
          int chunkSize = (bytesSent + bufferSize <= totalBytes) ? bufferSize : totalBytes - bytesSent;
          List<int> chunk = bytes.sublist(bytesSent, bytesSent + chunkSize);
          s.add(chunk);
          bytesSent += chunkSize;
          totalBytesSent += bytesSent;
          updateProgress((totalBytesSent * 100) / totalSize);
        }
      }
    } on SocketException {
      Fluttertoast.showToast(
          msg: 'Error al emparejar con el dispositivo',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16);
    } catch (e) {
      Fluttertoast.showToast(
          msg: 'Error en el proceso de envío',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            controller: _controller,
          ),
          const SizedBox(height: 25),
          ElevatedButton(
              onPressed: sendFiles,
              child: const Text('Enviar', style: const TextStyle(fontSize: 28))),
          const SizedBox(
            height: 25,
          ),
          LinearProgressIndicator(value: progress, minHeight: 10,)
        ],
      )),
    );
  }
}
