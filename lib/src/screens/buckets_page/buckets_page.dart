import 'package:flutter/material.dart';
import 'package:s3_client/src/widgets/cloud_bucket/cloud_bucket.dart';

class BucketsPage extends StatefulWidget {
  const BucketsPage({super.key});

  @override
  State<BucketsPage> createState() => _BucketsPageState();
}

class _BucketsPageState extends State<BucketsPage> {
  List<Map<String, dynamic>> foundBuckets = [];
  String? selectedBucket;

  @override
  void initState() {
    super.initState();
    _fetchBuckets();
  }

  void _fetchBuckets() {
    setState(() {
      foundBuckets = [
        {"name": "Bucket A", "creationDate": DateTime.now().subtract(const Duration(days: 10))},
        {"name": "Bucket B", "creationDate": DateTime.now().subtract(const Duration(days: 20))},
        {"name": "Bucket C", "creationDate": DateTime.now().subtract(const Duration(days: 30))},
      ];
    });
  }

  void _selectBucket(String bucketName) {
    setState(() {
      selectedBucket = bucketName;
    });
  }

  void _deleteBucket(String bucketName) {
    setState(() {
      foundBuckets.removeWhere((bucket) => bucket["name"] == bucketName);
      if (selectedBucket == bucketName) {
        selectedBucket = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Bucket"),
        backgroundColor: Colors.orange[700],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: foundBuckets.isEmpty
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
                        itemCount: foundBuckets.length,
                        itemBuilder: (context, index) {
                          var bucket = foundBuckets[index];
                          String bucketName = bucket["name"];
                          DateTime? creationDate = bucket["creationDate"];

                          return CloudBucket(
                            bucketName: bucketName,
                            creationDate: creationDate,
                            isSelected: selectedBucket == bucketName,
                            onTap: () => _selectBucket(bucketName),
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