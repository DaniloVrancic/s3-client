import 'package:flutter/material.dart';
import 'package:minio/models.dart';
import 'package:provider/provider.dart';
import 'package:s3_client/src/models/change_follower.dart';
import 'package:s3_client/src/models/user.dart';
import 'package:s3_client/src/utils/backblaze_service.dart';
import 'package:s3_client/src/widgets/cloud_object/cloud_object.dart';

class DirectoryPageWidget extends StatefulWidget {

  final String prefix;

  const DirectoryPageWidget({
    super.key,
    required this.prefix
    });

  @override
  State<DirectoryPageWidget> createState() => _DirectoryPageWidgetState();
}

class _DirectoryPageWidgetState extends State<DirectoryPageWidget> with SingleTickerProviderStateMixin  {

  late BackblazeService _b2service;
  late List<Object> foundFiles = [];
  late String userBucket;
  late User loggedUser;
  late ChangeFollower changeFollower;

  void requestFileUpload() {
    
    return;
  }

  late Map<String, CloudObjectController> _controllers;
  bool _isReloading = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    
    _b2service = context.read<BackblazeService>();
    
    loggedUser = context.read<User>();
    userBucket = loggedUser.username.toLowerCase();
    _controllers = {};
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _reloadObjects(); // Initial loading of objects
    
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

    Future<List<Object>> getAllBucketObjects(String bucket, {String prefix = ""}) async{

      ListObjectsResult? list = await _b2service.fetchAllObjectsFromBucket(bucket, prefix: prefix);
      list ??= ListObjectsResult(objects: [], prefixes: []); 
      
      List<Object> objectsList =  list.objects;

    
      return objectsList;
  }

    Future<void> loadObjects() async {
    List<Object> objects = await getAllBucketObjects(userBucket, prefix: widget.prefix);
    
    setState(() {
      foundFiles = objects;
    });
  }

    Future<void> _reloadObjects() async {
    if (_isReloading) return; // Guard against repeated presses.
    setState(() {
      _isReloading = true;
    });
    _animationController.repeat();
    
    try{
      await loadObjects();
    }
    finally{
      _animationController.stop();
      setState(() {
        _isReloading = false;
      });
    }
    
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Directory"),
      ),
      body: Center(

        child: Text("Hiya ^_^"),
      ),
    );
  }
}