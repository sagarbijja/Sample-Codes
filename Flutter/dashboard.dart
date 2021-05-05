import 'package:flutter/material.dart';
import 'package:online_appointment/models/notifier_models.dart';
import 'package:online_appointment/models/user_model.dart';
import 'package:online_appointment/screens/auth/login.dart';
import 'package:online_appointment/screens/tabs/about.dart';
import 'package:online_appointment/screens/tabs/settings.dart';
import 'package:online_appointment/screens/tabs/user_notifications.dart';
import 'package:online_appointment/screens/tabs/your_appointments.dart';
import 'package:online_appointment/screens/tabs/favourites.dart';
import 'package:online_appointment/screens/tabs/news_feeds.dart';
import 'package:online_appointment/services/api_requester.dart';
import 'package:online_appointment/widgets/transition.dart';
import 'package:provider/provider.dart';
import 'tabs/search_hospital.dart';
import 'tabs/profiles.dart';
import 'package:flutter_badged/flutter_badge.dart';
// import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'dart:io';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path;

class Dashboard extends StatefulWidget {
  final List<UserModel> userList;
  final int tabIndex;
  Dashboard({this.userList, this.tabIndex = -1});
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _tabIndex = 0;
  List<Widget> tabs;
  List tabTitles;
  UserModel mainUser;
  bool isFeedSearch = false;
  UserNotifications userNotifications;
  @override
  void initState() {
    if (widget.tabIndex != -1) {
      _tabIndex = widget.tabIndex;
    }
    mainUser = widget.userList[0];
    super.initState();
    tabTitles = List<String>();
    tabs = List<Widget>();
    tabTitles.add("News Feeds");
    tabs.add(NewsFeeds(
      mainUser: mainUser,
    ));
    tabTitles.add("Profiles");
    tabs.add(Profiles(userList: widget.userList));
    tabTitles.add("Family Appointments");
    tabs.add(Appointments(userList: widget.userList));
    tabTitles.add("Search Hospital");
    tabs.add(SearchHospital());
    tabTitles.add("Favorites");
    tabs.add(Favourites());
    tabTitles.add("Notificatons");
    tabs.add(UserNotifications());
    tabTitles.add("Settings");
    tabs.add(Settings(user: widget.userList[0]));
    tabTitles.add("About App");
    tabs.add(About());
    tabTitles.add("Logout");
  }

  void initCloudMessaging() async {
    final Directory dir = await path.getTemporaryDirectory();
    Hive.init(dir.path);
    Box box = await Hive.openBox('notificationBox');
    // String token = await FirebaseMessaging.instance.getToken();
    // print("Your Token : $token");
    RemoteMessage initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _tabIndex = 5;
      print("Got Notification ");
      box.add({
        "notification": {
          "title": initialMessage.notification.title,
          "body": initialMessage.notification.body
        }
      });

      // setState(() {});
    }

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message != null) {
        _tabIndex = 5;
        print("Got Notification from Forground");
        box.add({
          "notification": {
            "title": message.notification.title,
            "body": message.notification.body
          }
        });
        // setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    initCloudMessaging();

    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          if (_tabIndex < 5) {
            return true;
          } else {
            setState(() {
              _tabIndex = 0;
            });
          }
          return false;
        },
        child: Scaffold(
          // resizeToAvoidBottomPadding: true,
          // App Bar >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
          appBar: getAppBar(context),
          body: IndexedStack(
            index: _tabIndex,
            children: tabs,
          ),
          drawer: getDrawer(context),
          bottomNavigationBar: _tabIndex > 4
              ? SizedBox()
              : Consumer<BadgeNotifier>(builder:
                  (BuildContext context, BadgeNotifier model, Widget child) {
                  // Provider.of<BadgeNotifier>(context, listen: false).appointment++;
                  return BottomNavigationBar(
                    items: <BottomNavigationBarItem>[
                      BottomNavigationBarItem(
                        icon: FlutterBadge(
                          icon: Icon(Icons.backup_table),
                          itemCount: model.newsFeed,
                          borderRadius: 20.0,
                        ),
                        label: 'News Feeds',
                      ),
                      BottomNavigationBarItem(
                        icon: FlutterBadge(
                          icon: Icon(Icons.person),
                          itemCount: model.profile,
                          borderRadius: 20.0,
                        ),
                        label: 'Profiles',
                      ),
                      BottomNavigationBarItem(
                        icon: FlutterBadge(
                          icon: Icon(Icons.assignment),
                          itemCount: model.appointment,
                          borderRadius: 20.0,
                        ),
                        label: 'Appointments',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.search),
                        label: 'Search',
                      ),
                      BottomNavigationBarItem(
                        icon: FlutterBadge(
                          icon: Icon(Icons.bookmark),
                          itemCount: model.favorite,
                          borderRadius: 20.0,
                        ),
                        label: 'Favorite',
                      ),
                    ],
                    currentIndex: _tabIndex,
                    unselectedItemColor: Colors.green,
                    selectedItemColor: Colors.blue[700],
                    onTap: (index) {
                      switch (index) {
                        case 0:
                          Provider.of<BadgeNotifier>(context, listen: false)
                              .newsFeed = 0;
                          break;
                        case 1:
                          Provider.of<BadgeNotifier>(context, listen: false)
                              .profile = 0;
                          break;
                        case 2:
                          Provider.of<BadgeNotifier>(context, listen: false)
                              .appointment = 0;
                          break;
                        case 4:
                          Provider.of<BadgeNotifier>(context, listen: false)
                              .favorite = 0;
                          break;
                      }
                      switchTo(index, context);
                    },
                  );
                }),
        ),
      ),
    );
  }

  AppBar getAppBar(BuildContext context) {
    List<Widget> actions = [];
    // Actions:
    switch (tabTitles[_tabIndex]) {
      case "News Feeds":
        actions.add(tabTitles[_tabIndex] == "News Feeds"
            ? IconButton(
                icon: Icon(
                  isFeedSearch ? Icons.close : Icons.search,
                ),
                onPressed: () {
                  setState(() {
                    isFeedSearch = !isFeedSearch;
                  });
                })
            : SizedBox());
        break;
      case "Profiles":
        actions.add(IconButton(
            icon: Icon(
              Icons.person_add,
            ),
            onPressed: () {
              Profiles p = tabs[_tabIndex];
              p.addProfile();
            }));
        break;
    }
    // App Bars:
    switch (tabTitles[_tabIndex]) {
      case "News Feeds":
        return AppBar(
            title: isFeedSearch
                ? TweenAnimationBuilder(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    tween: Tween<double>(begin: -150, end: 0),
                    builder: (context, double _val, _) => Transform.translate(
                      offset: Offset(_val, 0),
                      child: TextField(
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Search Here",
                          hintStyle: TextStyle(color: Colors.white),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.white,
                          ),
                          // contentPadding: EdgeInsets.symmetric(horizontal: 10)
                        ),
                        onChanged: (String val) {
                          NewsFeeds n = tabs[0];
                          n.search(val);
                        },
                      ),
                    ),
                  )
                : Text(tabTitles[_tabIndex]),
            actions: actions);
      case "Profiles":
        return AppBar(
          title: Text(tabTitles[_tabIndex]),
          actions: actions,
        );
    }
    return AppBar(
      title: Text(tabTitles[_tabIndex]),
    );
  }

  Drawer getDrawer(context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(mainUser.name),
            accountEmail: Text(mainUser.email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).platform == TargetPlatform.iOS
                  ? Colors.blue
                  : Colors.white,
              child: Text(
                mainUser.name[0].toUpperCase(),
                style: TextStyle(fontSize: 40.0),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text(
              'Home',
            ),
            onTap: () {
              switchTo(-1, context, isDrawer: true);
            },
          ),
        
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notification'),
            onTap: () {
              switchTo(0, context, isDrawer: true);
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text("Settings"),
            onTap: () {
              switchTo(1, context, isDrawer: true);
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About App'),
            onTap: () {
              switchTo(2, context, isDrawer: true);
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {
              logout();
            },
          ),
        ],
      ),
    );
  }

  void switchTo(int index, BuildContext context, {isDrawer = false}) {
    isFeedSearch = false;
    if (index == -1)
      index = 0;
    else if (isDrawer) index += 5;

    _tabIndex = index;
    if (isDrawer) Navigator.of(context).pop();
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    setState(() {});
  }

  void logout() async {
    // await FirebaseAuth.instance.signOut();
    final Directory dir = await path.getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    Box box = await Hive.openBox('userBox');
    await box.clear();
    await Requester.clearAllCache();
    print("Logout");
    Navigator.pushAndRemoveUntil(
        context, SizeRoute(page: Login()), (Route<dynamic> route) => false);
  }
}

/*
BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'News Feeds',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profiles',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorite',
          ),
        ],
        currentIndex: _tabIndex,
        unselectedItemColor: Colors.green,
        selectedItemColor: Colors.blue[700],
        onTap: (index) {
          switchTo(index, context);
        },
      ),
*/

/*
Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 20, color: Colors.black.withOpacity(.1))
                          ]),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 8),
                          child: GNav(
                              color: Colors.white,
                              gap: 8,
                              activeColor: Colors.white,
                              iconSize: 24,
                              padding:
                                  EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                              duration: Duration(milliseconds: 800),
                              tabBackgroundColor: Colors.blue[300],
                              tabs: [
                                GButton(
                                  icon: Icons.library_add,
                                  text: 'New Feeds',
                                ),
                                GButton(
                                  icon: Icons.bookmark,
                                  text: 'Appointments',
                                ),
                                GButton(
                                  icon: Icons.favorite,
                                  text: 'Favorites',
                                ),
                              ],
                              selectedIndex: _tabIndex,
                              onTabChange: (index) {
                                setState(() {
                                  _tabIndex = index;
                                });
                              }),
                        ),
                      ),
                    );


*/
