import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:happy_school/user/MainHome.dart';
import 'package:happy_school/user/userCourses.dart';
import 'package:happy_school/user/userFeed.dart';
import 'package:happy_school/user/userLeaderBoard.dart';

class Userhome extends StatefulWidget {
  const Userhome({super.key});

  @override
  State<Userhome> createState() => _UserhomeState();
}

class _UserhomeState extends State<Userhome> {
  PageController _pageController = PageController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          leading: Padding(
            padding: EdgeInsets.only(left: 13, top: 13),
            child: Builder(
              builder: (BuildContext context) {
                return GestureDetector(
                  onTap: () {
                    Scaffold.of(context).openDrawer(); // Open left drawer
                  },
                  child: FaIcon(
                    FontAwesomeIcons.bars,
                    color: Colors.black,
                  ),
                );
              },
            ),
          ),
          title: Padding(
            padding: EdgeInsets.only(top: 10),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Hi,",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      "Rajabrahmam",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Container(
                  height: 25,
                  decoration: BoxDecoration(
                    color: Color(0x2EFF6B00),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 2.0, top: 2, bottom: 2, right: 4),
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/Images/coin.png",
                        ),
                        Text(
                          "1.4k",
                          style: TextStyle(
                            color: Colors.orangeAccent,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                const FaIcon(
                  FontAwesomeIcons.solidBell,
                  size: 23,
                ),
                const Spacer(),
                const Icon(Icons.person),
              ],
            ),
          ),
        ),
      ),
      drawer: CustomDrawer(handleNavigation: _onItemTapped), // Added drawer
      body: PageView(
        controller: _pageController,
        physics: const AlwaysScrollableScrollPhysics(),
        onPageChanged: (index) {
          _onItemTapped(index);
        },
        children: [
          Mainhome(),
          UserCourses(),
          Userleaderboard(),
          Userfeed(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: false,
        backgroundColor: Colors.white,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.clipboardList),
            label: 'My courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Leaderboard',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.globe),
            label: 'Feed',
          ),
        ],
        currentIndex: _selectedIndex.clamp(0, 3),
        selectedItemColor: Colors.orange[600],
        onTap: _onItemTapped,
      ),
      endDrawer: CustomDrawer(handleNavigation: handleNavigation),
    );
  }

  void handleNavigation(int index) {
    setState(() {
      _selectedIndex = index;
      switch (index) {
        case 0:
          _pageController.jumpToPage(0);
          break;
        case 1:
          _pageController.jumpToPage(1);
          break;
        case 2:
          _pageController.jumpToPage(2);
          break;
        case 3:
          _pageController.jumpToPage(3);
          break;
        default:
          break;
      }
    });
  }
}

class CustomDrawer extends StatelessWidget {
  final Function(int) handleNavigation;

  CustomDrawer({required this.handleNavigation});
  final User? user = FirebaseAuth.instance.currentUser;

  Future<String?> getUsername() async {
    String? username;
    try {
      var userDocument = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user!.email)
          .collection('userinfo')
          .doc('userinfo')
          .get();

      if (userDocument.exists) {
        username = userDocument.get('Name');
      }
    } catch (e) {
      print("Error getting username: $e");
    }
    return username;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Drawer(
      width: width * 0.80,
      child: FutureBuilder<String?>(
        future: getUsername(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else {
            return ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {},
                            child: const Icon(
                              Icons.account_circle,
                              color: Colors.black,
                              size: 60,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Welcome,',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Roboto',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '  ${snapshot.data}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Now placing the Home ListTile just below the orange section
                Column(
                  children: [
                    ListTile(
                      leading: FaIcon(
                        FontAwesomeIcons.houseChimney,
                        color: Colors.black,
                      ),
                      title: Text(
                        'Home',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        handleNavigation(
                            0); // Navigate to the first page (MainBuilderHome)
                        Navigator.pop(context);
                      },
                    ),
                    Divider(
                      color: Colors.black,
                      thickness: 0.5,
                      indent: 0,
                      endIndent: 0,
                    ),
                    ListTile(
                      leading: FaIcon(
                        FontAwesomeIcons.clipboardList,
                        color: Colors.black,
                      ),
                      title: Text(
                        'User courses',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        handleNavigation(
                            1); // Navigate to the first page (MainBuilderHome)
                        Navigator.pop(context);
                      },
                    ),
                    Divider(
                      color: Colors.black,
                      thickness: 0.5,
                      indent: 0,
                      endIndent: 0,
                    ),
                    ListTile(
                      leading: FaIcon(
                        Icons.bar_chart,
                        color: Colors.black,
                      ),
                      title: Text(
                        'leader board',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        handleNavigation(
                            2); // Navigate to the first page (MainBuilderHome)
                        Navigator.pop(context);
                      },
                    ),
                    Divider(
                      color: Colors.black,
                      thickness: 0.5,
                      indent: 0,
                      endIndent: 0,
                    ),
                    ListTile(
                      leading: FaIcon(
                        FontAwesomeIcons.globe,
                        color: Colors.black,
                      ),
                      title: Text(
                        'Feed',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        handleNavigation(
                            3); // Navigate to the first page (MainBuilderHome)
                        Navigator.pop(context);
                      },
                    ),
                    Divider(
                      color: Colors.black,
                      thickness: 0.5,
                      indent: 0,
                      endIndent: 0,
                    ),
                  ],
                )
                // Add other list items as needed
              ],
            );
          }
        },
      ),
    );
  }
}
