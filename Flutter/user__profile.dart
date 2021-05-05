import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:online_appointment/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:online_appointment/screens/user/pregnancy_tab.dart';
import 'package:online_appointment/screens/user/update_profile.dart';
import 'package:online_appointment/screens/user/user_reports/my_reports.dart';
import 'package:online_appointment/screens/user/user_reports/prescription.dart';
import 'package:online_appointment/services/api_requester.dart';
import 'package:online_appointment/widgets/transition.dart';
import 'package:dio/dio.dart';
import 'package:online_appointment/services/uploader.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'chronic_diseases.dart';

class UserProfile extends StatefulWidget {
  final Function onUpdate, onDelete;
  final UserModel user;
  UserProfile({this.user, this.onDelete, this.onUpdate});
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  // For User Profile >>>>>>>>>>>>>>
  List serviceList = [];
  // String _serviceStatus = "Getting Services...";
  UserModel user;
  // int _tabIndex = 0;
  BuildContext contextX;
  // For Reports >>>>>>>>>>>>>>>
  List<Widget> tabs;
  List<Widget> tabsView;

  List odpData = [];

  bool isODPloading = false;
  String _opdStatus = "";

  @override
  void initState() {
    super.initState();
    // Init Tabs and Reports
    user = widget.user;
    tabs = List<Widget>();
    tabsView = List<Widget>();
  }

  @override
  Widget build(BuildContext context) {
    tabsView = [];
    tabs = [];
    // Profile Tab
    tabsView.add(
      Column(
        children: <Widget>[
          getHeader(),
          getMyChronic(),
        ],
      ),
    );
    // Report Tab
    tabsView.add(ReportTab(
      user: user,
    ));
    tabs.add(Tab(
      text: "Profile",
    ));
    tabs.add(Tab(
      text: "Reports",
    ));
    if (widget.user.married && widget.user.gender == "Female") {
      tabsView.add(getTabPregnancyView());
      tabs.add(Tab(
        text: "Pregnancy\nReport",
      ));
    }
    if (widget.user.age < 10) {
      tabsView.add(getTabChildView());
      tabs.add(Tab(
        text: "Child Report",
      ));
    }

    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Your Profile"),
      // ),
      body: Builder(builder: (context) {
        contextX = context;

        return DefaultTabController(
          length: tabsView.length,
          child: Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                title: TabBar(
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white,
                    indicatorColor: Colors.white,
                    tabs: tabs),
              ),
              body: Builder(
                  builder: (context) => TabBarView(children: tabsView))),
        );
      }),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {},
      //   child: Icon(Icons.assignment),
      // ),
    );
  }

  Widget getTabPregnancyView() {
    return PregnancyReportTab(user: widget.user);
  }

  Widget getTabChildView() {
    return Container(
      color: Colors.green,
    );
  }

  // For Profile Tab >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  void showProfileImage(BuildContext contextT) {
    setState(() {});
    showDialog(
      context: contextT,
      builder: (context) => Dialog(
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Theme.of(context).primaryColor, width: 2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
            height: 300,
            width: 300,
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: widget.user.photo,
                  fit: BoxFit.cover,
                  height: 300,
                  width: 300,
                  errorWidget: (context, s, t) => Icon(
                    Icons.account_circle,
                    size: 55,
                  ),
                ),
                // Container(
                //   alignment: Alignment.topRight,
                //   child: IconButton(
                //     icon: Icon(
                //       Icons.edit,
                //       color: Colors.white,
                //     ),
                //     onPressed: () {
                //       Navigator.pop(context);
                //       Navigator.push(
                //           context,
                //           SlideRightRoute(
                //               page: UpdateProfile(
                //             user: widget.user,
                //             onDelete: () {
                //               Navigator.pop(context);
                //               widget.onDelete(widget.user);
                //             },
                //             onUpdate: () {
                //               Scaffold.of(context).showSnackBar(SnackBar(
                //                 content: Text("Profile Updated"),
                //               ));
                //               widget.onUpdate();
                //               setState(() {});
                //             },
                //           )));
                //     },
                //   ),
                // )
              ],
            )),
      ),
    );
  }

  Widget getHeader() {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 500),
      tween: Tween<double>(begin: -50, end: 0),
      curve: Curves.easeInOut,
      builder: (context, double _val, Widget child) => Transform.translate(
        offset: Offset(0, _val),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: Theme.of(context).brightness == Brightness.dark
                  ? [
                      Colors.black12,
                      Colors.black,
                    ]
                  : [
                      Colors.blue,
                      Colors.blue[700],
                    ],
            ),
            color: Theme.of(context).primaryColor,
          ),
          padding: EdgeInsets.all(3),
          child: Card(
              shadowColor: Colors.greenAccent,
              elevation: 0,
              margin: EdgeInsets.only(top: 0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              color: Colors.white.withOpacity(0),
              child: Column(
                children: [
                  ListTile(
                    trailing: IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              SlideRightRoute(
                                  page: UpdateProfile(
                                user: widget.user,
                                onDelete: () {
                                  widget.onDelete(widget.user);
                                },
                                onUpdate: () {
                                  Scaffold.of(contextX).showSnackBar(SnackBar(
                                    content: Text("Profile Updated"),
                                  ));
                                  widget.onUpdate();
                                  setState(() {});
                                },
                              )));
                        }),
                    leading: GestureDetector(
                      onTap: () {
                        showProfileImage(contextX);
                      },
                      child: widget.user.photo == ""
                          ? Icon(
                              Icons.account_circle,
                              color: Colors.white,
                              size: 55,
                            )
                          : ClipOval(
                              // child: Image.network(
                              //   widget.user.photo,
                              //   width: 55,
                              //   height: 55,
                              //   fit: BoxFit.cover,
                              //   errorBuilder: (context, s, t) => Icon(
                              //     Icons.account_circle,
                              //     size: 55,
                              //   ),
                              // ),
                              child: CachedNetworkImage(
                                imageUrl: widget.user.photo,
                                fit: BoxFit.cover,
                                width: 55,
                                height: 55,
                                errorWidget: (context, s, t) => Icon(
                                  Icons.account_circle,
                                  size: 55,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                    ),
                    title: Text(
                      widget.user.name,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(widget.user.email,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white70)),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            SizedBox(height: 5),
                            Text("${widget.user.age}",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18)),
                            SizedBox(height: 5),
                            Text(
                              "Age",
                              style: TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                            SizedBox(height: 5),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 45,
                        color: Colors.white70,
                        child: Text(""),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            SizedBox(height: 5),
                            Text(widget.user.gender,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18)),
                            SizedBox(height: 5),
                            Text(
                              "Gender",
                              style: TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                            SizedBox(height: 5),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 45,
                        color: Colors.white70,
                        child: Text(""),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            SizedBox(height: 5),
                            Text(widget.user.bloodGrp,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18)),
                            SizedBox(height: 5),
                            Text(
                              "Blood Group",
                              style: TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                            SizedBox(height: 5),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  )
                ],
              )),
        ),
      ),
    );
  }

  Widget getMyChronic() {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Expanded(
                child: Text("My Chronic Diseases:",
                    style: TextStyle(fontWeight: FontWeight.bold))),
            IconButton(
                icon: Icon(
                  Icons.edit,
                  color: Colors.blue,
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      SlideRightRoute(
                          page: ChronicDiseases(
                        user: widget.user,
                        onUpdate: () {
                          Navigator.pop(context);
                          Scaffold.of(contextX).showSnackBar(SnackBar(
                              content: Text(
                            "Your Chronic diseases updated",
                          )));
                          setState(() {});
                        },
                      )));
                })
          ]),
          Divider(height: 7, color: Colors.grey[400]),
          widget.user.myDiseases.length == 0
              ? Text(
                  "No Chronic Disease Selected",
                  textAlign: TextAlign.center,
                )
              : GridView.builder(
                  shrinkWrap: true,
                  itemCount: widget.user.myDiseases.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 1.0,
                      mainAxisSpacing: 2.0,
                      childAspectRatio: 1 / 0.35),
                  itemBuilder: (context, index) {
                    return Container(
                      padding: EdgeInsets.all(2),
                      color: Colors.blue,
                      alignment: Alignment.center,
                      child: Text(
                        widget.user.myDiseases[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }),
          Divider(height: 15, color: Colors.grey[400]),
        ],
      ),
    );
  }

  void onDelete() {
    Navigator.pop(context);
    widget.onDelete();
  }

  void onUpdate() {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text("Profile Updated"),
    ));
    widget.onDelete();
    setState(() {});
  }
}

class ReportTab extends StatefulWidget {
  final UserModel user;
  ReportTab({this.user});
  @override
  _ReportTabState createState() => _ReportTabState();
}

class _ReportTabState extends State<ReportTab> {
  bool isloading = false;

  String _opdStatus = "";
  List odpData = [];
  DateTime opd_datetime;
  bool isTermsAccepted = false;
  DateTime selectedDate = DateTime.now();
  TextEditingController _dateTextController = new TextEditingController();
  String opd_date = "Select Date of Birth";

  @override
  void initState() {
    super.initState();
    getOPD();
  }

  void getOPD() async {
    setState(() {
      isloading = true;
    });
    Map response = await Requester.getODP({"profile_id": widget.user.id});
    _opdStatus = "";
    if (response['status'] == "error") {
      _opdStatus = response['message'];
    } else {
      odpData = response['data'];
      if (odpData.length == 0) {}
    }
    setState(() {
      isloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          child: isloading
              ? getLoadingContainer()
              : _opdStatus != ""
                  ? getStatusContainer(_opdStatus)
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: odpData.length,
                      itemBuilder: (context, index) {
                        return ODP_EDP(user: widget.user, opd: odpData[index]);
                      },
                    ),
        ),
        Container(
          alignment: Alignment.bottomRight,
          padding: EdgeInsets.all(15),
          child: FloatingActionButton(
            child: Icon(Icons.assessment),
            onPressed: () {
              showOPDAddDialog(context);
            },
          ),
        ),
      ],
    );
  }

  void showOPDAddDialog(contextSf) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (contextS) {
          String diagnosis = "";
          String type = "";
          String error = "";
          String updateStatus = "Add";
          final _formKey = GlobalKey<FormState>();
          return StatefulBuilder(
            builder: (context, setStateT) => Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.only(top: 10, left: 7, right: 7),
                  height: 450,
                  child: Form(
                    key: _formKey,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                  child: Text(
                                "Update",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.bold),
                              )),
                              IconButton(
                                  icon: Icon(Icons.close),
                                  onPressed: () {
                                    Navigator.pop(contextS);
                                  })
                            ],
                          ),
                          Divider(
                            thickness: 1,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text("Tap to Choose"),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setStateT(() {
                                      type = "OPD";
                                    });
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.all(5),
                                    padding: EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.blue),
                                        borderRadius: BorderRadius.circular(5),
                                        color: type == "OPD"
                                            ? Colors.green
                                            : Theme.of(context)
                                                .scaffoldBackgroundColor),
                                    child: Text("OPD",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setStateT(() {
                                      type = "IPD";
                                    });
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.all(20),
                                    margin: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.blue),
                                        borderRadius: BorderRadius.circular(5),
                                        color: type == "IPD"
                                            ? Colors.green
                                            : Theme.of(context)
                                                .scaffoldBackgroundColor),
                                    child: Text("IPD",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            initialValue: diagnosis,
                            onChanged: (val) {
                              diagnosis = val;
                            },
                            decoration: InputDecoration(
                                labelText: "Enter Diagnosis/Disease"),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: _dateTextController,
                            readOnly: true,
                            validator: (String val) {
                              if (val == "")
                                return 'Please Select date';
                              else
                                return null;
                            },
                            // validator: (),
                            onChanged: (val) {
                              diagnosis = val;
                            },
                            decoration: InputDecoration(
                                labelText: "Select Date",
                                suffixIcon: IconButton(
                                    icon: Icon(Icons.date_range),
                                    onPressed: () => _selectDate(context))),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          RaisedButton(
                            onPressed: () async {
                              if (_formKey.currentState.validate()) {
                                if (type == "") {
                                  setStateT(() {
                                    error = "Please choose type.";
                                  });
                                  return;
                                }
                                setStateT(() {
                                  updateStatus = "Updating...";
                                });
                                Map response = await Requester.updateOPD({
                                  "profile_id": widget.user.id,
                                  "opd_ipd": type,
                                  "opd_date": _dateTextController.text,
                                  "diagnosis": diagnosis,
                                  "type": "add"
                                });
                                if (response['status'] == "success") {
                                  getOPD();
                                }
                                Navigator.pop(contextS);
                                Scaffold.of(contextSf).showSnackBar(SnackBar(
                                    content: Text("${response['message']}")));
                              }
                            },
                            child: Text(updateStatus),
                          ),
                          Text(
                            error,
                            style: TextStyle(color: Colors.red),
                          )
                        ]),
                  ),
                ),
              ),
            ),
          );
        });
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
        opd_datetime = selectedDate;
        opd_date = DateFormat('yyyy-MM-dd').format(selectedDate);
        _dateTextController.text = opd_date;
      });
  }

  Widget getLoadingContainer() {
    return Container(
      alignment: Alignment.center,
      child: SpinKitWave(
        color: Colors.blue,
      ),
    );
  }

  Widget getStatusContainer(String text) {
    return Container(alignment: Alignment.center, child: Text("$text"));
  }

  void _showToast(BuildContext context, String text) {
    final scaffold = Scaffold.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }
}

class ODP_EDP extends StatefulWidget {
  final UserModel user;
  final Map opd;
  final Function onUpdate;
  ODP_EDP({this.user, this.opd, this.onUpdate});
  @override
  _ODP_EDPState createState() => _ODP_EDPState();
}

class _ODP_EDPState extends State<ODP_EDP> {
  // For User Profile >>>>>>>>>>>>>>
  List serviceList = [];
  // String _serviceStatus = "Getting Services...";
  UserModel user;
  // int _tabIndex = 0;
  BuildContext contextX;

  // For Reports >>>>>>>>>>>>>>>
  List<Widget> tabs;
  List<Widget> tabsView;
  List reportsImgs = [], prescpImgs = [];
  bool _isloadingReport = false, _isloadingPrescp = false;

  File _imageFile;
  final picker = ImagePicker();
  bool isloading = false;
  List reports = [];
  bool isShowImage = false;
  Map image;
  bool isListView = false;

  String choosedMode;
  double containerHeight = 120;

  var status;

  @override
  void initState() {
    super.initState();
    getOPDReports();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      // OPD/IPD Details >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
      Container(
        height: 25,
        child: Row(
          children: [
            SizedBox(
              width: 15,
            ),
            Text(
              "OPD/IPD: ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Text(
                "${widget.opd['opd_ipd']}",
              ),
            ),

            Text("${widget.opd['opd_date']}"),
            IconButton(
              padding: EdgeInsets.all(0),
              onPressed: () {
                showEditDialog(context);
              },
              icon: Icon(
                Icons.edit,
                size: 20,
                color: Colors.blue[700],
              ),
            ),
            // Text("Diagnosis: ", style: TextStyle(fontWeight: FontWeight.bold)),
            // Text("${widget.opd['opd_ipd']}    "),
            SizedBox(
              width: 10,
            )
          ],
        ),
      ),
      Padding(
        padding: EdgeInsets.only(left: 15, right: 10, bottom: 3),
        child: RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: <TextSpan>[
                  TextSpan(
                      text: "Diagnosis : ",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                    text: "${widget.opd['diagnosis']}",
                  )
                ])),
      ),

      // If It is from Doctor >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
      widget.opd['from_doctor'] != 0
          ? Container(
              decoration: BoxDecoration(
                  // border: Border.fromBorderSide(
                  //     BorderSide(color: Colors.grey, width: 2))
                  ),
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              child: Text(
                "From Doctor",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.orange),
              ))
          : SizedBox(),
      Container(
        child: isloading
            ? getLoadingContainer()
            : status != ""
                ? getStatusContainer(status)
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                        // Report Images >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                        Expanded(
                            child: Container(
                                height: containerHeight,
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.grey[500], width: 1)),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    IconButton(
                                        color: Colors.blue,
                                        iconSize: 20,
                                        icon: Icon(
                                          Icons.camera_alt,
                                          color: Colors.blue,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          choosedMode = "report";
                                          showUploadBottomSheet(context);
                                        }),
                                    Expanded(
                                      child: reportsImgs.length == 0
                                          ? getStatusContainer("No Reports")
                                          : GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    SlideRightRoute(
                                                        page: MyReports(
                                                      user: widget.user,
                                                      opd: widget.opd,
                                                      onUpdate: () {
                                                        getOPDReports();
                                                      },
                                                    )));
                                              },
                                              child: GridView.builder(
                                                  itemCount:
                                                      reportsImgs.length > 6
                                                          ? 6
                                                          : reportsImgs.length,
                                                  gridDelegate:
                                                      SliverGridDelegateWithFixedCrossAxisCount(
                                                          crossAxisCount: 3,
                                                          crossAxisSpacing: 1.0,
                                                          mainAxisSpacing: 2.0,
                                                          childAspectRatio:
                                                              0.20 / 0.20),
                                                  shrinkWrap: true,
                                                  itemBuilder:
                                                      (context, index) {
                                                    if (index == 5) {
                                                      return Container(
                                                          color: Colors.black87,
                                                          child: Center(
                                                            child: Text(
                                                                "+${reportsImgs.length - 5}",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                    color: Colors
                                                                        .white)),
                                                          ));
                                                    }

                                                    return Container(
                                                      color: Colors.white,
                                                      child: CachedNetworkImage(
                                                        imageUrl:
                                                            reportsImgs[index]
                                                                ['path'],
                                                        fit: BoxFit.cover,
                                                        errorWidget: (context,
                                                                error, v) =>
                                                            Center(
                                                          child: Icon(
                                                            Icons.error,
                                                            color: Colors.red,
                                                            size: 15,
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                            ),
                                    ),
                                  ],
                                ))),
                        // Prescription Images >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                        Expanded(
                            child: Container(
                          height: containerHeight,
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey[500], width: 1)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                  color: Colors.blue,
                                  iconSize: 20,
                                  icon: Icon(
                                    Icons.camera_alt,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    choosedMode = "prescription";
                                    showUploadBottomSheet(context);
                                  }),
                              Expanded(
                                child: prescpImgs.length == 0
                                    ? getStatusContainer("No Prescription")
                                    : GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              SlideRightRoute(
                                                  page: Prescription(
                                                user: widget.user,
                                                opd: widget.opd,
                                                onUpdate: () {
                                                  getOPDReports();
                                                },
                                              )));
                                        },
                                        child: GridView.builder(
                                            itemCount: prescpImgs.length > 6
                                                ? 6
                                                : prescpImgs.length,
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 3,
                                                    crossAxisSpacing: 1.0,
                                                    mainAxisSpacing: 2.0,
                                                    childAspectRatio:
                                                        0.20 / 0.20),
                                            shrinkWrap: true,
                                            itemBuilder: (context, index) {
                                              if (index == 5) {
                                                return Container(
                                                    color: Colors.black87,
                                                    child: Center(
                                                      child: Text(
                                                          "+${prescpImgs.length - 5}",
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              color: Colors
                                                                  .white)),
                                                    ));
                                              }
                                              return Container(
                                                color: Colors.white,
                                                child: CachedNetworkImage(
                                                  imageUrl: prescpImgs[index]
                                                      ['path'],
                                                  fit: BoxFit.cover,
                                                  errorWidget:
                                                      (context, error, v) =>
                                                          Center(
                                                    child: Icon(
                                                      Icons.error,
                                                      color: Colors.red,
                                                      size: 15,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }),
                                      ),
                              )
                            ],
                          ),
                        )),
                      ]),
      ),
    ]));
  }

  Widget getLoadingContainer() {
    return Container(
      height: containerHeight,
      alignment: Alignment.center,
      child: SpinKitWave(
        color: Colors.blue,
      ),
    );
  }

  Widget getStatusContainer(String text) {
    return Container(
        height: containerHeight,
        alignment: Alignment.center,
        child: Text(text));
  }

  void _showToast(BuildContext context, String text) {
    final scaffold = Scaffold.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }

  // Others Camera ->>>>>>>>>>>>>>>>>>>>>>>
  Future<File> compressImage(File file) async {
    final temp = await getTemporaryDirectory();
    print(
      file.absolute.path,
    );
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      "${temp.path}/${DateTime.now().millisecondsSinceEpoch}.jpg",
      minHeight: 1920,
      minWidth: 1080,
      quality: 25,
    );
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

      showImageDailog(context);
    } else {
      print('No image selected.');
    }
    setState(() {});
  }

  void showImageDailog(BuildContext contextSf) async {
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (contextS) {
          String name = "";
          String uploadStatus = "Upload";
          final _formKey = GlobalKey<FormState>();
          return StatefulBuilder(
            builder: (context, setStateT) => Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Container(
                padding: EdgeInsets.only(top: 10, left: 5, right: 5),
                height: 400,
                child: Form(
                  key: _formKey,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: Text(
                              "Upload Report",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            )),
                            IconButton(
                                icon: Icon(Icons.close),
                                onPressed: () {
                                  Navigator.pop(contextS);
                                })
                          ],
                        ),
                        Divider(
                          thickness: 1,
                        ),
                        Expanded(
                            child: Stack(children: [
                          Center(
                            child: Image.file(
                              _imageFile,
                            ),
                          ),
                          uploadStatus == "Uploading..."
                              ? Center(
                                  child: SpinKitDualRing(
                                    color: Colors.blue,
                                  ),
                                )
                              : SizedBox()
                        ])),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          onChanged: (val) {
                            name = val;
                          },
                          decoration: InputDecoration(hintText: "Enter Name"),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        RaisedButton(
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              setStateT(() {
                                uploadStatus = "Uploading...";
                              });

                              FormData formData = new FormData.fromMap({
                                "profile_id": widget.user.id,
                                "name": name,
                                "dept_id": "${widget.opd['dept_id']}",
                                "image": await MultipartFile.fromFile(
                                    _imageFile.path,
                                    filename: path.basename(_imageFile.path))
                              });
                              Map response;
                              switch (choosedMode) {
                                case "report":
                                  response =
                                      await Uploader.uploadReport(formData);
                                  break;
                                case "prescription":
                                  response = await Uploader.uploadPrescription(
                                      formData);
                                  break;
                              }
                              setStateT(() {
                                uploadStatus = "Upload";
                              });

                              if (response['status'] == "success") {
                                getOPDReports();
                              }

                              Navigator.pop(contextS);
                              Scaffold.of(contextSf).showSnackBar(
                                  SnackBar(content: Text(response['message'])));
                            }
                          },
                          child: Text(uploadStatus),
                        )
                      ]),
                ),
              ),
            ),
          );
        });
  }

  void showUploadBottomSheet(BuildContext contextSf) {
    showModalBottomSheet(
        context: contextSf,
        builder: (context) => Container(
              height: 150,
              padding: EdgeInsets.all(10),
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                  // border: Border.all(width: 1),
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
                  Row(
                    children: [
                      Expanded(
                        child: RaisedButton.icon(
                            padding: EdgeInsets.all(20),
                            color: Colors.blue,
                            textColor: Colors.white,
                            onPressed: () {
                              getImage(contextSf, isCamera: true);
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.camera),
                            label: Text("Camera")),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: FlatButton.icon(
                            padding: EdgeInsets.all(20),
                            color: Colors.blue,
                            textColor: Colors.white,
                            onPressed: () {
                              getImage(contextSf);
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.image),
                            label: Text("Gallery")),
                      ),
                    ],
                  ),
                ],
              ),
            ));
  }

  // API =>

  void getOPDReports() async {
    try {
      setState(() {
        isloading = true;
      });
    } catch (e) {}

    Map response = await Requester.getODPReports({
      "profile_id": widget.opd['profile_id'],
      "dept_id": "${widget.opd['dept_id']}"
    });

    if (response['status'] == "error") {
      status = response['message'];
    } else {
      status = "";
      reportsImgs = response['data']['report'];
      prescpImgs = response['data']['prescription'];
    }
    try {
      setState(() {
        isloading = false;
      });
    } catch (e) {}
  }

  void showEditDialog(BuildContext contextSf) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (contextS) {
          String diagnosis = widget.opd['diagnosis'];
          String type = widget.opd['opd_ipd'];
          String updateStatus = "Update";
          final _formKey = GlobalKey<FormState>();
          return StatefulBuilder(
            builder: (context, setStateT) => Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.only(top: 10, left: 7, right: 7),
                  height: 400,
                  child: Form(
                    key: _formKey,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                  child: Text(
                                "Update",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.bold),
                              )),
                              IconButton(
                                  icon: Icon(Icons.close),
                                  onPressed: () {
                                    Navigator.pop(contextS);
                                  })
                            ],
                          ),
                          Divider(
                            thickness: 1,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text("Tap to Choose"),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setStateT(() {
                                      type = "OPD";
                                    });
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.all(5),
                                    padding: EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.blue),
                                        borderRadius: BorderRadius.circular(5),
                                        color: type == "OPD"
                                            ? Colors.green
                                            : Theme.of(context)
                                                .scaffoldBackgroundColor),
                                    child: Text("OPD",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setStateT(() {
                                      type = "IPD";
                                    });
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.all(20),
                                    margin: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.blue),
                                        borderRadius: BorderRadius.circular(5),
                                        color: type == "IPD"
                                            ? Colors.green
                                            : Theme.of(context)
                                                .scaffoldBackgroundColor),
                                    child: Text("IPD",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            initialValue: diagnosis,
                            onChanged: (val) {
                              diagnosis = val;
                            },
                            decoration: InputDecoration(
                                labelText: "Enter Diagnosis/Disease"),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          RaisedButton(
                            onPressed: () async {
                              if (_formKey.currentState.validate()) {
                                setStateT(() {
                                  updateStatus = "Updating...";
                                });
                                Map response = await Requester.updateOPD({
                                  "profile_id": widget.user.id,
                                  "dept_id": "${widget.opd['dept_id']}",
                                  "opd_ipd": type,
                                  // "opd_date":date
                                  "diagnosis": diagnosis,
                                  "type": "update"
                                });
                                if (response['status'] == "success") {
                                  widget.opd['opd_ipd'] = type;
                                  widget.opd['diagnosis'] = diagnosis;
                                  setState(() {});
                                }
                                Navigator.pop(contextS);
                                Scaffold.of(contextSf).showSnackBar(SnackBar(
                                    content: Text("${response['message']}")));
                              }
                            },
                            child: Text(updateStatus),
                          )
                        ]),
                  ),
                ),
              ),
            ),
          );
        });
  }
}
