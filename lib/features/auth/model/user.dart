class User {
  User({
    String? userID,
    String? userEmail,
    String? userSignInName,
    String? userPasswordHashSalt,
    String? userName,
    String? userPhone,
    String? userGroupIdentifier,
    String? userGroupName,
    String? userGroupWeight,}){
    _userID = userID;
    _userEmail = userEmail;
    _userSignInName = userSignInName;
    _userPasswordHashSalt = userPasswordHashSalt;
    _userName = userName;
    _userPhone = userPhone;
    _userGroupIdentifier = userGroupIdentifier;
    _userGroupName = userGroupName;
    _userGroupWeight = userGroupWeight;
  }

  User.fromJson(dynamic json) {
    _userID = json['UserID'];
    _userEmail = json['UserEmail'];
    _userSignInName = json['UserSignInName'];
    _userPasswordHashSalt = json['UserPasswordHashSalt'];
    _userName = json['UserName'];
    _userPhone = json['UserPhone'];
    _userGroupIdentifier = json['UserGroupIdentifier'];
    _userGroupName = json['UserGroupName'];
    _userGroupWeight = json['UserGroupWeight'];
  }
  String? _userID;
  String? _userEmail;
  String? _userSignInName;
  String? _userPasswordHashSalt;
  String? _userName;
  String? _userPhone;
  String? _userGroupIdentifier;
  String? _userGroupName;
  String? _userGroupWeight;

  String? get userID => _userID;
  String? get userEmail => _userEmail;
  String? get userSignInName => _userSignInName;
  String? get userPasswordHashSalt => _userPasswordHashSalt;
  String? get userName => _userName;
  String? get userPhone => _userPhone;
  String? get userGroupIdentifier => _userGroupIdentifier;
  String? get userGroupName => _userGroupName;
  String? get userGroupWeight => _userGroupWeight;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['UserID'] = _userID;
    map['UserEmail'] = _userEmail;
    map['UserSignInName'] = _userSignInName;
    map['UserPasswordHashSalt'] = _userPasswordHashSalt;
    map['UserName'] = _userName;
    map['UserPhone'] = _userPhone;
    map['UserGroupIdentifier'] = _userGroupIdentifier;
    map['UserGroupName'] = _userGroupName;
    map['UserGroupWeight'] = _userGroupWeight;
    return map;
  }

}