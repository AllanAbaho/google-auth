import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp();

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  User _user;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        print(user);
        _user = user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _user == null
          ? const LoginPage()
          : Home(_user.displayName, _user.email, _user.photoURL),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage();

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ClipRRect(
            //   borderRadius: BorderRadius.circular(10),
            //   child: Image.asset(
            //     'images/landscape.jpg',
            //     height: 150,
            //   ),
            // ),
            SizedBox(
              height: 25,
            ),
            const Text(
              'Login Page',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 50,
            ),
            ElevatedButton.icon(
              onPressed: () {
                signInWithGoogle();
              },
              icon: Image.asset(
                'images/google.png',
                height: 20,
              ),
              label: Text('Sign in with Google'),
            ),

            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Text(
                  'By using our app, you agree to our Terms & conditions and Privacy Policy'),
            ),
          ],
        ),
      ),
    );
  }

  signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      User user = userCredential.user;
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      // ignore: use_build_context_synchronously
      return Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              Home(user.displayName, user.email, user.photoURL),
        ),
      );
    } catch (e) {
      print('Error caught: $e');
    }
  }
}

class Home extends StatefulWidget {
  final String name;
  final String email;
  final String photoURL;
  const Home(this.name, this.email, this.photoURL, {Key key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<bool> signOutFromGoogle() async {
    try {
      await FirebaseAuth.instance.signOut();
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      // ignore: use_build_context_synchronously
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const LoginPage()));
      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            child: Image.network(widget.photoURL),
            borderRadius: BorderRadius.circular(100),
          ),
          SizedBox(
            height: 25,
          ),
          Text(widget.name),
          SizedBox(
            height: 25,
          ),
          Text(widget.email),
          SizedBox(
            height: 25,
          ),
          ElevatedButton(
              onPressed: () {
                signOutFromGoogle();
              },
              child: Text('Logout'))
        ],
      )),
    );
  }
}
