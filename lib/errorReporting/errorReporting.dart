import 'package:linkup/api/api_calls.dart';
import 'package:shake_flutter/models/shake_report_configuration.dart';
import 'package:shake_flutter/shake_flutter.dart';

class Errorreporting{
  void initShakeApp(String shakeAPIKey){
    Shake.start(shakeAPIKey); // API key loaded from here
    Shake.setShakingThreshold(200);
    Shake.setPushNotificationsToken(UserValues.fCMToken);
    Shake.registerUser(UserValues.uid);
  }

  void sendSilentReportShake(String errorTitle, StackTrace stackTrace, String tags){
    var detailedReport = '''
      $errorTitle
      
      ${stackTrace.toString().replaceAll("#", "")}

      Tag
      #bug $tags
    ''';

    ShakeReportConfiguration configuration = ShakeReportConfiguration();
    configuration.showReportSentMessage = true;

    
    Shake.silentReport(
      configuration: configuration,
      description: detailedReport
    );

  }

}