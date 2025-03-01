import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Widget/ProgressWidget.dart';
import '../constant/ThemeColor.dart';
import 'LoginScreen.dart';

class Setting extends StatelessWidget {
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]); // to hide only bottom bar
  }

  @override
  Widget build(BuildContext context) {
    return SettingsScreen();
  }
}

class SettingsScreen extends StatefulWidget {
  @override
  State createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  late SharedPreferences preference;
  String id = "";
  String name = "";
  String username = "";
  String photoUrl = "";
  TextEditingController nameTextEditingController = TextEditingController();

  File? profileImage;
  bool showSpin = false;
  final FocusNode nameFocusNode = FocusNode();

  final GoogleSignIn googleSignIn = GoogleSignIn();
  late bool darkMode = false;
  double balance = 0.0;

  @override
  void initState() {
    super.initState();
    readDataFromLocal();
    getThemeMode();
  }


  void getThemeMode() async {
    preference = await SharedPreferences.getInstance();
    darkMode = preference.getBool('darkMode') ??
        false; // set a default value of true if it hasn't been set before
  }

  void changeTheme(var userThemeData) async{
    await userThemeData.updateTheme(!darkMode);
    preference = await SharedPreferences.getInstance();
    setState(() {
      darkMode = preference.getBool('darkMode') ?? false;
    });
  }

  ///Unused
  void setDarkMode() async {
    setState(() {
      darkMode = true;
    });
    await preference?.setBool('darkMode', true);
  }

  ///Unused
  void setLightMode() async {
    setState(() {
      darkMode = false;
    });
    await preference?.setBool('darkMode', false);
  }

  void readDataFromLocal() async {
    preference = await SharedPreferences.getInstance();
    id = preference.getString("id").toString();
    name = preference.getString("name").toString() == "null"
        ? "User ${id.substring(0, 9)}"
        : preference.getString("name").toString();
    photoUrl = preference.getString("photoUrl").toString() == "null"
        ? "https://dlmocha.com/app/Ume-Talk/userDefaultAvatar.jpeg"
        : preference.getString("photoUrl").toString();

    final QuerySnapshot resultQuery = await FirebaseFirestore.instance
        .collection("user")
        .where("id", isEqualTo: id)
        .get();
    final List<DocumentSnapshot> documentSnapshots = resultQuery.docs;
    try {
      balance += documentSnapshots[0]['balance'];
      username = documentSnapshots[0]['userName'];
      print("object: $balance");
    }on Error catch (e){print(e);}
    print("balance: $balance");

    nameTextEditingController = TextEditingController(text: name);
    print("name: $name");
    print("photoUrl: $photoUrl");
    setState(() {
      showSpin = false;
    });
  }

  Future getImage(ImageSource sourcePicked) async {
    try {
      final ImagePicker _picker = ImagePicker();
      // Pick an image
      var image = await _picker.pickImage(source: sourcePicked);
      if (image != null) {
        setState(() {
          showSpin = true;
          final imagePicked = File(image.path);
          profileImage = imagePicked;
          uploadImageToFireStore();
          showSpin = false;
        });
      }
    } on PlatformException catch (e) {
      Fluttertoast.showToast(msg: "An error occurred!");
    }
  }

  void updateData() {
    String convert = name.toLowerCase().replaceAll(' ', '');
    var arraySearchID = List.filled(convert.length, "");
    for (int i = 0; i < convert.length; i++) {
      arraySearchID[i] = convert.substring(0, i + 1).toString();
    }

    nameFocusNode.unfocus();

    FirebaseFirestore.instance.collection("user").doc(id).update({
      "photoUrl": photoUrl,
      "name": name,
    }).then((data) async {
      await preference.setString("photoUrl", photoUrl);
      await preference.setString("name", name);
    });
    Fluttertoast.showToast(msg: "Update Successfully");
    setState(() {
      showSpin = false;
    });
  }

  Future deleteUser() async{
    // final QuerySnapshot resultQuery = await FirebaseFirestore.instance
    //     .collection("user")
    //     .where("id", isEqualTo: id)
    //     .get();
    // final List<DocumentSnapshot> documentSnapshots = resultQuery.docs;
    // try {
    //   List temp = documentSnapshots[0]['chatWith'];
    //   FirebaseFirestore.instance.collection("delete").doc(id).set(
    //       {"oldChatList": temp});
    // }on Error catch (e){

    // }
    // await FirebaseFirestore.instance.collection("user").doc(id).delete();
    // await Future.delayed(Duration(seconds: 2));
    // deleteFirebaseAuth();
  }

  Future deleteFirebaseAuth() async{
    await FirebaseAuth.instance.currentUser?.delete();
    logoutUser();
  }

  Future uploadImageToFireStore() async {
    String fileNameID = id;
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child(fileNameID);
    UploadTask uploadTask = ref.putFile(profileImage!);
    uploadTask.then((res) {
      res.ref.getDownloadURL().then((newProfileImage) {
        photoUrl = newProfileImage;
        FirebaseFirestore.instance.collection("user").doc(id).update({
          "photoUrl": photoUrl,
          "name": name,
        }).then((data) async {
          await preference.setString("photoUrl", photoUrl);
        });
      });
    }).catchError((error) {
      Fluttertoast.showToast(msg: error);
    });
    setState(() {
      showSpin = false;
    });
  }

  void showDeleteAlertDialog(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Your account will be deleted permanently and could not be restore. \nDo you want to delete your account?'),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(context);
              deleteUser();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future logoutUser() async {
    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();

    ///Todo Delete this line for Android await googleSignIn.signOut();
    await googleSignIn.signOut();
    setState(() {
      showSpin = false;
    });
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) {
          return LoginScreen();
        }), (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              leading: IconButton(
                onPressed: () {
                  //Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back_ios_new),
                color: Colors.black,
                splashRadius: 0.1, // Set a small value to disable the ripple effect
                highlightColor: Colors.transparent, // Disable the highlight color
                hoverColor: Colors.transparent, // Disable the hover color
              ),
              backgroundColor: Colors.blue,
              iconTheme: const IconThemeData(
                color: Colors.blue,
              ),
              title: const Text(
                "Setting",
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 30.0,
                ),
              ),
              centerTitle: true,
              pinned: true,
            ),
          ];
        },
        body: Material(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                ///Profile Image
                Container(
                  child: Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: <Widget>[
                        (profileImage == null)
                            ? (photoUrl != "")
                            ? Material(
                          //display already existing - old image file
                          child: CachedNetworkImage(
                            placeholder: (context, url) => Container(
                              child: const CircularProgressIndicator(
                                strokeWidth: 2.0,
                                valueColor:
                                AlwaysStoppedAnimation<Color>(
                                    Colors.lightBlueAccent),
                              ),
                              width: 300.0,
                              height: 300.0,
                              padding: const EdgeInsets.all(20.0),
                            ),
                            imageUrl: photoUrl,
                            width: 250.0,
                            height: 250.0,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: const BorderRadius.all(
                              Radius.circular(125.0)),
                          clipBehavior: Clip.hardEdge,
                        )
                            : const Icon(
                          Icons.account_circle,
                          size: 90.0,
                          color: Colors.grey,
                        )
                            : Material(
                          //display the new updated image here
                          child: Image.file(
                            profileImage!,
                            width: 250.0,
                            height: 250.0,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: const BorderRadius.all(
                              Radius.circular(125.0)),
                          clipBehavior: Clip.hardEdge,
                        ),
                        Container(
                          decoration:
                          const BoxDecoration(color: Colors.transparent),
                          width: 50,
                          height: 50,
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: IconButton(
                              icon: Icon(
                                Icons.add_circle_outline,
                                size: 50.0,
                                color: darkMode ? Colors.white : Colors.black,
                              ),
                              onPressed: () => getImage(ImageSource.gallery),
                              padding: const EdgeInsets.all(0.0),
                              //splashColor: Colors.transparent,
                              //highlightColor: Colors.black54,
                              //iconSize: 10.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  //alignment: Alignment.bottomRight,
                  width: double.infinity,
                  margin: const EdgeInsets.all(50.0),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Container(child: Text("ID: @${username}",
                  style: TextStyle(fontSize: 15, color: Colors.grey),),),
                const SizedBox(
                  height: 20.0,
                ),
                Container(child: Text("Balance: \$${balance}",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),),),
                const SizedBox(
                  height: 20.0,
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: showSpin ? circularProgress() : Container(),
                    ),
                    Container(
                      //Display User Name
                      child: Theme(
                        data: Theme.of(context)
                            .copyWith(primaryColor: Colors.black),
                        child: TextField(
                          maxLength: 25,
                          decoration: InputDecoration(
                              hintText: "Name",
                              contentPadding: const EdgeInsets.all(3.0),
                              hintStyle: const TextStyle(color: Colors.grey),
                              prefixText: "Name: ",
                              prefixStyle: TextStyle(
                                  color:
                                  darkMode ? Colors.white70 : Colors.grey),
                              suffixText: "Edit",
                              suffixStyle: TextStyle(
                                  color:
                                  darkMode ? Colors.white70 : Colors.grey),
                              counterText: "",
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: darkMode ? Colors.white60 :Colors.black54),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: darkMode ? Colors.cyan : Colors.blue),
                              )
                          ),
                          controller: nameTextEditingController,
                          style: TextStyle(color: darkMode ? Colors.white : Colors.black),
                          onChanged: (value) {
                            name = value;
                          },
                          focusNode: nameFocusNode,
                        ),
                      ),

                      margin: const EdgeInsets.only(left: 30.0, right: 30.0),
                    ),
                    const SizedBox(
                      height: 30.0,
                    ),
                    Material(
                      color: subThemeColor,
                      borderRadius: const BorderRadius.all(Radius.circular(30.0)),
                      elevation: 5.0,
                      child: Ink(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30.0),
                          child: Container(
                            height: 50,
                            width: 300,
                            alignment: Alignment.center,
                            child: const Text(
                              "Save",
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 18.0, fontWeight: FontWeight.w500),
                            ),
                          ),
                          onTap: updateData,
                        ),

                      ),
                    ),
                    const SizedBox(
                      height: 30.0,
                    ),
                    Material(
                      color: subThemeColor,
                      borderRadius: const BorderRadius.all(Radius.circular(30.0)),
                      elevation: 5.0,
                      child: Ink(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30.0),
                          child: Container(
                            height: 50,
                            width: 300,
                            alignment: Alignment.center,
                            child: const Text(
                              "Log Out",
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 18.0, fontWeight: FontWeight.w500),
                            ),
                          ),
                          onTap: logoutUser,
                        ),

                      ),
                    ),
                    const SizedBox(
                      height: 30.0,
                    ),
                    Material(
                      color: Colors.blue,
                      borderRadius: const BorderRadius.all(Radius.circular(30.0)),
                      elevation: 5.0,
                      child: Ink(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30.0),
                          child: Container(
                            height: 50,
                            width: 300,
                            alignment: Alignment.center,
                            child: const Text(
                              "Terms & Conditions",
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 18.0, fontWeight: FontWeight.w500),
                            ),
                          ),
                          onTap: () async {
                            launch("https://dlmocha.com/app/UmeTalk-privacy");
                            //await userThemeData.updateTheme(!darkMode);
                          },
                        ),

                      ),
                    ),
                    const SizedBox(
                      height: 30.0,
                    )],
                  crossAxisAlignment: CrossAxisAlignment.center,
                ),
              ],
            ), //Column

            padding: const EdgeInsets.only(left: 15.0, right: 15.0),
          ),
          color: Colors.white,
        ),
      ),
    );
  }
}
