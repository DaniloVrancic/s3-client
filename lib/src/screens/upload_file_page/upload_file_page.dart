import 'package:flutter/material.dart';

class UploadFilePage extends StatefulWidget {
  const UploadFilePage({super.key});

  @override
  State<UploadFilePage> createState() => _UploadFilePageState();
}

class _UploadFilePageState extends State<UploadFilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload File"),),
      body: 
      SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: Row(children: [
            ElevatedButton(onPressed: (){}, child: const Text("Select a File")),
            const SizedBox(width: 20.0,),
            ElevatedButton(onPressed: (){}, child: const Text("Upload File"))
          ],),
        ),
      ),
    );
  }
}