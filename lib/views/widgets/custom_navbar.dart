import 'package:flutter/material.dart';

class CustomNavBar extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String currentRoute;

  const CustomNavBar({
    Key? key,
    required this.scaffoldKey,
    required this.currentRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  scaffoldKey.currentState?.openDrawer();
                },
              ),
              IconButton(
                icon: const Icon(Icons.home),
                color: currentRoute == '/' ? Colors.orange : null,
                onPressed: () {
                  if (currentRoute != '/') {
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/', (route) => false);
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                color: currentRoute == '/cart' ? Colors.orange : null,
                onPressed: () {
                  if (currentRoute != '/cart') {
                    Navigator.pushReplacementNamed(context, '/cart');
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.person),
                color: currentRoute == '/profile' ? Colors.orange : null,
                onPressed: () {
                  if (currentRoute != '/profile') {
                    Navigator.pushReplacementNamed(context, '/profile');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
