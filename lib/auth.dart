import 'package:firebase/firebase.dart' as Firebase;

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
  Future signInWithGoogle();
  Future linkWithGoogle();
  Future signInWithGithub();
  Future linkWithGithub();
}

class Auth implements BaseAuth {
  final Firebase.Auth _firebaseAuth = Firebase.auth();
  final Firebase.GoogleAuthProvider _googleAuthProvider = Firebase.GoogleAuthProvider();
  final Firebase.GithubAuthProvider _githubAuthProvider = Firebase.GithubAuthProvider();

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
  Future signInWithGoogle() async {
    return _firebaseAuth.signInWithPopup(_googleAuthProvider)
      .then((Firebase.UserCredential userCredential) {
        userCredential.user.linkWithPopup(_googleAuthProvider);
      });
  }

  @override
  Future linkWithGoogle() async {
    Firebase.User currentUser = Firebase.auth().currentUser;
    currentUser.linkWithPopup(_googleAuthProvider).then((result) {
      print(result);
    }).catchError((e) {
      print(e);
    });
  }

  @override
  Future signInWithGithub() async {
    return _firebaseAuth.signInWithPopup(_githubAuthProvider)
        .then((Firebase.UserCredential userCredential) {
      userCredential.user.linkWithPopup(_githubAuthProvider);
    });
  }

  @override
  Future linkWithGithub() async {
    Firebase.User currentUser = Firebase.auth().currentUser;
    currentUser.linkWithPopup(_githubAuthProvider).then((result) {
      print(result);
    }).catchError((e) {
      print(e);
    });
  }

  @override
  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }

}
