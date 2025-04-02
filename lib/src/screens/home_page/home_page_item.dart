import 'package:minio/models.dart';

enum HomePageItemType { directory, object }

class HomePageItem {
  final HomePageItemType type;
  final Object? object;
  final String? directoryName;

  HomePageItem.directory(this.directoryName)
      : type = HomePageItemType.directory,
        object = null;

  HomePageItem.object(this.object)
      : type = HomePageItemType.object,
        directoryName = null;
}