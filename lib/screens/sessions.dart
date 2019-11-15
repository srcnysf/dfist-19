import 'package:dfist19/data/Schedule.dart';
import 'package:dfist19/data/Session.dart';
import 'package:dfist19/data/SpeakerResponse.dart';
import 'package:dfist19/data/TimeslotSessions.dart' as Session1;
import 'package:dfist19/data/SessionsResponse.dart';
import 'package:dfist19/data/SheduleResponse.dart';
import 'package:dfist19/data/Timeslot.dart';
import 'package:dfist19/screens/sessionDetail.dart';
import 'package:dfist19/utils/API.dart';
import 'package:dfist19/widgets/bottomSheet.dart';
import 'package:dfist19/widgets/sessionItem.dart';
import 'package:flutter/material.dart';
import 'package:fluttie/fluttie.dart';
import 'package:jiffy/jiffy.dart';

class SessionsScreen extends StatefulWidget {
  final bool isSessions;

  @override
  _SessionsScreenState createState() => _SessionsScreenState();

  SessionsScreen(this.isSessions);
}

class _SessionsScreenState extends State<SessionsScreen> {
  FluttieAnimationController shockedEmoji;
  TextEditingController _controller = TextEditingController();
  var instance = Fluttie();
  FocusNode focus = new FocusNode();
  bool isVisible = false;

  SessionsResponse dataSessions = new SessionsResponse();
  ScheduleResponse dataSchedule = new ScheduleResponse();
  SpeakerResponse dataSpeaker = new SpeakerResponse();
  List<Session> _sessions;
  List<Schedule> _schedule;
  List<Timeslot> _timeslot;
  List<Session> _newSessionss;

  _onChanged(String value) async {
    _newSessionss.clear();
    if (value.isEmpty) {
      setState(() {});
      return;
    }
    setState(() {
      _newSessionss = _sessions
          .where(((session) =>
              session.data.title.toLowerCase().contains(value.toLowerCase())))
          .toList();
    });
  }

  @override
  void initState() {
    this.isVisible;
    this.focus.addListener(() {
      if (focus.hasFocus) {
        isVisible = false;
      }
    });
    prepareAnimation();
    _sessions = new List();
    _schedule = new List();
    _timeslot = new List();
    _newSessionss = new List();
    super.initState();
  }

  @override
  dispose() {
//    SessionItem().prepareAnimation();
    super.dispose();
    _controller.dispose();
  }

  prepareAnimation() async {
    var emojiComposition =
        await instance.loadAnimationFromAsset("assets/animations/anim.json");
    shockedEmoji = await instance.prepareAnimation(emojiComposition);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(focus);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isSessions ? "Sessions" : "Your Schedule",
              style: TextStyle(
                fontFamily: 'RedHatDisplay',
                color: Color(0xff333d47),
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.normal,
                letterSpacing: 0,
              )),
          elevation: 0.0,
          centerTitle: true,
          bottom: PreferredSize(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  child: Padding(
                    padding:
                        EdgeInsets.only(top: 16.0, left: 16.0, right: 10.0),
                    child: _search(context),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      FlatButton(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          child: Row(
                            children: <Widget>[
                              Text(
                                "Halls",
                                style: TextStyle(
                                  fontFamily: 'RedHatDisplay',
                                  color: Color(0xff373a42),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.normal,
                                  letterSpacing: 0,
                                ),
                                textAlign: TextAlign.left,
                              ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: Color(0xff333d47),
                                size: 28.0,
                              ),
                            ],
                          ),
                          onPressed: () {
                            _showModalSheet(context);
                          }),
                      FlatButton(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          child: Row(
                            children: <Widget>[
                              Text(
                                "Category",
                                style: TextStyle(
                                  fontFamily: 'RedHatDisplay',
                                  color: Color(0xff373a42),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.normal,
                                  letterSpacing: 0,
                                ),
                                textAlign: TextAlign.left,
                              ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: Color(0xff333d47),
                                size: 28.0,
                              ),
                            ],
                          ),
                          onPressed: () {
                            _showModalSheet(context);
                          })
                    ],
                  ),
                ),
              ],
            ),
            preferredSize: Size(
              MediaQuery.of(context).size.width,
              100.0,
            ),
          ),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 16.0),
            child: FutureBuilder<ScheduleResponse>(
                future: API.getSchedule(),
                builder: (context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    dataSchedule = snapshot.data;
                    _schedule = dataSchedule.schedule;
                    _timeslot = _schedule[0].data.timeslots;
                    return FutureBuilder<SessionsResponse>(
                        future: API.getSessions(),
                        builder: (context, AsyncSnapshot snapshot) {
                          if (!snapshot.hasData) {
                            return Center(child: CircularProgressIndicator());
                          } else {
                            dataSessions = snapshot.data;
                            _sessions = dataSessions.sessions;
                            return _newSessionss.length == 0 ||
                                    _controller.text.isEmpty
                                ? ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.vertical,
                                    itemCount: _timeslot.length,
                                    itemBuilder: (context, index1) {
                                      Timeslot _scheduleItem =
                                          _timeslot[index1];
                                      return Column(
                                        children: <Widget>[
                                          Center(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0, right: 8.0),
                                              child: Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Container(
                                                        height: 2,
                                                        decoration: new BoxDecoration(
                                                            color: Color(
                                                                    0xffcacdd4)
                                                                .withOpacity(
                                                                    0.5),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        2))),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 8.0,
                                                            left: 8.0),
                                                    child: Text(
                                                      "${_scheduleItem.startTime}-${_scheduleItem.endTime}",
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'RedHatDisplay',
                                                        color:
                                                            Color(0xff333d47),
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        fontStyle:
                                                            FontStyle.normal,
                                                        letterSpacing: 0,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                        height: 2,
                                                        decoration: BoxDecoration(
                                                            color: Color(
                                                                    0xffcacdd4)
                                                                .withOpacity(
                                                                    0.5),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        2))),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          ListView.builder(
                                            shrinkWrap: true,
                                            physics: ClampingScrollPhysics(),
                                            itemCount: _timeslot[index1]
                                                .sessions
                                                .length,
                                            itemBuilder: (context, index2) {
                                              return Column(
                                                children: <Widget>[
                                                  ListView.builder(
                                                    shrinkWrap: true,
                                                    physics:
                                                        ClampingScrollPhysics(),
                                                    itemCount: _timeslot[index1]
                                                        .sessions[index2]
                                                        .items
                                                        .length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      Session _session =
                                                          new Session();
                                                      Session1.Session
                                                          _sessionItem =
                                                          _timeslot[index1]
                                                              .sessions[index2];
                                                      for (var i = 0;
                                                          i < _sessions.length;
                                                          i++) {
                                                        print(_sessions.length);
                                                        if (_sessionItem
                                                                .items[index]
                                                                .toString() ==
                                                            _sessions[i].id) {
                                                          _session =
                                                              _sessions[i];
                                                        }
                                                      }
                                                      String starts;
                                                      String ends;
                                                      List<String> s =
                                                          _scheduleItem
                                                              .startTime
                                                              .split(":");
                                                      List<String> e =
                                                          _scheduleItem.endTime
                                                              .split(":");
                                                      var startTime = Jiffy({
                                                        "hour": int.parse(s[0]),
                                                        "minute":
                                                            int.parse(s[1])
                                                      });
                                                      var endTime = Jiffy({
                                                        "hour": int.parse(e[0]),
                                                        "minute":
                                                            int.parse(e[1])
                                                      });
                                                      if (_timeslot[index1]
                                                              .sessions[index2]
                                                              .items
                                                              .length >
                                                          1) {
                                                        if (index == 0) {
                                                          var endTimeJ = endTime
                                                            ..subtract(
                                                                minutes: 20);
                                                          starts = startTime
                                                              .format("HH:mm")
                                                              .toString();
                                                          ends = endTimeJ
                                                              .format("HH:mm")
                                                              .toString();
                                                        } else {
                                                          var startTimeJ =
                                                              startTime
                                                                ..add(
                                                                    minutes:
                                                                        20);
                                                          starts = startTimeJ
                                                              .format("HH:mm")
                                                              .toString();
                                                          ends = endTime
                                                              .format("HH:mm")
                                                              .toString();
                                                        }
                                                      } else {
                                                        starts = startTime
                                                            .format("HH:mm")
                                                            .toString();
                                                        ends = endTime
                                                            .format("HH:mm")
                                                            .toString();
                                                      }

                                                      return SessionItem(
//                                                        shockedEmoji:
//                                                            shockedEmoji,
//                                                        instance: instance,
                                                        speaker: _session.data
                                                                .speakers,
                                                        title:
                                                            _session.data.title,
                                                        time: '$starts - $ends',
                                                        track: _schedule[0]
                                                                    .data
                                                                    .tracks[
                                                                        index2]
                                                                    .title !=
                                                                null
                                                            ? _schedule[0]
                                                                .data
                                                                .tracks[index2]
                                                                .title
                                                            : "",
                                                        type: _session.data
                                                                    .tags !=
                                                                null
                                                            ? _session
                                                                .data.tags[0]
                                                            : "",
                                                        onPressed: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => SessionDetail(
                                                                    onPressed:
                                                                        () {},
                                                                    session:
                                                                        _session,
                                                                    time:
                                                                        '$starts - $ends',
                                                                    track: _schedule[
                                                                            0]
                                                                        .data
                                                                        .tracks[
                                                                            index2]
                                                                        .title)),
                                                          );
                                                        },
                                                      );
                                                    },
                                                  )
                                                ],
                                              );
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.vertical,
                                    itemCount: _newSessionss.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      Session _session = _newSessionss[index];
                                      String _time;
                                      String _track;
                                      for (Timeslot timeslot in _timeslot) {
                                        for (var i = 0;
                                            i < timeslot.sessions.length;
                                            i++) {
                                          for (var j = 0;
                                              j <
                                                  timeslot
                                                      .sessions[i].items.length;
                                              j++) {
                                            if (timeslot.sessions[i].items[j]
                                                    .toString() ==
                                                _session.id) {
                                              _time =
                                                  "${timeslot.startTime}-${timeslot.endTime}";
                                              _track = _schedule[0]
                                                  .data
                                                  .tracks[i]
                                                  .title;
                                            }
                                          }
                                        }
                                      }

                                      return SessionItem(
//                                                shockedEmoji: shockedEmoji,
//                                                instance: instance,
                                        speaker: _session.data.speakers !=
                                                    null &&
                                                _session.data.speakers.length >
                                                    0
                                            ? _session.data.speakers
                                            : "",
                                        title: _session.data.title,
                                        time: _time != null ? _time : " ",
                                        track: _track != null ? _track : " ",
                                        type: _session.data.tags != null
                                            ? _session.data.tags[0]
                                            : "",
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder:
                                                    (context) =>
                                                        SessionDetail(
                                                            onPressed: () {},
                                                            session: _session,
                                                            time: _time != null
                                                                ? _time
                                                                : " ",
                                                            track:
                                                                _track != null
                                                                    ? _track
                                                                    : " ")),
                                          );
                                        },
                                      );
                                    },
                                  );
                            //
                          }
                        });
                  }
                }),
          ),
        ),
      ),
    );
  }

  Widget _search(BuildContext context) {
    return Column(
      children: <Widget>[
        Card(
          elevation: 0.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          semanticContainer: true,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                new BoxShadow(color: Colors.grey[200], blurRadius: 10.0)
              ],
              borderRadius: BorderRadius.all(
                Radius.circular(14.0),
              ),
            ),
            child: TextField(
              focusNode: focus,
              controller: _controller,
              onChanged: _onChanged,
              autocorrect: true,
              onTap: () {
                FocusScope.of(context).requestFocus(focus);
                isVisible = true;
              },
              onEditingComplete: () {
                isVisible = false;
              },
              onSubmitted: (text) {
                isVisible = false;
              },
              style: TextStyle(
                fontFamily: 'RedHatDisplay',
                color: Color(0xff80848b),
                fontSize: 15,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.normal,
                letterSpacing: 0,
              ),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(14.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.0),
                  borderSide: BorderSide(
                    color: Colors.transparent,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.transparent,
                  ),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                hintText: "Search..",
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey,
                ),
                suffixIcon: new Visibility(
                  visible: isVisible,
                  child: IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Colors.grey,
                    ),
                    onPressed: _controller.clear,
                  ),
                ),
                hintStyle: TextStyle(
                  fontFamily: 'RedHatDisplay',
                  color: Color(0xff80848b),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.normal,
                  letterSpacing: 0,
                ),
              ),
              maxLines: 1,
            ),
          ),
        ),
      ],
    );
  }

  void _showModalSheet(BuildContext context) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32.0),
          topRight: Radius.circular(32.0),
        )),
        context: context,
        builder: (context) {
          return new Container(
            height: 430,
            child: new Stack(
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: 24.0, top: 14.0, right: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      MaterialButton(
                        child: new Text("Reset",
                            style: TextStyle(
                              fontFamily: 'RedHatDisplay',
                              color: Color(0xff333d47),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.normal,
                              letterSpacing: 0,
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 30.0),
                        child: new Text("Categories",
                            style: TextStyle(
                              fontFamily: 'RedHatDisplay',
                              color: Color(0xff333d47),
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              fontStyle: FontStyle.normal,
                              letterSpacing: 0,
                            )),
                      ),
                      IconButton(
                        icon: Icon(Icons.clear,
                            color: Color(0xff333d47), size: 24),
                        onPressed: () {
                          Navigator.pop(context);
                          FocusScope.of(context).requestFocus(new FocusNode());
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 64.0),
                  child: BottomSheetList(),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    color: Colors.white,
                    height: MediaQuery.of(context).size.height / 11,
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16.0, bottom: 8.0),
                      child: GestureDetector(
                        child: Card(
                          color: Color(0xff3196f6),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.0)),
                          child: Center(
                            child: new Text("Apply Filter",
                                style: TextStyle(
                                  fontFamily: 'RedHatDisplay',
                                  color: Color(0xffffffff),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  fontStyle: FontStyle.normal,
                                  letterSpacing: 0,
                                )),
                          ),
                        ),
                        onTap:() {
                          Navigator.pop(context);
                          FocusScope.of(context).requestFocus(new FocusNode());
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
