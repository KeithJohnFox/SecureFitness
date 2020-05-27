import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/header.dart';

class UsernameFieldValidator {
  static String validate (String val) {
    String pattern = r'^[a-zA-Z0-9]+$';
    RegExp regExp = new RegExp(pattern);
    if (val.trim().length < 6 || val.isEmpty) {
      return "Username needs 6 or more characters";
    } else if (val.trim().length > 20) {
      return "Username can't be over 20 characters";
    }
    else if(!regExp.hasMatch(val)){
      return "Username must only contain Characters and Numbers";
    }
    else {
      return null;
    }
  }
}

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>(); //formKey set to username input from form
  String username; //username string 
  submit() {
    final form = _formKey.currentState; //this stores user input of username

    //* Check validate is true with no errors
    if (form.validate()) {
      form.save(); //Save input value
      SnackBar snackbar = SnackBar(content: Text("Welcome $username to SecureFitness!")); //Welcome popup message
      _scaffoldKey.currentState.showSnackBar(snackbar); //Show snackBar message popup
      Timer(Duration(seconds: 2), () { //Snackbar time of 2 seconds
        Navigator.pop(context, username); 
      });
    }
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(context, //top bar
          // titleText: "Let's setup your profile", removeBackButton: true),
          titleText: "Let's setup your profile", removeBackButton: true),
      body: ListView(
        children: <Widget>[
          Container(
            child: Column( //Design based in a column format
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 25.0),
                  child: Center(
                    child: Text(
                      "Create your username",
                      style: TextStyle(fontSize: 25.0),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Container(
                    child: Form( //Form Field
                      key: _formKey,
                      autovalidate: true,
                      //user enters username here
                      child: TextFormField( 
                        //* ------USER VALIDATION-------
                        //* minimum character length of username 6, max length 20
                        validator: UsernameFieldValidator.validate,  
                        //D- onSaved gets value typed in the input of user, set to state variable called username
                        onSaved: (val) => username = val,
                        //Input styling
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Username",
                          labelStyle: TextStyle(fontSize: 15.0),
                          hintText: "Username be at least 6 characters long",
                        ), 
                      ),
                    ),
                  ),
                ),
                
                //Execute when user hits submit button
                GestureDetector(
                  onTap: submit,
                  child: Container(
                    height: 50.0,
                    width: 350.0,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    child: Center(
                      child: Text(
                        "Submit",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
