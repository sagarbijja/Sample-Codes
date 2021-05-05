import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:online_appointment/models/notifier_models.dart';
import 'package:online_appointment/models/user_model.dart';
import 'package:online_appointment/screens/dashboard.dart';
import 'package:online_appointment/services/api_requester.dart';
import 'package:online_appointment/models/doctor_model.dart';
import 'package:online_appointment/widgets/transition.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';

class DoctorInfo extends StatefulWidget {
  final DoctorModel doctor;
  final UserModel user;
  final String id;
  final bool isProfile;
  final bool isMultiUser;
  DoctorInfo(
      {this.doctor,
      this.user,
      this.id,
      this.isProfile,
      this.isMultiUser = false});
  @override
  _DoctorInfoState createState() => _DoctorInfoState();
}

class _DoctorInfoState extends State<DoctorInfo> {
  DoctorModel doctor;

  DateTime _selectedDate = DateTime.now();
  TextEditingController _dateTextController;
  String _session = "Select Session";
  Map notAvailable = {};

  // bool _isloading = false;
  Map session = {};
  List<String> sessionList = ["Select Session"];
  bool _isloadingSess = false;
  bool isDoctorLoding = false;
  String status = " ";
  BuildContext contextSk;
  List<UserModel> userList;
  int selectedUser = -1;
  UserModel user;
  @override
  void initState() {
    super.initState();

    if (widget.id != null) {
      isDoctorLoding = true;
      getDoctorProfile();
    } else {
      userList = Provider.of<UserNotifer>(context, listen: false).getValue();
      getSessionDetail(DateFormat("yyyy-MM-dd").format(DateTime.now()));
      doctor = widget.doctor;
      user = widget.user;
      _dateTextController = new TextEditingController();
 
    }
  }

  void getDoctorProfile() async {
    Map response = await Requester.getDoctorProfile({"doctor_id": widget.id});
    if (response['status'] != "error") {
      this.doctor = DoctorModel.fromJson(response['data']);
      status = " ";
    } else {
      status = response['message'];
    }
    setState(() {
      isDoctorLoding = false;
    });
  }

  void getSessionDetail(String date) async {
    setState(() {
      _isloadingSess = true;
    });
    Map response = await Requester.getDoctorSessions(
        {"doctor_id": widget.doctor.id, "date": date});
    if (response['status'] != "error") {
      notAvailable = response['not_available'] ?? {};
      session = response['data'];
      if (session.length != 0) {
        sessionList = ["Select Session"];
        session.forEach((key, value) {
          print(session[key]['status']);
          if (session[key]['status'] == 'OPEN') {
            sessionList.add(key + "    " + session[key]['timing']);
          }
        });
      }
      // print(session);
    } else {}
    setState(() {
      _isloadingSess = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Doctor Profile"),
      ),
      body: Builder(builder: (context) {
        contextSk = context;
        return ListView(children: [
          SizedBox(
            height: 10,
          ),
          // Carousel Slider
          CarouselSlider(
            options: CarouselOptions(height: 200.0, autoPlay: true),
            items: [1, 2, 3, 4, 5].map((i) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 1.0),
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(15)),
                      child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Icon(
                            Icons.photo,
                            size: 50,
                            color: Colors.white,
                          )));
                },
              );
            }).toList(),
          ),

          // Doctor Profile -------------------------------
          Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                // Profile Card >>>>>>>>>>>>>>>>>>
                Card(
                  elevation: 3,
                  clipBehavior: Clip.hardEdge,
                  shadowColor: Colors.blue[700],
                  child: Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: isDoctorLoding
                        ? SpinKitWave(
                            size: 20,
                            color: Colors.blue,
                          )
                        : status != " "
                            ? Text(status)
                            : Column(
                                children: [
                                  Row(
                                      // crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Container(
                                          width: 100,
                                          height: 100,
                                          clipBehavior: Clip.hardEdge,
                                          decoration: BoxDecoration(
                                              color: Colors.blue,
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Image.network(
                                            doctor.photo,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Padding(
                                              padding: EdgeInsets.all(10),
                                              child: Image.asset(
                                                "assets/icons/stethoscope.png",
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: ListTile(
                                            title: Text(doctor.name,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            subtitle: Text(doctor.specialist,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                )),
                                          ),
                                        ),
                                  
                                      ]),
                                  Container(
                                      padding:
                                          EdgeInsets.only(left: 25, top: 10),
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 15,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "Clinic/Hospital :  ",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                doctor.hospital,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: 15,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "Mobile No       :  ",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                doctor.mobile,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            ],
                                          ),
                                        ],
                                      )),
                                  SizedBox(
                                    height: 20,
                                  )
                                ],
                              ),
                  ),
                ),
     
                widget.isMultiUser
                    ? Card(
                        clipBehavior: Clip.hardEdge,
                        elevation: 3,
                        shadowColor: Colors.blue[700],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Select User",
                              style: TextStyle(fontSize: 20),
                            ),
                            Divider(
                              color: Colors.black,
                            ),
                            ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: userList.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    selected: selectedUser == index,
                                    selectedTileColor: Colors.greenAccent,
                                    // tileColor: Colors.white,
                                    onTap: () {
                                      selectedUser = index;
                                      user = userList[index];
                                      setState(() {});
                                    },
                                    leading:
                                        Icon(Icons.account_circle, size: 50),
                                    title: Text(
                                      userList[index].name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                })
                          ],
                        ),
                      )
                    : SizedBox(),
                // Book  Appointment Card >>>>>>>>>>>>>>>>>>>>>
                widget.id != null
                    ? SizedBox()
                    : Container(
                        child: Card(
                          elevation: 5,
                          shadowColor: Colors.blue[700],
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Text(
                                    "Book Appointment",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Divider(
                                    color: Colors.black,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          readOnly: true,
                                          controller: _dateTextController,
                                          decoration: InputDecoration(
                                              hintText:
                                                  "Select Appointment Date"),
                                        ),
                                      ),
                                      IconButton(
                                          icon: Icon(Icons.date_range),
                                          onPressed: () {
                                            showDatePickerDialog(context);
                                          })
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  // Sessions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                  Text("Select a session"),
                                  _isloadingSess
                                      ? SpinKitWave(
                                          size: 20,
                                          color: Colors.blue,
                                        )
                                      : Row(
                                          children: [
                                            // Morning >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                            getSessionCard(context, "Morning"),
                                            // Evening >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                                            getSessionCard(context, "Evening")
                                          ],
                                        ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                ]),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ]);
      }),
    );
  }

  Widget getSessionCard(BuildContext context, String key) {
    return session[key] != null
        ? Expanded(
            child: InkWell(
            child: Card(
              clipBehavior: Clip.hardEdge,
              elevation: 5,
              child: InkWell(
                splashColor: Colors.blue,
                onTap: () {
                  _session = key;
                  showConfirmDialog(context, key);
                },
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      key,
                      style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                    Divider(
                      color: Colors.black,
                      thickness: 1,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                        "${session[key]['current']}/${session[key]['limits']}"),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      session[key]['status'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: session[key]['status'] == "OPEN"
                              ? Colors.green
                              : doctor.status == "CLOSED"
                                  ? Colors.grey
                                  : Colors.red,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Divider(
                      color: Colors.black,
                      thickness: 1,
                    ),
                    Text(session[key]['timing']),
                    SizedBox(
                      height: 15,
                    ),
                  ],
                ),
              ),
            ),
          ))
        : SizedBox();
  }

  showConfirmDialog(BuildContext context, String key) async {
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Appointment"),
              content: Text("Are you sure you want book appointment at $key ?"),
              actions: [
                TextButton(
                  onPressed: () {
                    book(context);
                    Navigator.of(context).pop();
                  },
                  child: Text("Yes"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("No"),
                )
              ],
            ));
  }

  void showDatePickerDialog(context) async {
    int flag = 0;
    for (int i = 1; i <= 7; i++) {
      if (!getIsAvailable(_selectedDate.millisecondsSinceEpoch)) {
        _selectedDate.add(Duration(days: 1));
        flag++;
      }
    }
    // No Dates Available
    if (flag >= 7) {
      _showToast(context, "No Dates Available.", colors: Colors.redAccent);
      return;
    }

    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime.now(),
        // 7 Days
        lastDate: DateTime.now().add(Duration(days: 7)),
        selectableDayPredicate: (DateTime day) {
          return getIsAvailable(day.millisecondsSinceEpoch);
        });
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
        _dateTextController.text =
            DateFormat("dd/MM/yyy").format(_selectedDate);
        // if (!getIsAvailable(_selectedDate.millisecondsSinceEpoch)) {
        //   _showToast(context, "Sorry the doctor is not avaliable for x days",
        //       colors: Colors.redAccent);
        // }
        getSessionDetail(DateFormat("yyyy-MM-dd").format(_selectedDate));
      });
  }

  bool getIsAvailable(int date) {
    // Date Format Send by Server : yyyy-MM-dd

    try {
      int from = DateTime.parse(notAvailable['from']).millisecondsSinceEpoch;
      int to = DateTime.parse(notAvailable['to']).millisecondsSinceEpoch;
      // USING mili seconds
      if (date >= from && date <= to) return false;
    } catch (e) {}

    return true;
  }

  void book(contextT) async {
    //  Check if user is selected
    if (user == null) {
      _showToast(context, "Please Select a User", colors: Colors.redAccent);
      return;
    }
    if (_dateTextController.text == "") {
      _showToast(context, "Please Select Date", colors: Colors.redAccent);
      return;
    }

    Map response = await Requester.bookAppointment({
      "patient_name": user.name,
      "patient_id": user.id,
      "doctor_id": doctor.id,
      "apt_date": DateFormat("yyyy/MM/dd").format(_selectedDate),
      "phone_no": user.mobile,
      "session": _session,
      "parent_id": user.parentId == "" ? user.id : user.parentId
    });

    if (response['status'] == 'success') {
      widget.doctor.currentApts = response['count'];
    }
    if (response['message'].contains("Booked")) {
      Provider.of<AppointmentNotifier>(contextSk, listen: false).update();
      // Jump to Main Dashboard

      _showToast(context, response['message'],
          colors: Colors.green, label: "Check");
      Navigator.pushReplacement(
          context,
          SlideRightRoute(
              page: Dashboard(
            userList: userList,
            tabIndex: 2,
          )));
    } else {
      _showToast(context, response['message'], colors: Colors.redAccent);
    }

    getSessionDetail(DateFormat("yyyy/MM/dd").format(_selectedDate));
  }

  void _showToast(BuildContext context, String text,
      {Color colors, String label = ""}) {
    final scaffold = Scaffold.of(contextSk);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor:
            colors ?? Theme.of(context).snackBarTheme.backgroundColor,
        duration: Duration(seconds: 4),
      ),
    );
  }
}
