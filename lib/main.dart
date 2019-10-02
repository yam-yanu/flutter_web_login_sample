import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_web_login_sample/provider.dart';
import 'package:flutter_web_login_sample/validators.dart';
import 'package:flutter_web_login_sample/auth.dart' as WebAuth;
import 'package:firebase/firebase.dart';


void main() async {
  // TODO なんとか秘匿情報がでないようにする
  initializeApp(
    apiKey: "",
    authDomain: "",
    databaseURL: "",
    projectId: "",
    storageBucket: "",
    messagingSenderId: "",
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider(
      auth: WebAuth.Auth(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData.light(),
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final WebAuth.Auth auth = Provider.of(context).auth;
    return StreamBuilder<String>(
      stream: auth.onAuthStateChanged,
      builder: (context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final bool loggedIn = snapshot.hasData;
          if (loggedIn == true) {
            return HomePage();
          } else {
            return LoginPage();
          }
        }
        return CircularProgressIndicator();
      },
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome Page'),
        actions: <Widget>[
          FlatButton(
            child: Text("Sign Out"),
            onPressed: () async {
              try {
                WebAuth.Auth auth = Provider.of(context).auth;
                await auth.signOut();
              } catch (e) {
                print(e);
              }
            },
          )
        ],
      ),
      body: Container(
        child: Center(
          child: Center(
            child: Form(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FlatButton(
                    child: Text("link with Google"),
                    color: Colors.blue,
                    onPressed: () async {
                      try {
                        final _auth = Provider.of(context).auth;
                        await _auth.linkWithGoogle();
                      } catch (e) {
                        print(e);
                      }
                    },
                  ),
                  FlatButton(
                    child: Text("link with Github"),
                    color: Colors.black,
                    textColor: Colors.white,
                    onPressed: () async {
                      try {
                        final _auth = Provider.of(context).auth;
                        await _auth.linkWithGithub();
                      } catch (e) {
                        print(e);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();

  String _email, _password;
  FormType _formType = FormType.login;

  bool validate() {
    final form = formKey.currentState;
    form.save();
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  void submit() async {
    if (validate()) {
      try {
        final auth = Provider.of(context).auth;
        if (_formType == FormType.login) {
          String userId = await auth.signInWithEmailAndPassword(
            _email,
            _password,
          );

          print('Signed in $userId');
        } else {
          String userId = await auth.createUserWithEmailAndPassword(
            _email,
            _password,
          );

          print('Registered in $userId');
        }
      } catch (e) {
        print(e);
      }
    }
  }

  void switchFormState(String state) {
    formKey.currentState.reset();

    if (state == 'register') {
      setState(() {
        _formType = FormType.register;
      });
    } else {
      setState(() {
        _formType = FormType.login;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Form Page'),
      ),
      resizeToAvoidBottomPadding: false,
      body: Center(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: buildEmailAndPassword() + buildProviders(),
          ),
        ),
      ),
    );
  }

  List<Widget> buildEmailAndPassword() {
    return [
      Text('Use Email & Password'),
      TextFormField(
        validator: EmailValidator.validate,
        decoration: InputDecoration(labelText: 'Email'),
        onSaved: (value) => _email = value,
      ),
      TextFormField(
        validator: PasswordValidator.validate,
        decoration: InputDecoration(labelText: 'Password'),
        obscureText: true,
        onSaved: (value) => _password = value,
      ),
      Divider(
        height: 30.0,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          FlatButton(
            child: Text('Login'),
            color: Colors.blueAccent,
            onPressed: submit,
          ),
          FlatButton(
            child: Text('Register Account'),
            color: Colors.teal,
            onPressed: () {
              switchFormState('register');
            },
          ),
        ],
      ),
    ];
  }

  List<Widget> buildProviders() {
    if (_formType == FormType.login) {
      return [
        Text('Use Providers'),
        FlatButton(
          child: Text("Sign in with Google"),
          color: Colors.blue,
          onPressed: () async {
            try {
              final _auth = Provider.of(context).auth;
              await _auth.signInWithGoogle();
            } catch (e) {
              print(e);
            }
          },
        ),
        FlatButton(
          child: Text("Sign in with Github"),
          color: Colors.black,
          textColor: Colors.white,
          onPressed: () async {
            try {
              final _auth = Provider.of(context).auth;
              await _auth.signInWithGithub();
            } catch (e) {
              print(e);
            }
          },
        ),
      ];
    } else {
      return [
        RaisedButton(
          child: Text('Create Account'),
          color: Colors.blueAccent,
          onPressed: submit,
        ),
        FlatButton(
          child: Text('Go to Login'),
          color: Colors.teal,
          onPressed: () {
            switchFormState('login');
          },
        )
      ];
    }
  }
}