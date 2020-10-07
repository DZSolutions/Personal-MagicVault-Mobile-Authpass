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
        googleClientId:
            '334340771161-kp9lmvn14kkmpb8oih996l98b18d4jm9.apps.googleusercontent.com',
        googleClientSecret: 'aTysO7KZmJpsIK32I9Rl3lgb',
        dropboxKey: 'xhofdbveoa57j3q',
        dropboxSecret: 'janlxkx1730iotn',
        microsoftClientId: 'e40fd28c-f809-4103-8366-e3f51ba64853',
        microsoftClientSecret: 'kktMFOMI13@:vylpRQ800(*',
      );
}
