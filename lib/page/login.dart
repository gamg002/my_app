import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:my_app/data/userlogin.dart';
import 'package:my_app/page/calculation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  List<Userpassword> listUser = [];
  final userController = TextEditingController();
  final passwordController = TextEditingController();
  int indexList = 0;
  late bool userSuccess = false;

  @override
  void initState() {
    fetchUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              HeaderScreen(),
              ImageZone(),
              UserLogin(),
              PasswordLogin(),
              ButtonSubmit(),
            ],
          ),
        ),
      ),
    );
  }

  HeaderScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 0),
          child: Container(
            width: double.maxFinite,
            height: 90,
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40)),
                color: Colors.blue),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const SizedBox(height: 10),
              Image.asset(
                'assets/ic_logo.png',
                scale: 8,
              )
            ]),
          ),
        ),
      ],
    );
  }

  ImageZone() {
    return Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Container(
        height: 190,
        width: 190,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset(
            'assets/ic_logo.png',
          )
        ]),
      ),
    );
  }

  UserLogin() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 40),
      child: Container(
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(40)),
            color: Colors.blue),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 10),
            child: TextField(
              controller: userController,
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.center,
              maxLines: 1,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelStyle: TextStyle(color: Colors.white),
                labelText: 'ID',
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ),
    );
  }

  PasswordLogin() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(width: 1),
            borderRadius: BorderRadius.all(Radius.circular(40)),
            color: Colors.white),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 20, right: 10),
              child: TextField(
                obscureText: true,
                controller: passwordController,
                textAlign: TextAlign.center,
                textAlignVertical: TextAlignVertical.center,
                maxLines: 1,
                decoration: const InputDecoration(
                  labelText: 'PASSWORD',
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ButtonSubmit() {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Center(
        child: Container(
          height: 25,
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(40)),
              color: Colors.blue),
          child: MaterialButton(
            height: 10,
            minWidth: 30,
            onPressed: (() {
              checkEmtyText();
            }),
            textColor: Colors.white,
            child: const Text('Log in'),
          ),
        ),
      ),
    );
  }

  Future checkDataSharedPreferences() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var emailLogin = preferences.getString('prefs_email');

    if (emailLogin != null || emailLogin?.isEmpty == false) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const Calculation()));
    }
  }

  Future<List<Userpassword>> fetchUsers() async {
    String url =
        "https://script.google.com/macros/s/AKfycbychSNTYEaX1wzppFLQecSHAiczcl6Hvzyy4q5S-Q5WdmIZB6S2O5Fxu_FJLBxdCq3qiA/exec";

    final response = await http.get(Uri.parse(url));
    var result = jsonDecode(response.body.toString());

    if (response.statusCode == 200) {
      for (Map<String, dynamic> index in result) {
        listUser.add(Userpassword.fromJson(index));
      }

      return listUser;
    } else {
      return listUser;
    }
  }

  void checkLoginUser() {
    for (var i = 0; i < listUser.length; i++) {
      if (listUser[i].email == userController.text) {
        if (listUser[i].password == passwordController.text) {
          navigateToCalculation(i);
        } else {
          getShowErrorDialog('รหัสไม่ถูกต้อง', 'ตกลง', false);
        }
      } else {
        indexList++;
        if (indexList == listUser.length) {
          getShowErrorDialog('" ID " ไม่ถูกต้อง', 'ตกลง', false);
        }
      }
    }
  }

  void checkEmtyText() {
    if (userController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      getShowErrorDialog('กรุณากรอกข้อมูลให้ครบถ้วน', 'ตกลง', false);
    } else {
      indexList = 0;
      checkLoginUser();
    }
  }

  Future navigateToCalculation(int i) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('prefs_email', '${listUser[i].email}');
    preferences.setString('prefs_name', '${listUser[i].name}');
    preferences.setString('prefs_role', '${listUser[i].role}');

    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const Calculation()));
  }

  getShowErrorDialog(
    String description,
    String button,
    bool isCancle,
  ) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shadowColor: Colors.red,
        actionsAlignment: MainAxisAlignment.center,
        title: Image.asset(
          'assets/ic_error.png',
          height: 70,
          width: 70,
        ),
        content: Container(
          height: 30,
          alignment: Alignment.center,
          child: Text(
            description,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            style: ButtonStyle(
              side: MaterialStateProperty.all<BorderSide>(
                  const BorderSide(color: Colors.blue, width: 2)),
            ),
            onPressed: () => Navigator.pop(context, 'OK'),
            child: Text(
              button,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: isCancle,
    );
  }
}
