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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: PageView(
        controller: _pageController,
        physics: const AlwaysScrollableScrollPhysics(),
        onPageChanged: (index) {
          _onItemTapped(index);
        },
        children: [
          Mainhome(),
          Usercourses(),
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
            label: 'leaderboard',
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
    );
  }
}
