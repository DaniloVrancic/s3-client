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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
            ElevatedButton(onPressed: (){},
            style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Color.fromARGB(255, 250, 150, 20),),
                        textStyle: WidgetStatePropertyAll(TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16.0,
                        color: Colors.black
                      ),),
                        padding: WidgetStatePropertyAll(EdgeInsets.only(top: 24.0, bottom: 24.0, left: 30.0, right: 30.0))
                      ), 
            child: const Text("Select a File")),
            const SizedBox(width: 20.0,),
            ElevatedButton(onPressed: (){}, 
            style: const ButtonStyle(
                        textStyle: WidgetStatePropertyAll(TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16.0,
                        
                      ),),
                        padding: WidgetStatePropertyAll(EdgeInsets.only(top: 24.0, bottom: 24.0, left: 30.0, right: 30.0))
                      ),
            child: const Text("Upload File"))
          ],),
        ),
      ),
    );
  }
}