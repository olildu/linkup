import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseCalls {
  User? user = FirebaseAuth.instance.currentUser;
  dynamic data;

  String? getUserId() {
    return user?.uid;
  }

  Future<void> getUserData() async {
    final ref = FirebaseDatabase.instance.ref().child("/UsersMetaData/${user?.uid}/UserDetails");
    final snapshot = await ref.get();

    if (snapshot.exists) {
      data = snapshot.value; // Store retrieved data in the data variable
    } else {
      data = null;
    }
  }
}
