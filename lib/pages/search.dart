import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:fluttershare/pages/activity_feed.dart';


class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search>
    with AutomaticKeepAliveClientMixin<Search> {
  TextEditingController searchController = TextEditingController(); //Clears out test in search field when X button pressed
  Future<QuerySnapshot> searchResultsFuture;

    //Search Function
  handleSearch(String query) {
        Future<QuerySnapshot> users = usersRef
      //D- Query where query is equal to displayname
          .where("displayName", isGreaterThanOrEqualTo: query)
          .getDocuments(); //Retrieve user data
      setState(() {
        searchResultsFuture = users; //Set users in state
      });
  }

  //Clears search input when x icon is pressed
  clearSearch() {
    searchController.clear();
  }

  //User Search Box
  AppBar buildSearchField() {
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: "Search for a user...",
          filled: true,
          prefixIcon: Icon(
            Icons.account_box,
            size: 28.0,
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: clearSearch,
          ),
        ),
        onFieldSubmitted: handleSearch, //handles search function
      ),
    );
  }

  //Displayed before user enters an input
  Container buildNoContent() {
    final Orientation orientation = MediaQuery.of(context).orientation; //Responsive Design for portrait mode or landscape mode
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            SvgPicture.asset(
              'assets/images/search.svg', //background image
              height: orientation == Orientation.portrait ? 300.0 : 200.0, //Responsive Design
            ),
            Text(
              "Find Users",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                fontSize: 60.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  //Results of users from search input
  buildSearchResults() {
    return FutureBuilder(
      future: searchResultsFuture,  //query stored
      builder: (context, snapshot) { //snapshot of database data
        if (!snapshot.hasData) {
          return circularProgress(); //Display loading circle till results are displayed
        }
        List<UserResult> searchResults = []; //Documents stored in list text widgets
        snapshot.data.documents.forEach((doc) { //iterate each document
          User user = User.fromDocument(doc);
          UserResult searchResult = UserResult(user);
          searchResults.add(searchResult);
        });
        return ListView(
          children: searchResults,
        );
      },
    );
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
      appBar: buildSearchField(),
      body:
          searchResultsFuture == null ? buildNoContent() : buildSearchResults(), //If query returns null display No content page otherwise run search results
    );
  }
}

//Search Results Styling
class UserResult extends StatelessWidget {
  final User user;

  UserResult(this.user);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.7),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => showProfile(context, profileId: user.id),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: CachedNetworkImageProvider(user.photoUrl), //Cache user images to show later
              ),
              title: Text(
                user.displayName,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                user.username,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Divider(
            height: 2.0,
            color: Colors.white54,
          ),
        ],
      ),
    );
  }
}
