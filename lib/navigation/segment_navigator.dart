import 'package:flutter/material.dart';
import 'package:hiking4nerds/app.dart';
import 'package:hiking4nerds/navigation/bottom_navigation.dart';
import 'package:hiking4nerds/pages/history.dart';
import 'package:hiking4nerds/pages/map.dart';
import 'package:hiking4nerds/pages/more/more.dart';
import 'package:hiking4nerds/pages/setup/location_selection.dart';
import 'package:hiking4nerds/pages/setup/route_preferences.dart';
import 'package:hiking4nerds/pages/setup/route_list.dart';
import 'package:hiking4nerds/pages/setup/route_preview.dart';
import 'package:hiking4nerds/services/route.dart';
import 'package:hiking4nerds/services/sharing/import_service.dart';

class SegmentRoutes {
  static const String root = '/';
  static const String locationSelection = '/setup/locationselection';
  static const String routePreferences = '/setup/routepreferences';
  static const String routeList = '/setup/routelist';
  static const String routePreview = '/setup/routepreview';
  static const String more = '/more';
}

/// There are two options for navigation between pages.
/// Option 1 switch to another page within the same segment
/// > to achieve this pass an onPushY callback inside the
/// > corresponding page and call the _push function with
/// > the route you want to switch to
/// > example creates an PageX with the ability to switch to PageY:
/// > PageX(onPushY: () => _push(context, SegmentRoutes.Y));
/// > passing parameters is possible through an Map<String, dynamic>
/// > example:
/// > onPushX: (param) => _push(context, SegmentRoutes.X, {"param-name": param})
/// > make sure to resolve the param on the receiving Page in _routeBuilder()
/// > PageY(paramName: param["param-name"]
///
/// Option 2 switch to another root segment (tab inside the bottom nav bar)
/// > to achieve this pass an onPushY callback inside the
/// > corresponding page and call the onChangeSegment callback function with
/// > the segment you want to switch to
/// > example switches to segment
/// > onPushY: ([params]) => onChangeSegment(AppSegment.X, reset prev segment)
/// > additional option to update the state of this segment (updateState)
class SegmentNavigator extends StatelessWidget {
  static GlobalKey<MapPageState> mapKey = GlobalKey<MapPageState>();
  static GlobalKey<HistoryPageState> historyKey = GlobalKey<HistoryPageState>();
  static ImportService _importService = new ImportService();
  final ChangeSegmentCallback onChangeSegment;
  final GlobalKey<NavigatorState> navigatorKey;
  final AppSegment segment;

  SegmentNavigator({@required this.navigatorKey, @required this.segment, @required this.onChangeSegment}) {
    _importService.addLifecycleIntentHandler(switchToHistory: (() {
      onChangeSegment(AppSegment.history);
      historyKey.currentState.updateState();
    }));
  }

  /// resolves the corresponding root page for an specified segment
  Widget _findRootPage(BuildContext context, AppSegment segment) {
    switch (segment) {
      case AppSegment.setup:
        return LocationSelectionPage(
            onPushRoutePreferences: (routeParams) => _push(context,
                SegmentRoutes.routePreferences, {"route-params": routeParams}));
      case AppSegment.map:
        return MapPage(key: mapKey);
      case AppSegment.history:
        return HistoryPage(key: historyKey, onSwitchToMap: (HikingRoute route) {
          onChangeSegment(AppSegment.map);
          mapKey.currentState.updateState(route, false);
        },);
      case AppSegment.more:
        return MorePage();
    }

    throw new Exception(
        "SegmentNavigator: Segment not specified for " + segment.toString());
  }

  /// maps routes to root pages and sub pages
  Map<String, WidgetBuilder> _routeBuilders(BuildContext context,
      [Map<String, dynamic> params]) {
    return {
      SegmentRoutes.routePreferences: (context) => RoutePreferences(
            routeParams: params["route-params"],
            onPushRouteList: (routeParams) => _push(context,
                SegmentRoutes.routeList, {"route-params": routeParams}),
          ),
      SegmentRoutes.routeList: (context) => RouteList(
            routeParams: params["route-params"],
            onPushRoutePreview: (routeParams) => _push(context,
                SegmentRoutes.routePreview, {"route-params": routeParams}),
          ),
      SegmentRoutes.routePreview: (context) => RoutePreviewPage(
          routeParams: params["route-params"],
          onSwitchToMap: (route) {
            onChangeSegment(AppSegment.map);
            // refresh the state of the new segment by passing parameters
            mapKey.currentState.updateState(route);
          }),
    };
  }

  void _push(BuildContext context, String route,
      [Map<String, dynamic> params]) {
    WidgetBuilder widget = _routeBuilders(context, params)[route];

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => widget(context)));
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      initialRoute: SegmentRoutes.root,
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (context) => _findRootPage(context, segment),
        );
      },
    );
  }
}

/// changes current segment to specified segment, optionally
/// pop previous segment to root page
typedef ChangeSegmentCallback = void Function(AppSegment segment,
    [bool popToRoot]);
