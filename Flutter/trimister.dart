import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:online_appointment/services/api_requester.dart';
import 'package:dio/dio.dart';
import 'package:online_appointment/services/uploader.dart';
import 'package:online_appointment/widgets/transition.dart';
import 'package:online_appointment/screens/user/user_reports/pregnancy_report.dart'
    as pReport;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

enum PregnancyStatus { Abortion, Normal_Delivery, Scissor_Delivery, None }
enum ChildStatus { Alive, Death, None }

class Trimester extends StatefulWidget {
  Function onUpdate;
  final pInfo;
  Trimester({this.pInfo, this.onUpdate});
  @override
  _TrimesterState createState() => _TrimesterState();
}

class _TrimesterState extends State<Trimester> {
  PregnancyStatus pregnancyStatus = PregnancyStatus.None;
  ChildStatus childStatus = ChildStatus.None;

  List<Widget> tabs;
  List<Widget> tabsView;
  List reportsImgs, prescpImgs, pregImgs, childImgs;
  final picker = ImagePicker();
  bool isloading = false;
  List reports = [];
  bool isShowImage = false;
  Map image;
  bool isListView = false;

  int selectedTriNo = 0;

  String choosedMode;
  double containerHeight = 90;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Trimester")),
      body: Builder(
        builder: (context) => Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              getHeader(context),
              Container(
                color: Colors.blue[800],
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(
                        child: Text(
                      "REPORTS",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    )),
                
                    Expanded(
                        child: Text(
                      "Rx/PRESCRIPTION",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    )),
                  ],
                ),
              ),
              Expanded(child: getReports(context)),
              SizedBox(
                height: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getHeader(context) {
    return Container(
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black))),
      padding: EdgeInsets.all(5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: Container(
            decoration: BoxDecoration(
                border: Border(
                    right: BorderSide(
              color: Colors.black,
            ))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                getRow("LMP", widget.pInfo['LMP']),
                getRow("EDD", widget.pInfo['EDD']),
                getRow("UPT", widget.pInfo['UPT']),
                // getRow("Weight", widget.pInfo['weight']),
                getRow("Hisk Risk", widget.pInfo['high_risk']),
                getRow("Pregnancy", widget.pInfo['preg_cate']),
              ],
            ),
          )),
          SizedBox(
            width: 10,
          ),
          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              getRow("Doctor Details", widget.pInfo['doctor_name']),
            ],
          )),
        ],
      ),
    );
  }

  Widget getReports(context) {
    return Container(
        child: ListView(
      children: [
        TrimesterCard(
          pInfo: widget.pInfo,
          extra: {
            "title": "1st Trimester",
            "week": "0 - 12 Weeks",
            "month": "1",
            "tri_no": "1"
          },
          contextX: context,
        ),
        TrimesterCard(
          pInfo: widget.pInfo,
          extra: {
            "title": "2nd Trimester",
            "week": "13 - 24 Weeks",
            "month": "4",
            "tri_no": "2"
          },
          contextX: context,
        ),
        TrimesterCard(
          pInfo: widget.pInfo,
          extra: {
            "title": "3rd Trimester",
            "week": "25 - 36 Weeks",
            "month": "9",
            "tri_no": "3"
          },
          contextX: context,
        ),
        RaisedButton(
          color: Colors.green,
          padding: EdgeInsets.all(15),
          child: Text("Final Status"),
          onPressed: () {
            showStatusDialog(context);
          },
        )
      ],
    ));
  }

  Widget getRow(String header, String text) {
    if (text == "") {
      text = "-";
    }
    return Row(
      children: [
        Text(
          header + " : ",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(
            text,
            // softWrap: true,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void showStatusDialog(BuildContext contextSf) {
    String name = "";
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (contextS) {
          // String name = " ";
          String uploadStatus = "Upload";
          final _formKey = GlobalKey<FormState>();
          return StatefulBuilder(
            builder: (context, setStateT) => Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Container(
                padding: EdgeInsets.only(top: 10, left: 5, right: 5),
                height: 500,
                child: Form(
                  key: _formKey,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: Text(
                              "Select Final Status",
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
                        Column(
                          children: [
                            RadioListTile(
                                value: PregnancyStatus.Abortion,
                                groupValue: pregnancyStatus,
                                title: Text("Abortion"),
                                onChanged: (PregnancyStatus c) {
                                  setStateT(() {
                                    pregnancyStatus = c;
                                  });
                                }),
                            RadioListTile(
                                value: PregnancyStatus.Normal_Delivery,
                                groupValue: pregnancyStatus,
                                title: Text("Normal Delivery"),
                                onChanged: (PregnancyStatus c) {
                                  setStateT(() {
                                    pregnancyStatus = c;
                                  });
                                }),
                            RadioListTile(
                                value: PregnancyStatus.Scissor_Delivery,
                                groupValue: pregnancyStatus,
                                title: Text("Scissor Delivery"),
                                onChanged: (PregnancyStatus c) {
                                  setStateT(() {
                                    pregnancyStatus = c;
                                  });
                                })
                          ],
                        ),
                        Divider(
                          thickness: 1,
                        ),
                        PregnancyStatus.Abortion != pregnancyStatus &&
                                PregnancyStatus.None != pregnancyStatus
                            ? Column(
                                children: [
                                  RadioListTile(
                                      value: ChildStatus.Alive,
                                      groupValue: childStatus,
                                      title: Text("Alive"),
                                      onChanged: (ChildStatus c) {
                                        setStateT(() {
                                          childStatus = c;
                                        });
                                      }),
                                  RadioListTile(
                                      value: ChildStatus.Death,
                                      groupValue: childStatus,
                                      title: Text("Death"),
                                      onChanged: (ChildStatus c) {
                                        setStateT(() {
                                          childStatus = c;
                                        });
                                      }),
                                ],
                              )
                            : SizedBox(),
                        SizedBox(
                          height: 10,
                        ),
                        RaisedButton(
                          onPressed: () async {
                            String message = "Uploaded";

                            if (PregnancyStatus.None == pregnancyStatus) {
                              message = "Please select the status";
                            } else if (PregnancyStatus.Abortion !=
                                    pregnancyStatus &&
                                ChildStatus.None == childStatus) {
                              message = "Please select the child status";
                            } else {
                              setStateT(() {
                                uploadStatus = "Uploading...";
                              });

                              message = await updatePregnancyStatus();
                            }

                            Scaffold.of(contextSf)
                                .showSnackBar(SnackBar(content: Text(message)));

                            // if (message != "") {
                            //   setStateT(() {
                            //     uploadStatus = message;
                            //   });
                            // } else
                            Navigator.pop(contextS);
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

  Future<String> updatePregnancyStatus() async {
    String pStatus = "", cStatus = "";
    switch (pregnancyStatus) {
      case PregnancyStatus.Abortion:
        pStatus = "Abortion";
        break;
      case PregnancyStatus.Normal_Delivery:
        pStatus = "Normal";
        break;
      case PregnancyStatus.Scissor_Delivery:
        pStatus = "Scissor";
        break;
      case PregnancyStatus.None:
        pStatus = "None";

        break;
    }

    switch (childStatus) {
      case ChildStatus.Death:
        cStatus = "Death";
        break;
      case ChildStatus.Alive:
        cStatus = "Alive";
        break;
      case ChildStatus.None:
        cStatus = "None";
        break;
    }
    Map response = await Requester.updatePregnancyStatus({
      'id': widget.pInfo['id'],
      'profile_id': widget.pInfo['profile_id'],
      'preg_status': pStatus,
      'child_status': cStatus
    });
    if (response['status'] == 'success') widget.onUpdate();
    return response['message'];
  }
}

// ###############################

class TrimesterCard extends StatefulWidget {
  final Map pInfo;
  final Map extra;
  final BuildContext contextX;
  TrimesterCard({this.pInfo, this.extra, this.contextX});
  @override
  _TrimesterCardState createState() => _TrimesterCardState();
}

class _TrimesterCardState extends State<TrimesterCard> {
  List reportsImgs, prescpImgs;
  File _imageFile;
  final picker = ImagePicker();
  bool isShowImage = false;
  Map image;
  Map triInfo;
  bool isListView = false;
  String name = "";
  int selectedTriNo = 0;
  String weight = "0", symptoms = "";
  String choosedMode;
  double containerHeight = 130;
  bool isloading = false;
  @override
  void initState() {
    super.initState();
    triInfo = {
      "weight": "0",
      "symptoms": "-",
    };
    reportsImgs = [];
    prescpImgs = [];

    getTrimesterInfo();
  }

  // API >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  void getTrimesterInfo() async {
    setState(() {
      isloading = true;
    });
    Map response = await Requester.getTrimesterInfo({
      "profile_id": widget.pInfo['profile_id'],
      "id": widget.pInfo['id'],
      "tri_no": widget.extra['tri_no']
    });

    if (response['status'] == 'error') {
    } else {
      List l;
      l = response['reports'];
      if (l.length != 0) reportsImgs = response['reports'];
      l = response['prescriptions'];
      if (l.length != 0) prescpImgs = response['prescriptions'];
      l = response['data'];
      if (l.length != 0) triInfo = response['data'][0];
    }
    setState(() {
      isloading = false;
    });
  }

  Future<String> updateTrimesterInfo({isImage: true}) async {
    Map response;
    Map data = {
      "profile_id": widget.pInfo['profile_id'],
      "id": widget.pInfo['id'],
      "tri_no": widget.extra['tri_no'],
    };

    if (isImage) {
      FormData fromData = new FormData.fromMap({
        "profile_id": widget.pInfo['profile_id'],
        "id": widget.pInfo['id'],
        "tri_no": widget.extra['tri_no'],
        "name": name,
        "type": choosedMode,
        "photo": await MultipartFile.fromFile(_imageFile.path,
            filename: path.basename(_imageFile.path))
      });

      response = await Uploader.uploadTrimesterReports(fromData);
    } else {
      data['weight'] = weight;
      data["symptoms"] = symptoms;
      response = await Requester.updateTrimesterInfo(data);
    }

    if (response['status'] == 'error') {
      return response['message'];
    } else {
      getTrimesterInfo();
      Scaffold.of(widget.contextX)
          .showSnackBar(SnackBar(content: Text(response['message'])));
    }

    return "";
  }

  // Build >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          color: Colors.blue,
          padding: EdgeInsets.all(7),
          child: Text(
            "${widget.extra['title']}",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        ),
        Row(
          children: [
            SizedBox(
              width: 10,
            ),
            Expanded(
                child: Text(
              "Month ${widget.extra['month']}",
              style: TextStyle(fontWeight: FontWeight.w500, color: Colors.red),
            )),
            Expanded(
                child: Text(
              "Weight : ${triInfo['weight']}",
              style: TextStyle(fontWeight: FontWeight.w500, color: Colors.blue),
            )),
            Expanded(
                child: Text(
              "${widget.extra['week']}",
              style: TextStyle(fontWeight: FontWeight.w500, color: Colors.red),
            )),
            // Checkbox(value: false, onChanged: (b) {})
            IconButton(
                icon: Icon(
                  Icons.edit,
                  color: Colors.blue,
                ),
                onPressed: () {
                  showEditDailog();
                })
          ],
        ),
        Row(
          children: [
            SizedBox(
              width: 10,
            ),
            Text(
              "Symptoms : ",
              style: TextStyle(fontWeight: FontWeight.w500, color: Colors.blue),
            ),
            Text(
              "${triInfo['symptoms']}",
              style: TextStyle(fontWeight: FontWeight.w500, color: Colors.red),
            ),
          ],
        ),
        getTabReportView()
      ]),
    );
  }

  Widget getTabReportView() {
    return Container(
        padding: EdgeInsets.only(top: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
                child: Container(
              height: containerHeight,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[500], width: 1)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                      color: Colors.blue,
                      iconSize: 20,
                      icon: Icon(
                        Icons.add_a_photo,
                        color: Colors.blue,
                        size: 20,
                      ),
                      onPressed: () {
                        choosedMode = "R";
                        showUploadBottomSheet(context);
                      }),
                  Expanded(
                    child: isloading
                        ? getLoadingContainer()
                        : this.reportsImgs.length == 0
                            ? getStatusContainer("No Reports")
                            : GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      SlideRightRoute(
                                          page: pReport.PregnancyReport(
                                              trimes: triInfo,
                                              type: "R",
                                              onUpdate: () {
                                                getTrimesterInfo();
                                              })));
                                },
                                child: GridView.builder(
                                    itemCount: reportsImgs.length > 6
                                        ? 6
                                        : reportsImgs.length,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                            crossAxisSpacing: 1.0,
                                            mainAxisSpacing: 2.0,
                                            childAspectRatio: 0.20 / 0.20),
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      if (index == 5) {
                                        return Container(
                                            color: Colors.black87,
                                            child: Center(
                                              child: Text(
                                                  "+${reportsImgs.length - 5}",
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      color: Colors.white)),
                                            ));
                                      }
                                      return Container(
                                        color: Colors.white,
                                        child: CachedNetworkImage(
                                          imageUrl: reportsImgs[index]['photo'],
                                          fit: BoxFit.cover,
                                          errorWidget: (context, error, v) =>
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
            Expanded(
                child: Container(
              height: containerHeight,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[500], width: 1)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                      color: Colors.blue,
                      iconSize: 20,
                      icon: Icon(
                        Icons.add_a_photo,
                        color: Colors.blue,
                        size: 20,
                      ),
                      onPressed: () {
                        choosedMode = "P";
                        showUploadBottomSheet(context);
                      }),
                  Expanded(
                    child: isloading
                        ? getLoadingContainer()
                        : this.prescpImgs.length == 0
                            ? getStatusContainer("No Prescription")
                            : GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      SlideRightRoute(
                                          page: pReport.PregnancyReport(
                                              trimes: triInfo,
                                              type: "P",
                                              onUpdate: () {
                                                getTrimesterInfo();
                                              })));
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
                                            childAspectRatio: 0.20 / 0.20),
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
                                                      color: Colors.white)),
                                            ));
                                      }
                                      return Container(
                                        color: Colors.white,
                                        child: CachedNetworkImage(
                                          imageUrl: prescpImgs[index]['photo'],
                                          fit: BoxFit.cover,
                                          errorWidget: (context, error, v) =>
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
          ],
        ));
  }

  void showEditDailog() {
    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(builder: (context, setStateT) {
              String uploadStatus = "Upload";
              return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Container(
                  padding: EdgeInsets.only(top: 10, left: 5, right: 5),
                  height: 300,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: Text(
                              "Update Trimester",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            )),
                            IconButton(
                                icon: Icon(Icons.close),
                                onPressed: () {
                                  Navigator.pop(context);
                                })
                          ],
                        ),
                        Divider(
                          thickness: 1,
                        ),
                        TextFormField(
                          onChanged: (val) {
                            weight = val;
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: "Weight"),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          onChanged: (val) {
                            symptoms = val;
                          },
                          decoration: InputDecoration(labelText: "symptoms"),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        RaisedButton(
                          onPressed: () async {
                            setStateT(() {
                              uploadStatus = "Updating...";
                            });

                            String message =
                                await updateTrimesterInfo(isImage: false);
                            if (message != "") {
                              setStateT(() {
                                uploadStatus = message;
                              });
                            } else
                              Navigator.pop(context);
                          },
                          child: Text(uploadStatus),
                        )
                      ]),
                ),
              );
            }));
  }

// Containers >>>>>>>>>>>>>>>>>>>>>>>
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

  void showImageDailog(BuildContext contextSf) {
    name = "";
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (contextS) {
          // String name = " ";
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
                            setStateT(() {
                              uploadStatus = "Uploading...";
                            });

                            String message = await updateTrimesterInfo();

                            if (message != "") {
                              setStateT(() {
                                uploadStatus = message;
                              });
                            } else
                              Navigator.pop(contextS);
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
}
