import 'package:authpass/env/_base.dart';
import 'package:authpass/env/env.dart';

// import 'secrets.dart';

Future<void> main() async => await Production().start();

class Production extends EnvAppBase {
  Production() : super(EnvType.production);

  @override
  EnvSecrets get secrets => const EnvSecrets(
        analyticsAmplitudeApiKey: null,
        analyticsGoogleAnalyticsId: null,
        googleClientId: null,
        googleClientSecret: null,
        dropboxKey: 'x9hjztjezw813y0',
        dropboxSecret: 'ro2i1nqvpn7m63c',
        microsoftClientId: 'e40fd28c-f809-4103-8366-e3f51ba64853',
        microsoftClientSecret: 'kktMFOMI13@:vylpRQ800(*',
      );
}
