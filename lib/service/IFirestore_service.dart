abstract class IFirestoreService {
  Future<bool?> addUser(
      {required String userId,
      required String device,
      required bool notification,
      required String time});
}
