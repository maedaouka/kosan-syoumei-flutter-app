import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_twitter_login/flutter_twitter_login.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'dart:async';
import 'package:twitter_api/twitter_api.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
  FlutterError.dumpErrorToConsole(details);
  if (kReleaseMode)
    exit(1);
};
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'auth sample',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthPage(
        title: 'Auth Sample with Firebase',
      ),
    );
  }
}

class AuthPage extends StatefulWidget {
  AuthPage({
    Key key,
    this.title,
  }) : super(
    key: key,
  );

  final String title;

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TwitterLogin twitterLogin = TwitterLogin(
    consumerKey: "IoJiMkAVEmjjkQoIExzAn69xE",
    consumerSecret: "ZCa3waPjr9HM5xHDgSDcLjiGqy6jBeQ6DlVyAa5uOkDG09bLOU",
  );

  bool logined = false;

  void login(FirebaseUser user, String token, String secret) {
    setState(() {
      logined = true;
    });
    Navigator.push(context, MaterialPageRoute(builder: (context) => MyHomePage(user, token, secret)));
  }

  void logout() {
    setState(() {
      logined = false;
    });
  }

  Future signInWithTwitter() async {
    // twitter認証の許可画面が出現
    final TwitterLoginResult result = await twitterLogin.authorize();

    //Firebaseのユーザー情報にアクセス & 情報の登録 & 取得
    final AuthCredential credential = TwitterAuthProvider.getCredential(
      authToken: result.session.token,
      authTokenSecret: result.session.secret,
    );

    //Firebaseのuser id取得
    final FirebaseUser user =
        (await _auth.signInWithCredential(credential)).user;

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    login(user, result.session.token, result.session.secret);
  }

  void signOutTwitter() async {
    await twitterLogin.logOut();
    logout();
  }

  @override
  Widget build(BuildContext context) {
    Widget logoutText = Text("現在ログアウト状態です");
    Widget loginText = Text("現在ログイン状態です");

    Widget loginBtnTwitter = RaisedButton(
      child: Text("Sign in with Twitter"),
      color: Color(0xFF1DA1F2),
      textColor: Colors.white,
      onPressed: signInWithTwitter,
    );
    Widget logoutBtnTwitter = RaisedButton(
      child: Text("Sign out with Twitter"),
      color: Color(0xFF1DA1F2),
      textColor: Colors.white,
      onPressed: signOutTwitter,
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("古参証明"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            logined ? loginText : logoutText,
            logined ? logoutBtnTwitter : loginBtnTwitter,
          ],
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => new _MyHomePageState();

  MyHomePage(FirebaseUser user, String token, String secret) {
    _MyHomePageState.user = user;
    _MyHomePageState.token = token;
    _MyHomePageState.secret = secret;
  }
}

class _MyHomePageState extends State<MyHomePage> {
  static FirebaseUser user;
  static String token;
  static String secret;
  static String deviceId;
  static List<dynamic> certificateList = [];
  static List<dynamic> fromNameList = [];
  static List<dynamic> toNameList = [];
  static List<dynamic> memoList = [];
  static List<dynamic> dobList = [];


  List<String> itemList = [];
  void buildItemList()async{
    var response = await fetchArticle();
    for (int j = 0; j < response.data["items"].length; j++) {
      setState(() {
        itemList.add(response.data["items"][j]);
      });
    }
  }

  Future fetchArticle() async {

    final url = "https://22161mw9kg.execute-api.ap-northeast-1.amazonaws.com/kosan_syoumei_mylist?device=$deviceId";

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final body = json.decode(response.body)
      setState(() {
        certificateList = body["to_name_list"];
        fromNameList = body["from_name_list"];
        toNameList = body["to_name_list"];
        memoList = body["memo_list"];
        dobList = body["dob_list"];
        if(Platform.isAndroid) {
          deviceId = user.providerData[1].uid;
        }
        if(Platform.isIOS) {
          deviceId = user.providerData[0].uid;
        }

      });
      return certificateList;
    } else {
      throw Exception('Failed to load article');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchArticle();
  }

  @override
  Widget build(BuildContext context) {
   return new Scaffold(
      appBar: new AppBar(
        title: new Text("古参証明書　一覧"),
      ),
      body: ListView(children: List.generate(certificateList.length, (index) {
        return InkWell(
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => MyCertificateDetail(index, deviceId, fromNameList[index], toNameList[index], dobList[index], memoList[index])));
          },
          child: Card(
            child: Column(
              children: <Widget>[
                Container(
                    margin: EdgeInsets.all(10.0),
                    child: ListTile(
                      title: Text(certificateList[index]),
                      leading: Icon(Icons.people),
                      subtitle: Text(dobList[index] + "発行"),
                    )
                )
              ],
            ),
          ),
        );
      })
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.push(context, MaterialPageRoute(builder: (context) => MyCertificateCreate(user, token, secret)));
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}


class MyCertificateDetail extends StatefulWidget {
  @override
  _MyCertificateDetailState createState() => new _MyCertificateDetailState();

  MyCertificateDetail(int id, String deviceId, String fromName, String toName, String dob, String memo) {
    _MyCertificateDetailState.i = id;
    _MyCertificateDetailState.deviceId = deviceId;
    _MyCertificateDetailState.fromName = fromName;
    _MyCertificateDetailState.toName = toName;
    _MyCertificateDetailState.dob = dob;
    _MyCertificateDetailState.memo = memo;
  }
}

class _MyCertificateDetailState extends State<MyCertificateDetail> {
  static int i = 0;
  static String deviceId = "";
  static String fromName = "";
  static String toName = "";
  static String dob = "";
  static String memo = "";

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("古参証明書"),
        ),
        body: Center(
          child: Text("古参証明書　$fromName様　発効日 $dob \n\n $deviceIdは$toNameを応援していることをここに証明します。\n\n「$memo」\n\n 古参証明書"),
        )
    );
  }
}

class CreateCertificatePage extends StatefulWidget {
  @override
  _CreateCertificatePageState createState() => new _CreateCertificatePageState();
}

class _CreateCertificatePageState extends State<CreateCertificatePage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("古参証明書"),
        ),
        body: Center(
          child: Text("古参証明書作成ページです。"),
        )
    );
  }
}

class MyCertificateCreate extends StatefulWidget {

  @override
  _MyCertificateCreateState createState() => new _MyCertificateCreateState();

  MyCertificateCreate(FirebaseUser user, String token, String secret) {
    _MyCertificateCreateState.user = user;
    _MyCertificateCreateState.token = token;
    _MyCertificateCreateState.secret = secret;
    if (Platform.isAndroid) {
      _MyCertificateCreateState._deviceId = user.providerData[1].uid;
      _MyCertificateCreateState._fromName = user.providerData[1].displayName;
    } else if (Platform.isIOS) {
      _MyCertificateCreateState._deviceId = user.providerData[0].uid;
      _MyCertificateCreateState._fromName = user.providerData[0].displayName;
    }

  }
}

class _MyCertificateCreateState extends State<MyCertificateCreate> {
  static FirebaseUser user;
  static String token;
  static String secret;
  static String _memo = "";
  static String _fromName = "";
  static String _toName = "";
  static String _deviceId = "";

  void _handleMemo(String e) {
    setState(() {
      _memo = e;
    });
  }

  void _handleFromName(String e) {
    setState(() {
      _fromName = e;
    });
  }

  void _handleToName(String e) {
    setState(() {
      _toName = e;
    });
  }

  Future twitterUserShow(String token, String secret, String screen_name) async {

    String consumerApiKey = "IoJiMkAVEmjjkQoIExzAn69xE";
    String consumerApiSecret = "ZCa3waPjr9HM5xHDgSDcLjiGqy6jBeQ6DlVyAa5uOkDG09bLOU";
    String accessToken = token;
    String accessTokenSecret = secret;

    final _twitterOauth = new twitterApi(
        consumerKey: consumerApiKey,
        consumerSecret: consumerApiSecret,
        token: accessToken,
        tokenSecret: accessTokenSecret
    );

    Future twitterRequest = _twitterOauth.getTwitterRequest(
      // Http Method
      "GET",
      // Endpoint you are trying to reach
      "users/show.json",
      // The options for the request
      options: {
        "screen_name": screen_name,
      },
    );

    var res = await twitterRequest;

    var resJson = json.decode(res.body);

    return(resJson["id_str"]);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("古参証明書　作成"),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Text("相手のTwitterID（@は入力しないでください）"),
            new TextField(
              enabled: true,
              maxLength: 10,
              maxLengthEnforced: false,
              style: TextStyle(color: Colors.red),
              obscureText: false,
              maxLines: 1,
              onChanged: _handleToName,
            ),
            Text("メモ"),
            new TextField(
              enabled: true,
              maxLength: 10,
              maxLengthEnforced: false,
              style: TextStyle(color: Colors.red),
              obscureText: false,
              maxLines: 1,
              onChanged: _handleMemo,
            ),
            RaisedButton(
              child: Text("証明書を発行する"),
              color: Colors.yellow,
              shape: BeveledRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              onPressed: () {
                Future createCertificate() async {
                  _toName = await twitterUserShow(token, secret, _toName);
                  final url = "https://eca9kh6oqe.execute-api.ap-northeast-1.amazonaws.com/default/kosan_syoumei_create?device=$_deviceId&from_name=$_fromName&to_name=$_toName&memo=$_memo";
                  await http.get(url);
                }
                createCertificate();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
