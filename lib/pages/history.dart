import 'package:flutter/material.dart';
import 'package:hiking4nerds/services/database_helpers.dart';
import 'package:hiking4nerds/styles.dart';
import 'package:hiking4nerds/components/route_canvas.dart';
import 'package:hiking4nerds/services/elevation_chart.dart';
import 'package:hiking4nerds/services/localization_service.dart';
import 'package:hiking4nerds/services/route.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<HistoryEntry> _routes = [];
  bool _routesLoaded = false;

  @override
  void initState() {
    super.initState();
    loadAllRoutes();
  }

  Future loadAllRoutes() async {
    List<HikingRoute> routes = await DatabaseHelper.instance.queryAllRoutes();
    setState(() {
      _routes.clear();
      if(routes != null) routes.forEach((entry) => _routes.add(HistoryEntry(context, entry)));
      _routesLoaded = true;
    });    
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_routesLoaded) {
      body = Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RaisedButton(
              child: Text('Load Routes'),
              onPressed: () {
                loadAllRoutes();
              },
            ),
          ),
          Expanded(
            child: SizedBox(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return InkWell(
                      onTap: () {},
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      20.0, 12.0, 12.0, 12.0),
                                  child: Container(
                                    child: _routes[index].routeCanvas,
                                    decoration: new BoxDecoration(
                                        color: Colors.grey[300],
                                        border:
                                            Border.all(color: Colors.grey[600]),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey,
                                            blurRadius: 3.0,
                                          ),
                                        ],
                                        borderRadius: new BorderRadius.all(
                                            const Radius.circular(3.0))),
                                  )),
                              // Padding(
                              //   padding:
                              //       const EdgeInsets.only(top: 10, bottom: 10),
                              //   child: SizedBox(
                              //     width:
                              //         MediaQuery.of(context).size.width * 0.5,
                              //     child: Wrap(
                              //       spacing: 5,
                              //       runSpacing: -10,
                              //       children: generateChips(_routeList[index]),
                              //     ),
                              //   ),
                              // ),
                              Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 12, 12, 0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        "${_routes[index].distance} km",
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[600]),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        "${_routes[index].time} min",
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[600]),
                                      ),
                                    ],
                                  )),
                            ],
                          ),
                          Divider(
                            height: 2.0,
                            color: Colors.grey,
                          )
                        ],
                      ));
                },
                itemCount: _routes.length,
              ),
            ),
          ),
        ],
      );
    } else {
      body = Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RaisedButton(
              child: Text('Load Routes'),
              onPressed: () {
                loadAllRoutes();
              },
            ),
          ),
          Center(
            child: new CircularProgressIndicator(),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: htwGreen,
        title: Text(LocalizationService().getLocalization(
            english: 'History',
            german: 'Verlauf')),
        elevation: 0,
      ),
      body: body,
    );
  }
}

class HistoryEntry {
  String date; // Route date - created
  String distance; // Route length in KM
  String time; // Route time needed in Minutes
  RouteCanvasWidget routeCanvas;
  ElevationChart chart;
  List<String> pois = [];

  // RouteListTile({ this.title, this.date, this.distance, this.avatar });

  HistoryEntry(BuildContext context, HikingRoute route) {
    this.date = route.date.toString();
    this.distance = formatDistance(route.totalLength);
    this.time = (route.totalLength * 12).toInt().toString();
    this.routeCanvas = RouteCanvasWidget(
      MediaQuery.of(context).size.width * 0.2,
      MediaQuery.of(context).size.width * 0.2,
      route.path,
      lineColor: Colors.black,
    );
    print('History Entry $date $distance Nodes ${route.path.length}');
  }

  String formatDistance(double n) {
    return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 2);
  }
}
