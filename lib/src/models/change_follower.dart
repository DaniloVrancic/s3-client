class ChangeFollower {
  late bool needToGetObjects;

  ChangeFollower(){ //Simple object container class just to optimize the fetching and getting from the client that will be done
    needToGetObjects = true;
  }
}