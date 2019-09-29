import 'dart:io';

import 'package:analytics_event_gen/analytics_event_gen.dart';
import 'package:authpass/bloc/app_data.dart';
import 'package:authpass/env/_base.dart';
import 'package:authpass/ui/screens/password_list.dart';
import 'package:authpass/utils/path_utils.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:usage/usage_io.dart' as usage;

part 'analytics.g.dart';

final _logger = Logger('analytics');

class Analytics {
  Analytics({@required this.env}) {
    _init();
  }

  static void trackError(String description, bool fatal) {
    _errorGa?.sendException(description, fatal: fatal);
  }

  final Env env;
  final AnalyticsEvents events = _$AnalyticsEvents();

  usage.Analytics _ga;

  /// global analytics tracker we use for error reporting.
  static usage.Analytics _errorGa;
  static const _gaPropertyMapping = <String, String>{
    'platform': 'cd1',
    'userType': 'cd2',
  };

  Future<void> _init() async {
    final info = await env.getAppInfo();
    _logger.fine('Got PackageInfo: ${info.appName}, ${info.buildNumber}, ${info.packageName}');
    if (env.secrets.analyticsGoogleAnalyticsId != null) {
      final docsDir = await PathUtils().getAppDataDirectory();
      _ga = usage.AnalyticsIO(
        env.secrets.analyticsGoogleAnalyticsId,
        info.appName,
        '${info.version}+${info.buildNumber}',
        documentDirectory: docsDir,
      );
      _errorGa = _ga;
      _ga.setSessionValue(_gaPropertyMapping['platform'], Platform.operatingSystem);
    } else {
      _logger.info('No analyics Id defined. Not tracking anyting.');
    }

    events.registerTracker((event, params) {
      final label = params.entries.map((e) => '${e.key}=${e.value}').join(',');
      _logger.finer('event($event, $params) - label: $label');
//      _amplitude?.logEvent(name: event, properties: params);
      _ga?.sendEvent(
        'track',
        event,
        label: label,
        parameters: Map.fromEntries(params.entries.map((entry) {
          final custom = _gaPropertyMapping[entry.key];
          if (custom == null) {
            return null;
          }
          return MapEntry(custom, entry.value?.toString());
        }).where((entry) => entry != null)),
      );
    });
  }

  void trackScreen(String screenName) {
    _logger.finer('trackScreen($screenName)');
    _ga?.sendScreenView(screenName);
  }
}

abstract class AnalyticsEvents implements AnalyticsEventStubs {
  void trackLaunch();

  void trackCreateFile();

  void trackOpenFile({@required OpenedFilesSourceType type});

  void trackSelectEntry({EntrySelectionType type});

  void trackCopyField({@required String key});

  void trackCloseAllFiles({int count});

  void trackUserType({String userType});

  void trackCloseFile();

  /// weird case of empty password list.
  void trackPasswordListEmpty();
}
