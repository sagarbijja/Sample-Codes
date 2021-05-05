import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:online_appointment/screens/auth/payment_mode.dart';
import 'package:online_appointment/services/api_requester.dart';
import 'package:online_appointment/services/authservice.dart';
import 'package:online_appointment/widgets/pincode.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:online_appointment/widgets/transition.dart';
import 'dart:io';
import 'package:dio/dio.dart';

import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:image_picker/image_picker.dart';

import 'package:path/path.dart' as path;

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

enum MarriedStatus { Married, Unmarried }

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController nameController = new TextEditingController();
  TextEditingController phoneController = new TextEditingController();
  TextEditingController ageController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController _dateTextController = new TextEditingController();

  DateTime dob;
  bool _obscureText = true;
  bool isTermsAccepted = false;
  DateTime selectedDate = DateTime.now();
  String _dob = "Select Date of Birth";
  String city = "Select City";
  String state = "Select State";
  String bloodgrp = "Select Blood Group";
  String gender = "Select Gender";
  String otptxt = "Get OTP";
  String resendtxt = "Resend in ";
  final RegExp namereg = RegExp(r"^[A-Za-z]+\s[A-Za-z]+\s[A-Za-z]+$");
  final RegExp mobreg = RegExp(r"[7-9]\d{9}");
  final RegExp mailreg = RegExp(r"^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+$");
  bool showOTP = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool codeSent = false;
  String phoneNo, verificationId, smsCode = '';
  String status = "OTP Sent to Your Mobile Number, Please Check.";
  String token;
  static const int timeOut = 60;
  bool verified = false;
  double space = 10;

  Map<String, Object> data;
  List<String> cityList = ["Select City"];
  List<String> stateList = ["Select State"];
  Map states = {};
  Timer _timer;
  int _start = timeOut;

  File _imageFile;
  final picker = ImagePicker();

  MarriedStatus marriedStatus = MarriedStatus.Unmarried;

  @override
  void initState() {
    super.initState();
    getStateCity();
  }

  void getStateCity() async {
    states = await Requester.getStateCity();
    if (states['status'] == "error") return;
    if (states['data'].length > 0) {
      stateList.clear();
      stateList.add("Select State");
      states['data'].forEach((key, value) {
        stateList.add(key);
      });
    }
    setState(() {});
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_start < 1) {
            timer.cancel();
            resendtxt = "Get OTP";
            codeSent = false;
            _start = timeOut;
          } else {
            _start = _start - 1;
            resendtxt = "Resend ($_start)";
          }
        },
      ),
    );
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

//  Image Upload Functions
  Future<File> compressImage(File file) async {
    // final dir = await path_provider.getTemporaryDirectory();
    print(
      file.absolute.path,
    );
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      "/storage/emulated/0/Android/data/com.example.online_appointment/files/Pictures/${DateTime.now().millisecondsSinceEpoch}.jpg",
      minHeight: 1920 ~/ 2,
      minWidth: 1080 ~/ 2,
      quality: 25,
    );

    print("FILE LENGHT : ${file.lengthSync() / 1024}");
    print("RESULT LENGHT : ${result.lengthSync() / 1024}");
    return result;
  }

  Future getImage(BuildContext context, {bool isCamera = false}) async {
    var pickedFile;
    if (isCamera)
      pickedFile = await picker.getImage(source: ImageSource.camera);
    else
      pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _imageFile = File(pickedFile.path);
      _imageFile = await compressImage(_imageFile);
    } else {
      print('No image selected.');
    }
    setState(() {});
  }

  void showUploadBottomSheet(BuildContext contextSf) {
    showModalBottomSheet(
        context: contextSf,
        builder: (context) => Container(
              padding: EdgeInsets.all(10),
              clipBehavior: Clip.hardEdge,
              height: 200,
              decoration: BoxDecoration(

                  borderRadius: BorderRadius.circular(15),
                  color: Colors.grey[100]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Choose Option",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  Divider(
                    thickness: 1,
                    color: Colors.blue,
                  ),
                  FlatButton.icon(
                      color: Colors.blue,
                      textColor: Colors.white,
                      onPressed: () {
                        getImage(contextSf, isCamera: true);
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.camera),
                      label: Text("Take a Photo")),
                  FlatButton.icon(
                      color: Colors.blue,
                      textColor: Colors.white,
                      onPressed: () {
                        getImage(contextSf);
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.image),
                      label: Text("Upload from Gallery")),
                ],
              ),
            ));
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1950, 8),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        dob = selectedDate;
        _dob = DateFormat('dd-MM-yyyy').format(selectedDate);
        _dateTextController.text = _dob;
      });
  }

  Future<void> verifyPhone(BuildContext context, String phone) async {
    final PhoneVerificationCompleted verified = (AuthCredential authResult) {
      print("Number Verfied");
      AuthService().signIn(authResult);
      setState(() {
        this.verified = true;
      });
      _timer.cancel();
    };

    final PhoneVerificationFailed verificationfailed =
        (FirebaseAuthException authException) {
      print('${authException.message}');
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text(authException.message)));
    };

    final PhoneCodeSent smsSent = (String verId, [int forceResend]) {
      this.verificationId = verId;
      print("Sms Sent");
      setState(() {
        this.codeSent = true;
      });
      startTimer();
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text('OTP Sent to registered mobile number')));
    };

    final PhoneCodeAutoRetrievalTimeout autoTimeout = (String verId) {
      this.verificationId = verId;
      print("Timeout Complete");
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('Timeout Resend OTP')));
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNo,
        timeout: const Duration(seconds: timeOut),
        verificationCompleted: verified,
        verificationFailed: verificationfailed,
        codeSent: smsSent,
        codeAutoRetrievalTimeout: autoTimeout);
  }

  void smsVerify(BuildContext context, String smscode) async {
    try {
      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: smsCode);

      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text('Mobile Number Verified Successfully')));
      await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);
      setState(() {
        _timer.cancel();
        this.verified = true;
        status = "Mobile Number Verified Successfully";
      });
      token = await FirebaseMessaging.instance.getToken();
      print("Your Token : $token");
    } catch (e) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Builder(
          builder: (context) => Form(
            key: _formKey,
            child: ListView(children: [
              //-----------------------Header------------------------------
              Container(
                padding: EdgeInsets.all(20),
                width: double.infinity,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        colors: [
                      Colors.blue[900],
                      Colors.blue[800],
                      Colors.blue[400]
                    ])),
                child: Text(
                  'Create Account',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(20, 5, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      child: Center(
                          child: GestureDetector(
                              onTap: () {
                                showUploadBottomSheet(context);
                              },
                              child: _imageFile == null
                                  ? CircleAvatar(
                                      backgroundColor: Colors.blue[100],
                                      radius: 100,
                                      child: Image.asset(
                                        "assets/icons/person.png",
                                        width: 100,
                                      ),
                                    )
                                  : CircleAvatar(
                                      radius: 100,
                                      backgroundImage: FileImage(
                                        _imageFile,
                                      )))),
                    ),
                    SizedBox(
                      height: space,
                    ),
//-----------------------Name------------------------------
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red, width: 2.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue[800], width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue[500], width: 2.0),
                        ),
                        hintText: "Enter Full Name",
                      ),
                      keyboardType: TextInputType.text,
                      validator: (String val) {
                        val = val.trim();
                        if (!namereg.hasMatch(val))
                          return 'Should be Full Name eg.FirstName MiddleName SirName';
                        else
                          return null;
                      },
                    ),
                    SizedBox(height: space),
                    Row(
                      children: [
                        Text(
                          "+91 ",
                          style: TextStyle(fontSize: 17),
                        ),
                        Expanded(
                          flex: 3,
//-----------------------Mobile------------------------------
                          child: TextFormField(
                            readOnly: verified,
                            controller: phoneController,
                            decoration: InputDecoration(
                              hintText: "Mobile Number",
                            ),
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            validator: (val) {
                              if (mobreg.hasMatch(val)) {
                                return null;
                              } else {
                                return "Enter Valid Mobile Number";
                              }
                            },
                            onChanged: (val) {
                              setState(
                                () {
                                  this.phoneNo = "+91" + val;
                                },
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          width: space,
                        ),
//-----------------------Get OTP / Verfied Button ------------------------------
                        Expanded(
                          flex: 2,
                          child: verified
                              ? Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.green,
                                  size: 40,
                                )
                              : codeSent
                                  ? RaisedButton(
                                      disabledColor: Colors.blue[400],
                                      child: Text(
                                        resendtxt,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onPressed: null)
                                  : RaisedButton(
                                      disabledColor: Colors.blue[400],
                                      color: Colors.blue,
                                      child: Text(
                                        otptxt,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onPressed: otptxt.startsWith("Sending")
                                          ? null
                                          : () {
                                              // if (_formKey.currentState.validate()) {
                                              if (mobreg.hasMatch(
                                                  phoneController.text)) {
                                                setState(() {
                                                  otptxt = "Sending";
                                                });
                                                verifyPhone(context, phoneNo);
                                              } else
                                                Scaffold.of(context)
                                                    .showSnackBar(SnackBar(
                                                  content: Text(
                                                      "Please enter valid number"),
                                                ));
                                              // }
                                            },
                                    ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: space,
                    ),
//-----------------------OTP Box------------------------------
                    codeSent && !verified
                        ? Container(
                            child: Column(
                              children: [
                                verified ? Text(status) : Text(status),
                                PinCode(
                                  onDone: (String text) {
                                    this.smsCode = text;
                                    print(text);
                                    smsVerify(context, this.smsCode);

                                    // await auth
                                    //     .signInWithCredential(phoneAuthCredential);
                                    // verifyPhone(text);
                                  },
                                ),
                              ],
                            ),
                          )
                        : SizedBox(),
                    SizedBox(
                      height: space,
                    ),
//-----------------------DOB------------------------------
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectDate(context),
                            child: TextFormField(
                              validator: (val) =>
                                  val.isEmpty ? "Please Select DOB" : null,
                              readOnly: true,
                              controller: _dateTextController,
                              decoration: InputDecoration(
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.red, width: 2.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.blue, width: 2.0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.blue[500], width: 2.0),
                                  ),
                                  hintText: "Select DOB",
                                  suffixIcon: IconButton(
                                      icon: Icon(Icons.date_range),
                                      onPressed: () => _selectDate(context))),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: space,
                    ),
                    Row(
                      children: [
//-----------------------Gender------------------------------
                        Expanded(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: gender,
                            items: <String>[
                              'Select Gender',
                              'Male',
                              'Female',
                              'Transgender',
                            ].map((String value) {
                              return new DropdownMenuItem<String>(
                                value: value,
                                child: new Text(value),
                              );
                            }).toList(),
                            onChanged: (String newval) {
                              setState(() {
                                gender = newval;
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
//-----------------------Blood Grp------------------------------
                        DropdownButton<String>(
                          value: bloodgrp,
                          items: <String>[
                            'Select Blood Group',
                            'A+',
                            'B+',
                            'AB+',
                            'O+',
                            'A-',
                            'B-',
                            'AB-',
                            'O-',
                          ].map((String value) {
                            return new DropdownMenuItem<String>(
                              value: value,
                              child: new Text(value),
                            );
                          }).toList(),
                          onChanged: (String newval) {
                            setState(() {
                              bloodgrp = newval;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: space,
                    ),
                    Row(
                      children: [
//-----------------------State------------------------------
                        Expanded(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: state,
                            items: stateList.map((String value) {
                              return new DropdownMenuItem<String>(
                                value: value,
                                child: new Text(value),
                              );
                            }).toList(),
                            onChanged: (String _state) {
                              if (_state != "Select State") {
                                state = _state;
                                Map s = states['data'];
                                print(s[_state]);
                                List l = s[_state];
                                cityList.clear();
                                cityList.insert(0, "Select City");
                                l.forEach((element) {
                                  cityList.add(element);
                                });
                              }
                              setState(() {});
                            },
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
//-----------------------City------------------------------
                        Expanded(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: city,
                            items: cityList.map((String value) {
                              return new DropdownMenuItem<String>(
                                value: value,
                                child: new Text(value),
                              );
                            }).toList(),
                            onChanged: (String newval) {
                              setState(() {
                                city = newval;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: space,
                    ),
                    Text(
                      "Marital status :",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    SizedBox(
                      height: space,
                    ),

                    Row(
                      children: [
                        Radio(
                          value: MarriedStatus.Unmarried,
                          groupValue: marriedStatus,
                          onChanged: (MarriedStatus value) {
                            setState(() {
                              marriedStatus = value;
                            });
                          },
                        ),
                        Expanded(
                          child: Text(
                            "Unmarried",
                            style: TextStyle(fontSize: 17),
                          ),
                        ),
                        Radio(
                          value: MarriedStatus.Married,
                          groupValue: marriedStatus,
                          onChanged: (MarriedStatus value) {
                            setState(() {
                              marriedStatus = value;
                            });
                          },
                        ),
                        Expanded(
                          child: Text(
                            "Married",
                            style: TextStyle(fontSize: 17),
                          ),
                        ),
                      ],
                    ),

                   
                    SizedBox(
                      height: space,
                    ),

//-----------------------Email------------------------------
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red, width: 2.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue[800], width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue[500], width: 2.0),
                        ),
                        hintText: "Enter Email",
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) {
                        if (mailreg.hasMatch(val)) {
                          return null;
                        } else {
                          return "Enter Valid Email Address";
                        }
                      },
                    ),
                    SizedBox(
                      height: space,
                    ),
//-----------------------Password------------------------------
                    TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(
                          errorBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.red, width: 2.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.blue[800], width: 2.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.blue[500], width: 2.0),
                          ),
                          hintText: "Enter Password",
                          suffixIcon: IconButton(
                              icon: Icon(Icons.lock,
                                  color:
                                      _obscureText ? Colors.grey : Colors.blue),
                              onPressed: _toggle)),
                      keyboardType: TextInputType.text,
                      obscureText: _obscureText,
                      validator: (val) {
                        if (val.length < 8)
                          return "Password must contains 8 characters";
                        else
                          return null;
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: isTermsAccepted,
                          onChanged: (bool b) {
                            isTermsAccepted = b;
                            setState(() {});
                          },
                        ),
                        InkWell(
                          onTap: () {},
                          child: Text(
                            "I Accept Terms & Conditions",
                            style: TextStyle(
                              fontSize: 15,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
//-----------------------Sign Up Txt------------------------------
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.only(left: 30, top: 30),
                            child: Text(
                              'Next',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
//-----------------------Signup FAB------------------------------
                        Container(
                          margin: EdgeInsets.only(right: 30, top: 30),
                          child: FloatingActionButton(
                            child: Icon(Icons.arrow_forward),
                            onPressed: () {
                              submit(context);
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
//-----------------------Footer------------------------------
                    Container(
                      alignment: Alignment.bottomCenter,
                      padding: EdgeInsets.only(bottom: 20),
                      child: InkWell(
                        child: Text(
                          'Already have account? Login',
                          style: TextStyle(
                            fontSize: 15,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, "/login");
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  void submit(BuildContext context) async {
    // Validate Input Fields
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
    } else {
      return;
    }
    // Validate OTP
    if (!verified) {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text("Verfiy your Moble Number")));
      return;
    }
    // Validate Dropdowns and DOB
    if (bloodgrp == "Select Blood Group" ||
        gender == "Select Gender" ||
        _dob == "Select Date of Birth" ||
        state == "Select State" ||
        city == "Select City") {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text("Please Fill all the fields")));
      return;
    }
    if (!isTermsAccepted) {
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text("Please Accept the terms and conditions")));
      return;
    }

    /*data = {
      "name": "Nikhil",
      "phone_no": "8999294549",
      "dob": "12/12/2020",
      "age": "19",
      "gender": "Male",
      "blood_grp": "AB+",
      "state": "MH",
      "city": "Solapur",
      "email": "nikhil@gmail.com",
      "password": "1234567",
      "token": "123456"
    };
    */
    // Gather all data

    data = {
      "name": nameController.text.trim(),
      "phone_no": phoneController.text.trim(),
      "dob": DateFormat('yyyy-MM-dd').format(dob),
      "gender": gender,
      "blood_grp": bloodgrp,
      "state": state,
      "married": marriedStatus == MarriedStatus.Married ? "1" : "0",
      "city": city,
      "email": emailController.text.trim(),
      "password": passwordController.text,
    };
    data['token'] = "$token";
    if (_imageFile != null) {
      data['photo'] = await MultipartFile.fromFile(_imageFile.path,
          filename: path.basename(_imageFile.path));
    }

    print(data);
    Navigator.push(context, SlideRightRoute(page: PaymentScreen(data: data)));
  }

  @override
  void dispose() {
    try {
      super.dispose();
      _timer.cancel();
    } catch (e) {
      print(e);
    }
  }
}
