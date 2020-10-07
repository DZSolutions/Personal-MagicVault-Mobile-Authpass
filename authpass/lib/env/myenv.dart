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
        microsoftClientId: '933ae920-12bd-417f-b822-1f168e003cf0',
        microsoftClientSecret: '~gQjutHZf9eaUh9eD-AiJ.1_FSb4ZL-5dR',
      );
}
