import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:umbrella_reminder/service/IFirestore_service.dart';

class FirestoreService extends IFirestoreService {
  @override
  Future<bool?> addUser(
      {required String userId,
      required String device,
      required bool notification,
      required String time}) async {
    try {
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');
      await users.doc(userId).set({
        'device': device,
        'notification': notification,
        'notification_time': time,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUserInfo(String userId) async {
    try {
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');
      final snapshot = await users.doc(userId).get();
      final data = snapshot.data() as Map<String, dynamic>;
      return data;
    } catch (e) {
      return null;
    }
  }
}
