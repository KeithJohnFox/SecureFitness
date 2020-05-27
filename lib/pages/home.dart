import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; //Material Dart Professional Color Schemes
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/activity_feed.dart';
import 'package:fluttershare/pages/create_account.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/pages/search.dart';
import 'package:fluttershare/pages/timeline.dart';
import 'package:fluttershare/pages/upload.dart';
import 'package:google_sign_in/google_sign_in.dart'; //Google Sign in Package
import 'package:cloud_firestore/cloud_firestore.dart'; //Firestore (Database) package


//* Final Modifier 
final usersRef = Firestore.instance.collection('users');
final DateTime timestamp = DateTime.now();
final googleSignIn = GoogleSignIn();

final activityFeedRef = Firestore.instance.collection('feed');
final commentsRef = Firestore.instance.collection('comments');
final followersRef = Firestore.instance.collection('followers');
final timelineRef = Firestore.instance.collection('timeline');
final followingRef = Firestore.instance.collection('following');
User currentUser;

final StorageReference storageRef = FirebaseStorage.instance.ref();
final postsRef = Firestore.instance.collection('posts');


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //* Bool isAuth, if user is authenticated set true & show AuthScreen, if false show UnAuthScreen 
  bool isAuth = false;
  PageController pageController;
  int pageIndex = 0;

//initState uses google Listener to check if user signs in do they have user account in firebase
  @override
  void initState() {
    super.initState();
    pageController = PageController();
    // Detects when user signed in
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) { //*Error handler for signing in
      print('Error signing in');
    });
    // Reauthenticate user when app is opened
    googleSignIn.signInSilently(suppressErrors: true).then((account) {
      handleSignIn(account);
      //* Catch signin error if there is one
    }).catchError((err) {
      print('Error signing in');
    });
  }

//Sign in Handler checks if User 
  handleSignIn(GoogleSignInAccount account) async { //googleSign in set as var account
    //If user data is returned
    if (account != null) {
      await createUserInFirestore(); 
      print('User signed in!: $account');
      //* Set User Authentication true
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  //D- USER CREATION IN DATABASE FUNCTION
  createUserInFirestore() async {
    //D- 1) Firstly check if user already exists in users collection in database (by to their id)
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersRef.document(user.id).get(); //Doc instance of user in database by user id

    if (!doc.exists) {
      //D- 2) if User doesn't exist, then take them to the create account page
      final username = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreateAccount())); //Here we push user to createAccount page using Navigator.push

      //D- 3) get username from create account, use it to make new user document in users collection
      //D- user data to be stored in firebase
      usersRef.document(user.id).setData({
        "id": user.id,
        "username": username,
        "photoUrl": user.photoUrl, //photo associated with google account 
        "email": user.email,
        "displayName": user.displayName,
        "bio": "",
        "timestamp": timestamp
      });

      //Make new users their own followers which allows you to see your own posts in acitivity feed
      await followersRef
        .document(user.id)
        .collection('userFollowers')
        .document(user.id)
        .setData({});

      doc = await usersRef.document(user.id).get();
    }
    currentUser = User.fromDocument(doc);
    print(currentUser);
    print(currentUser.username);
  }

  //Dispose gets rid of pages when needed
  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

//Login Method executes googleSignIn feature
//initState() is activated and checks firebase for user account in firebase 
  login() {
    googleSignIn.signIn();
  }

//Logout Function
  logout() {
    googleSignIn.signOut();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  //onTap is responsible for changes pages through an index
  onTap(int pageIndex) {
    pageController.animateToPage( //animateToPage allows an animation transition between pages
      pageIndex,
      duration: Duration(milliseconds: 400), //time for animation
      curve: Curves.easeInOut, //curve states type of animation
    );
  }

// Authorized User Build Screen Widget
  Scaffold buildAuthScreen() {
    return Scaffold(
      body: PageView(
        children: <Widget>[
          Timeline(currentUser: currentUser),
          ActivityFeed(),
          Upload(currentUser: currentUser),
          Search(),
          Profile(profileId: currentUser?.id),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
          currentIndex: pageIndex,
          //Ontap is function is executed when i user taps on a button
          onTap: onTap,
          //when a button is pressed an active color is set to show user pressed on the button
          activeColor: Theme.of(context).primaryColor,
          //List of widgets to show on tap
          items: [
            //Icon is displayed to allow users to click on an icon to go to another page
            BottomNavigationBarItem(icon: Icon(Icons.whatshot)), //flame icon
            BottomNavigationBarItem(icon: Icon(Icons.notifications_active)), //activity feed page
            BottomNavigationBarItem(
              icon: Icon(
                Icons.photo_camera, //Upload Page
                size: 35.0,
              ),
            ),
            BottomNavigationBarItem(icon: Icon(Icons.search)), //Search page
            BottomNavigationBarItem(icon: Icon(Icons.account_circle)), //Profile page
          ]),
    );
    // return RaisedButton(
    //   child: Text('Logout'),
    //   onPressed: logout,
    // );
  }

  // Widget buildAuthScreen() {
  //   return RaisedButton(
  //     child: Text('Logout'),
  //     onPressed: logout,
  //   );
  // }


// Unauthorized user Build Screen Method 
  Scaffold buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).accentColor,
            ],
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'SecureFitness',
              style: TextStyle(
                fontFamily: "Signatra",
                fontSize: 85.0,
                color: Colors.white,
              ),
            ),

            //Sets an Image to act like a button (Sign in Google Feature)
            GestureDetector(
              //On click run login method
              onTap: login,
              child: Container(
                width: 260.0,
                height: 60.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/images/google_signin_button.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

//* If user is authenticated then Build the AuthScreen, if false build UnAuthScreen
  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
