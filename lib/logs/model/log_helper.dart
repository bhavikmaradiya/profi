import 'package:cloud_firestore/cloud_firestore.dart';

class LogHelper {
  DocumentReference documentReference;
  Map<String, dynamic> map;

  LogHelper(this.documentReference, this.map);
}
