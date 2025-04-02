import 'package:flutter/material.dart';
import 'package:minio/minio.dart';
import 'package:minio/models.dart';
import 'package:provider/provider.dart';
import 'package:s3_client/src/models/bucket_notifier.dart';

import 'package:s3_client/src/utils/backblaze_service.dart';
import 'package:s3_client/src/utils/snackbar_shower.dart';
import 'package:s3_client/src/widgets/cloud_bucket/cloud_bucket.dart';

class BucketsPage extends StatefulWidget {
  const BucketsPage({super.key});

  @override
  State<BucketsPage> createState() => _BucketsPageState();
}

class _BucketsPageState extends State<BucketsPage> with SingleTickerProviderStateMixin {
  //List<Map<String, dynamic>> foundBuckets = [];
  List<Bucket> myFoundBuckets = [];
  BucketNotifier? _selectedBucket;
  late BackblazeService _b2service;

  bool _isReloading = false;
  late AnimationController _animationController;



  @override
  void initState() {
    super.initState();
    _b2service = context.read<BackblazeService>();
    _selectedBucket = context.read<BucketNotifier>();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _reloadBuckets();
  }

  Future<void> _fetchBuckets() async {
    List<Bucket> tempFoundBuckets = await _b2service.listAllBuckets();
    setState(() {
      myFoundBuckets = tempFoundBuckets;
    });
  }

  Future<void> _reloadBuckets() async {
    if (_isReloading) return; // Guard against repeated presses.
    setState(() {
      _isReloading = true;
    });
    _animationController.repeat();
    
    try{
      await _fetchBuckets();
    }
    finally{
      _animationController.stop();
      setState(() {
        _isReloading = false;
      });
    }
  }

  void _selectBucket(String bucketName, DateTime? creationDate) {
    setState(() {
      Bucket newBucket = Bucket(creationDate, bucketName);
      _selectedBucket!.setBucket(newBucket);
    });
  }

  void _deleteBucket(String bucketName) async {
    try{
    await _b2service.deleteBucket(bucket: bucketName);
    setState(() {
      myFoundBuckets.removeWhere((bucket) => bucket.name == bucketName);
      if (_selectedBucket!.selectedBucket.name == bucketName) {
        Bucket newBucket = Bucket(DateTime.now(), "");
        _selectedBucket!.setBucket(newBucket);
      }
    });
      SnackbarShower.showSnackbar(context: context, message: "Bucket deleted.", color: Colors.green.shade300);
    }
    on MinioError catch(e){
      if(e.message!.contains("bucket you tried to delete is not empty"))
      {
        SnackbarShower.showSnackbar(context: context, message: "The bucked you tried to delete is not empty.", color: Colors.red.shade400);
      }
      else{
        SnackbarShower.showSnackbar(context: context, message: "An error happened.", color: Colors.red.shade400);
      }
    }
    catch(e){
      SnackbarShower.showSnackbar(context: context, message: "An error happened.", color: Colors.red.shade400);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Bucket"),
        backgroundColor: Colors.orange[700],
        actions: [
          IconButton(onPressed: () async { await _reloadBuckets(); },
              
              icon: _isReloading 
                ? RotationTransition(
                    turns: _animationController,
                    child: const Icon(Icons.refresh),
                  )
                : const Icon(Icons.refresh),
              ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: myFoundBuckets.isEmpty
                    ? const Center(
                        child: Text(
                          "No buckets found.",
                          style: TextStyle(fontSize: 20.0),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(8.0),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: MediaQuery.of(context).size.width <= 830
                              ? (MediaQuery.of(context).size.width <= 506 ? 1 : 2)
                              : 3,
                          mainAxisSpacing: 5.0,
                          crossAxisSpacing: 10.0,
                          childAspectRatio: MediaQuery.of(context).size.width <= 830
                              ? (MediaQuery.of(context).size.width <= 506 ? 1.1 : 0.9)
                              : 0.7,
                        ),
                        itemCount: myFoundBuckets.length,
                        itemBuilder: (context, index) {
                          Bucket bucket = myFoundBuckets[index];
                          String bucketName = bucket.name;
                          DateTime? creationDate = bucket.creationDate;

                          return CloudBucket(
                            bucketName: bucketName,
                            creationDate: creationDate,
                            isSelected: _selectedBucket!.selectedBucket.name == bucketName,
                            onTap: () => _selectBucket(bucketName, creationDate),
                            onDelete: () => _deleteBucket(bucketName),
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