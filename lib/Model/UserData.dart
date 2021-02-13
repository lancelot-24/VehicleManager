class UserData {
  final String name;
  final int uid;

  UserData({this.name, this.uid});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'uid': uid,
    };
  }
}
