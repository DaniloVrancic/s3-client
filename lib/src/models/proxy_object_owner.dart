class Owner {
  Owner(
    this.displayName,
    this.id,
  );

  Owner.fromJSON(Map<String, dynamic> json) {
    displayName = json['displayName'];
    id = json['id'];
  }

  /// Container for the display name of the owner.
  String? displayName;

  /// Container for the ID of the owner.
  String? id;
}