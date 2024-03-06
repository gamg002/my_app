class Userpassword {
  String? email;
  String? password;
  String? role;
  String? name;

  Userpassword({this.email, this.password, this.role, this.name});

  Userpassword.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    password = json['password'];
    role = json['role'];
    name = json['name'];
  }

  
}
