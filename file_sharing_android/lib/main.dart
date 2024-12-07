import 'package:file_sharing_android/screens/send_page.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'File Sharing',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const HomePage());
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {

    Future<void> goToSendPage() async {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(allowMultiple: true);

      if (result != null && context.mounted) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SendPage(files: result.files)));
      }
    }

    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
              onPressed: goToSendPage,
              style: ElevatedButton.styleFrom(minimumSize: const Size(200, 80)),
              child: const Text('Enviar', style: TextStyle(fontSize: 28))),
          const SizedBox(height: 40),
          ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(minimumSize: const Size(200, 80)),
              child: const Text('Recibir', style: TextStyle(fontSize: 28)))
        ],
      ),
    ));
  }
}
