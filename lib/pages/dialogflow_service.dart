import 'package:dialogflow_grpc/dialogflow_auth.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:dialogflow_grpc/v2.dart';

class DialogflowService {
  late DialogflowGrpcV2 _dialogflow;

  Future<void> init() async {
    // Load your JSON key file as a string from assets
    final serviceAccountJson = await rootBundle.loadString(
      'assets/key/virtualfashionassistant-3fcb8-b548e77dd713.json',
    );

    // Create a ServiceAccount object
    final serviceAccount = ServiceAccount.fromString(serviceAccountJson);

    // Create the DialogflowGrpcV2Beta1 client via the service account
    _dialogflow = DialogflowGrpcV2.viaServiceAccount(serviceAccount);
  }

  Future<String> detectIntent(String query) async {
    final response = await _dialogflow.detectIntent(query, 'en');
    return response.queryResult.fulfillmentText;
  }
}
