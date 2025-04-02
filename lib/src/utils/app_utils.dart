import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:s3_client/src/models/bucket_notifier.dart';
import 'package:s3_client/src/models/user.dart';

class AppUtils {
  

  
  static String getBucketFromContext(BuildContext context) {
    User loggedUser = context.read<User>();
    String userBucket = "${loggedUser.username.toLowerCase()}-b2---${loggedUser.username.toLowerCase()}";
    return userBucket;
  }

  static getSelectedBucketFromContext(BuildContext context){
    BucketNotifier selectedBucket = context.read<BucketNotifier>();
    return selectedBucket!.selectedBucket;
  }
}