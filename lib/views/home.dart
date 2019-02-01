import 'package:flutter/material.dart';
import 'package:fedi/views/post.dart';
import 'package:fedi/views/timeline.dart';
import 'package:fedi/views/notifications.dart';
import 'package:fedi/views/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fedi/definitions/instance.dart';
import 'package:fedi/definitions/item.dart';
import 'dart:async';
import 'dart:collection';
import 'package:fedi/api/gettimeline.dart';

class Home extends StatefulWidget {
  @override
  HomeState createState() => new HomeState();
}

class HomeState extends State<Home> with SingleTickerProviderStateMixin {
  Instance instance;
  String authCode;
  TabController _tabController;

  List<Item> _statuses = new List();
  String _currentTab;

  LinkedHashMap<String, Widget> _tabs = LinkedHashMap.from({
    "tabOne": new Center(
      child: CircularProgressIndicator(),
    ),
    "tabTwo": new Center(
      child: CircularProgressIndicator(),
    ),
    "tabThree": new Center(
      child: CircularProgressIndicator(),
    ),
    "tabFour": new Center(
      child: CircularProgressIndicator(),
    ),
  });

  List<Widget> _tabList = List<Widget>();

  void _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('authenticated', false);
    prefs.setString('userAuth', null);
    prefs.setString('instance', null);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LogIn()));
  }

  void _postStatus() async {
    final _newStatus = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Post(
                  instance: instance,
                  authCode: authCode,
                )));
    setState(() {
      List<Item> _newlist = List();
      _newlist.add(_newStatus);
      _newlist.addAll(_statuses);
      _statuses = _newlist;
    });
  }

  Future<void> _newStatuses(String timeline) async {
    List<Item> statusList;
    statusList = await getTimeline(instance, authCode, timeline);

    try {
      setState(() {
        _statuses = statusList;
        _resetTabs();
        // contents = statusListView();
      });
    } catch (e) {
      print(e);
    }
  }

  void _resetTabs() {
    setState(() {
      _tabs["tabOne"] = RefreshIndicator(
        child: TimeLine(
          instance: instance,
          authCode: authCode,
          timeline: "home",
          statuses: _statuses,
          lasttimeline: _currentTab,
          inittimeline: _initTimeline,
        ),
        key: Key("home"),
        onRefresh: () => _newStatuses("home"),
      );
      _tabs["tabTwo"] = Notifications(
        instance: instance,
        authCode: authCode,
      );
      _tabs["tabThree"] = RefreshIndicator(
        child: TimeLine(
          instance: instance,
          authCode: authCode,
          timeline: "local",
          statuses: _statuses,
          lasttimeline: _currentTab,
          inittimeline: _initTimeline,
        ),
        key: Key("local"),
        onRefresh: () => _newStatuses("local"),
      );
      _tabs["tabFour"] = RefreshIndicator(
        child: TimeLine(
          instance: instance,
          authCode: authCode,
          timeline: "public",
          statuses: _statuses,
          lasttimeline: _currentTab,
          inittimeline: _initTimeline,
        ),
        key: Key("public"),
        onRefresh: () => _newStatuses("local"),
      );

      _tabList = List<Widget>.from(_tabs.values.toList());
    });
  }

  Future<bool> _initTimeline(String timeline) async {
    List<Item> statusList;
    statusList = await getTimeline(instance, authCode, timeline);
    try {
      setState(() {
        _statuses = statusList;
        _resetTabs();
      });
    } catch (e) {
      print(e);
      return false;
    }
    return true;
  }

  Future<void> verifyAuth() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var auth = prefs.getBool('authenticated') ?? false;
    var userAuth = prefs.getString('userAuth') ?? null;
    var instanceUrl = prefs.getString('instance') ?? null;

    if (auth == false || userAuth == null || instanceUrl == null) {
      _logout(context);
    } else {
      Instance newInstance = await Instance.fromUrl(instanceUrl);
      setState(() {
        instance = newInstance;
        authCode = userAuth;

        _resetTabs();
      });
    }
  }

  _tabChange() {
    setState(() {
      _currentTab = _tabs.keys.elementAt(_tabController.index);
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _tabList = List<Widget>.from(_tabs.values.toList());
      _tabController = TabController(vsync: this, length: _tabList.length);
      _tabController.addListener(_tabChange);
      _currentTab = _tabs.keys.elementAt(_tabController.index);
    });
    verifyAuth();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.home)),
            Tab(icon: Icon(Icons.notifications)),
            Tab(icon: Icon(Icons.people)),
            Tab(icon: Icon(Icons.public)),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            // TODO: rest of the drawer
            // TODO: user header
            ListTile(
              title: Text('Logout'),
              onTap: () {
                _logout(context);
              },
            )
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabList,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _postStatus,
        child: Icon(Icons.edit),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
    );
  }
}
