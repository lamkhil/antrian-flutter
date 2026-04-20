import 'package:antrian/globals/widgets/app_sidebar.dart';
import 'package:antrian/globals/widgets/app_topbar.dart';
import 'package:flutter/material.dart';
import 'package:antrian/extension/size.dart';

class AppLayout extends StatefulWidget {
  final Widget child;
  final String title;
  final List<String> breadcrumbs;

  const AppLayout({
    super.key,
    required this.child,
    required this.title,
    this.breadcrumbs = const [],
  });

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final isTablet = context.isTablet; // tambahkan ke extension

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F5F7),
      drawer: isDesktop
          ? null
          : Drawer(
              width: 240,
              child: AppSidebar(
                collapsed: false,
                onClose: () => _scaffoldKey.currentState?.closeDrawer(),
              ),
            ),
      body: Row(
        children: [
          if (isDesktop)
            Hero(
              tag: 'app-sidebar',
              child: Material(
                color: Colors.transparent,
                child: AppSidebar(collapsed: false),
              ),
            )
          else if (isTablet)
            Hero(
              tag: 'app-sidebar',
              child: Material(
                color: Colors.transparent,
                child: AppSidebar(collapsed: true),
              ),
            ), // mini sidebar ikonnya saja
          Expanded(
            child: Column(
              children: [
                Hero(
                  tag: 'app-topbar',
                  child: Material(
                    color: Colors.transparent,
                    child: AppTopBar(
                      title: widget.title,
                      breadcrumbs: widget.breadcrumbs,
                      onMenuTap: isDesktop
                          ? null
                          : () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                  ),
                ),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
