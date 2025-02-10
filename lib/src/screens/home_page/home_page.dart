import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:minio/models.dart';
import 'package:provider/provider.dart';
import 'package:s3_client/src/models/user.dart';
import 'package:s3_client/src/screens/search_page/search_page.dart';
import 'package:s3_client/src/screens/settings_page/settings_page.dart';
import 'package:s3_client/src/screens/start_page/start_page_view.dart';
import 'package:s3_client/src/screens/upload_file_page/upload_file_page.dart';
import 'package:s3_client/src/utils/backblaze_service.dart';
import 'package:s3_client/src/utils/s3_service.dart';
import 'package:s3_client/src/widgets/cloud_object/cloud_object.dart';
import 'package:s3_client/src/widgets/file_item/file_item.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {

  late BackblazeService _b2service;
  late List<Object> foundFiles;

  void requestFileUpload() {
    
    return;
  }

  @override
  void initState() {
    super.initState();
    
    _b2service = context.read<BackblazeService>();

    loadObjects();
    
  }

  Future<void> loadObjects() async {
    User currentUser = context.read<User>();
    List<Object> objects = await getAllBucketObjects(currentUser.username.toLowerCase());
    setState(() {
      foundFiles = objects;
    });
  }

  Future<List<Object>> getAllBucketObjects(String bucket) async{

      ListObjectsResult? list = await _b2service.fetchAllObjectsFromBucket(bucket);
      if (list != null)
      {
        list.objects.forEach((element) => print("$element\n"));
      }
      else{
        list = ListObjectsResult(objects: [], prefixes: []);
      }
      List<Object> objectsList =  list.objects;
      return objectsList;
  }

  
  @override
  Widget build(BuildContext context) {
    User loggedUser = context.read<User>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(onPressed: () =>
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context)=> const SearchPageWidget())
                ),
              
              icon: const Icon(Icons.search)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          //ScaffoldMessenger.of(context).showSnackBar(
          //const SnackBar(content: Text('File successfully uploaded')),
          //)

          
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context)=> const UploadFilePage())
                )
        },
        tooltip: "Upload File",
        backgroundColor: const Color.fromARGB(150, 210, 100, 10),
        child: const Icon(Icons.add)
      ),
      
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.orange,
                gradient: LinearGradient(colors: [
            Color.fromARGB(255, 220, 130, 25),
            Color.fromARGB(255, 23, 22, 22)
          ])
              ),
              child: Text("Menu",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24
              )),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context)=> const SettingsPageWidget())
                );
              },
            ),
            ListTile(
                leading: const Icon(Icons.upload_file),
              title: const Text("Upload File"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context)=> const UploadFilePage())
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Log Out"),
              onTap: () {
                loggedUser.logout();
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context)=> const StartPageWidget())
                );
              },
            ),
          ],
        )
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
            child: foundFiles.isEmpty
                ? const Center(
                    child: Text("No files found."),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                      childAspectRatio: 2.0,
                    ),
                    itemCount: foundFiles.length,
                    itemBuilder: (context, index) {
                      return CloudObject(
                        eTag: foundFiles[index].eTag,
                        size: foundFiles[index].size,
                        owner: foundFiles[index].owner,
                        lastModified: foundFiles[index].lastModified,
                        fileName: foundFiles[index].key.toString(),
                        onDownload: (){},
                        onDelete: (){

                          setState(() {
                            foundFiles.removeAt(index);
                          });
                        },
                        border: Border.all(
                          color: const Color.fromARGB(125, 226, 158, 11),
                          width: 1.25,
                          ),
                        borderRadius: BorderRadius.circular(20.0),
                      );
                    },
                  ),
          ),
            ],
          ),
        ),
      ),
    );
  }
}