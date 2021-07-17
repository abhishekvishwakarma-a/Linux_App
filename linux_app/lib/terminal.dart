import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MyTerminal(),
  );
}

class MyTerminal extends StatefulWidget {
  @override
  MyTerminalstate createState() => MyTerminalstate();
}

class MyTerminalstate extends State<MyTerminal> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User user;
  bool isloggedin = false;
  checkAuthentification() async {
    _auth.authStateChanges().listen((user) {
      if (user == null) {
        Navigator.of(context).pushReplacementNamed("start");
      }
    });
  }

  getUser() async {
    User firebaseUser = _auth.currentUser;
    await firebaseUser?.reload();
    firebaseUser = _auth.currentUser;

    if (firebaseUser != null) {
      setState(() {
        this.user = firebaseUser;
        this.isloggedin = true;
      });
    }
  }

  signOut() async {
    _auth.signOut();

    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
  }

  @override
  void initState() {
    super.initState();
    this.checkAuthentification();
    this.getUser();
  }

  var msgcontroller = TextEditingController();
  var task;
  var state;
  var _controller = TextEditingController();
  TextEditingController ipController = new TextEditingController();

  command(task) async {
    var fsconnect = FirebaseFirestore.instance;

    var url = http
        .get(Uri.parse("http://${ipController.text}/cgi-bin/web.py?x=${task}"));

    var response = await http
        .get(Uri.parse("http://${ipController.text}/cgi-bin/web.py?x=${task}"));

    setState(() {
      state = response.body;
    });
    await fsconnect.collection('CommandOutput').add({
      '$task': '$state',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Terminal',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red.shade900,
        actions: <Widget>[
          IconButton(icon: Icon(Icons.logout), onPressed: signOut),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    margin: EdgeInsets.only(top: 30, left: 20, right: 20),
                    child: Card(
                      color: Colors.black,
                      child: TextField(
                        controller: msgcontroller,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: '  Enter Command',
                          hintStyle: TextStyle(color: Colors.white),
                          fillColor: Colors.white,
                          prefixText: '[root@localhost ~]#',
                          prefixStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.white),
                          focusColor: Colors.blue,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black45),
                          ),
                        ),
                        onChanged: (value) {
                          task = value;
                        },
                        autocorrect: true,
                        showCursor: true,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 30),
                  child: Material(
                    color: Colors.red.shade900,
                    borderRadius: BorderRadius.circular(20),
                    elevation: 10,
                    child: MaterialButton(
                      splashColor: Colors.blue,
                      minWidth: 150,
                      height: 40,
                      onPressed: () {
                        command(task);
                        msgcontroller.clear();
                      },
                      child: Text(
                        'Click Here',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 400,
                  width: 340,
                  margin: EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.red.shade900),
                  child: Card(
                    color: Colors.black,
                    child: ListView.builder(
                      itemCount: 1,
                      itemBuilder: (BuildContext context, int index) {
                        return Text(
                          state ?? "  ",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
