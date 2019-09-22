import 'package:firebase/firebase.dart' as Firebase;
import 'package:google_sign_in/google_sign_in.dart';

abstract class BaseAuth {
  Stream<String> get onAuthStateChanged;
  Future<String> signInWithEmailAndPassword(
      String email,
      String password,
      );
  Future<String> createUserWithEmailAndPassword(
      String email,
      String password,
      );

  Future<String> currentUser();
  Future<void> signOut();
  Future<String> signInWithGoogle();
}

class Auth implements BaseAuth {
  final Firebase.Auth _firebaseAuth = Firebase.auth();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Stream<String> get onAuthStateChanged => _firebaseAuth.onAuthStateChanged.map(
        (Firebase.User user) => user?.uid,
  );

  @override
  Future<String> createUserWithEmailAndPassword(
      String email, String password) async {
    return (await _firebaseAuth.createUserWithEmailAndPassword(
      email,
      password,
    )).user.uid;
  }

  @override
  Future<String> currentUser() async {
    return _firebaseAuth.currentUser.uid;
  }

  @override
  Future<String> signInWithEmailAndPassword(
      String email, String password) async {
    return (await _firebaseAuth.signInWithEmailAndPassword(
      email,
      password,
    )).user.uid;
  }

  @override
  Future<String> signInWithGoogle() async {
    final GoogleSignInAccount account = await _googleSignIn.signIn();
    final GoogleSignInAuthentication _auth = await account.authentication;
    final Firebase.AuthCredential credential = Firebase.GoogleAuthProvider.credential(
      _auth.idToken,
      _auth.accessToken,
    );
    return (await _firebaseAuth.signInWithCredential(credential)).uid;
  }

  @override
  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }

}
