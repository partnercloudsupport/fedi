import 'package:flutter/material.dart';
import 'package:fedi/definitions/item.dart';
import 'package:fedi/views/item.dart';
import 'package:fedi/definitions/instance.dart';
import 'package:fedi/definitions/user.dart';
import 'package:fedi/api/gettimeline.dart';
import 'dart:async';

class TimeLine extends StatefulWidget {
  final Instance instance;
  final String authCode;
  final List<Item> statuses;
  final Function inittimeline;
  final User currentUser;
  final Key key;

  TimeLine(
      {this.instance,
      this.authCode,
      this.statuses,
      this.inittimeline,
      this.currentUser,
      this.key});
  @override
  TimeLineState createState() => new TimeLineState();
}

class TimeLineState extends State<TimeLine> {
  Widget contents = new Center(child: CircularProgressIndicator());
  List<Item> _statuses = new List();

  @override
  void initState() {
    super.initState();
  }

  Widget statusListView() {
    return new ListView.builder(
      itemBuilder: (context, i) {
        final index = i;
        if (index >= _statuses.length) {
          return null;
        }
        return ItemBuilder(
            instance: widget.instance,
            authCode: widget.authCode,
            item: _statuses[index],
            isContext: false,
            currentUser: widget.currentUser,
            key: Key(_statuses[index].id));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.statuses == null || widget.statuses.length == 0) {
      widget.inittimeline();
    } else {
      setState(() {
        _statuses = widget.statuses;
        contents = statusListView();
      });
    }

    return contents;
  }
}
