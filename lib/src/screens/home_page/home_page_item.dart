import 'package:s3_client/src/models/proxy_object.dart';

enum HomePageItemType { directory, object }

class HomePageItem {
  final HomePageItemType type;
  final ProxyObject? object;
  final String? directoryName;

  HomePageItem.directory(this.directoryName)
      : type = HomePageItemType.directory,
        object = null;

  HomePageItem.object(this.object)
      : type = HomePageItemType.object,
        directoryName = null;
}