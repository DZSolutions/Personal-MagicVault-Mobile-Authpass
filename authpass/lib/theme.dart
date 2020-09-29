import 'package:authpass/utils/platform.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

final _logger = Logger('theme');

class AuthPassTheme {
  static const monoFontFamily = 'JetBrainsMono';
//  static const Color linkColor = Colors.blueAccent;
  static const int _primaryColorValue = 0xFFE91E63;
  static const Color primaryColor = Color(_primaryColorValue);
  static const Color linkColor = primaryColor;
  static const MaterialColor primarySwatch =
      MaterialColor(_primaryColorValue, <int, Color>{
    50: Color(0xFFFCE4EC),
    100: Color(0xFFF8BBD0),
    200: Color(0xffF48FB1),
    300: Color(0xFFF06292),
    400: Color(0xFFEC407A),
    500: Color(0xFFE91E63),
    600: Color(0xFFD81B60),
    700: Color(0xFFC2185B),
    800: Color(0xFFAD1457),
    900: Color(0xFF880E4F),
  });

  static const defaultFileColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    primaryColor,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
    Colors.black,
  ];
  static const defaultColorOrder = [
    //DEFAULT COLOR
    Colors.green,
    Colors.orange,
    Colors.blueGrey,
    Colors.deepPurple,
  ];
}

abstract class Breakpoints {
  static const TABLET_WIDTH = 720;
}

// during development use getters :-)
//ThemeData get authPassLightTheme => createTheme();
//ThemeData get authPassDarkTheme => createDarkTheme();
final authPassLightTheme = createTheme();
final authPassDarkTheme = createDarkTheme();

ThemeData _customize(ThemeData base) {
  final pageTransitionBuilders = {...const PageTransitionsTheme().builders};
  pageTransitionBuilders[TargetPlatform.macOS] =
      const FadeUpwardsPageTransitionsBuilder();
  return base.copyWith(
    pageTransitionsTheme:
        PageTransitionsTheme(builders: pageTransitionBuilders),
  );
}

bool _addedInterLicense = false;

Typography _getTypography() {
  if (defaultTargetPlatform == TargetPlatform.macOS &&
      // macos 10.15 -> darwin 19.0
      // https://en.wikipedia.org/wiki/MacOS_Mojave#Release_history
      // https://en.wikipedia.org/wiki/MacOS_Catalina#Release_history
      !_isDarwinVersion(minimumMajor: 19, minimumMinor: 0)) {
    if (!_addedInterLicense) {
      LicenseRegistry.addLicense(() async* {
        final license =
            await rootBundle.loadString('assets/fonts/Inter-LICENSE.txt');
        yield LicenseEntryWithLineBreaks(['fonts_inter'], license);
      });
      _addedInterLicense = true;
    }
    return Typography.material2018(
      platform: defaultTargetPlatform,
      black: Typography.blackCupertino.apply(fontFamily: 'Inter'),
      white: Typography.whiteCupertino.apply(fontFamily: 'Inter'),
    );
  } else {
    print(
        'using default theme $defaultTargetPlatform -- ${AuthPassPlatform.operatingSystemVersion}');
    return Typography.material2018(platform: defaultTargetPlatform);
  }
}

final macOsVersionPattern = RegExp(r'Darwin (\d+)\.(\d+)');

bool _isDarwinVersion(
    {@required int minimumMajor, @required int minimumMinor}) {
  assert(minimumMajor != null);
  assert(minimumMinor != null);
  final match =
      macOsVersionPattern.firstMatch(AuthPassPlatform.operatingSystemVersion);
  if (match == null) {
    _logger.severe(
        'Unable to parse mac os version ${AuthPassPlatform.operatingSystemVersion}');
    return false;
  }
  final major = int.parse(match.group(1));
  final minor = int.parse(match.group(2));
  print('Parsed ${AuthPassPlatform.operatingSystemVersion} as $major.$minor');
  _logger.finest(
      'Parsed ${AuthPassPlatform.operatingSystemVersion} as $major.$minor');
  return major > minimumMajor ||
      (major == minimumMajor && minor >= minimumMinor);
}

ThemeData createTheme() {
  return _customize(ThemeData(
    primarySwatch: AuthPassTheme.primarySwatch,
    typography: _getTypography(),
  ));
}

ThemeData createDarkTheme() {
  final colorScheme = ColorScheme.dark(
    primary: AuthPassTheme.primaryColor,
    secondary: AuthPassTheme.primarySwatch[300],
    secondaryVariant: AuthPassTheme.primarySwatch[500],
  );
  return _customize(ThemeData(
    typography: _getTypography(),
    primaryColor: colorScheme.primary,
    textSelectionHandleColor: AuthPassTheme.primarySwatch[800],
//    textSelectionColor: Colors.red,
    toggleableActiveColor: colorScheme.primary,
//    cursorColor: Colors.red,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    primarySwatch: AuthPassTheme.primarySwatch,
    accentColor: AuthPassTheme.primaryColor,
    selectedRowColor: colorScheme.surface,
  ));
}
