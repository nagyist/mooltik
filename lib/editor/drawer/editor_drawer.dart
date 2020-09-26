import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mooltik/editor/drawer/export_tab.dart';
import 'package:mooltik/editor/drawer/pallete_tab/pallete_tab.dart';
import 'package:mooltik/editor/timeline/timeline.dart';
import 'package:mooltik/editor/timeline/timeline_model.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mooltik/editor/frame/frame_model.dart';

import 'drawer_icon_button.dart';

class EditorDrawer extends StatefulWidget {
  EditorDrawer({
    Key key,
    this.width = 200,
    this.quickAccessButtons,
  })  : assert(width != null),
        super(key: key);

  final double width;
  final List<DrawerIconButton> quickAccessButtons;

  @override
  _EditorDrawerState createState() => _EditorDrawerState();
}

class _EditorDrawerState extends State<EditorDrawer>
    with TickerProviderStateMixin {
  bool open = true;
  AnimationController _controller;
  Animation _openCloseAnimation;

  final tabs = [
    PalleteTab(),
    Timeline(),
    ExportTab(),
  ];
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    _openCloseAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topLeft,
      children: [
        AnimatedBuilder(
          animation: _openCloseAnimation,
          child: _buildDrawerBody(),
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(48 - widget.width * _openCloseAnimation.value, 0),
              child: child,
            );
          },
        ),
        _buildDrawerBar(),
      ],
    );
  }

  Widget _buildDrawerBody() {
    return RepaintBoundary(
      child: Container(
        width: widget.width,
        color: Colors.blueGrey[800],
        child: IndexedStack(
          index: _selectedTabIndex,
          children: tabs,
        ),
      ),
    );
  }

  Widget _buildDrawerBar() {
    final frame = context.watch<FrameModel>();
    final playing = context.watch<TimelineModel>().playing;

    return Container(
      color: Colors.blueGrey[700],
      child: Column(
        children: [
          DrawerIconButton(
            icon: FontAwesomeIcons.palette,
            selected: open && _selectedTabIndex == 0,
            onTap: () => _onTabTap(0),
          ),
          DrawerIconButton(
            icon: FontAwesomeIcons.film,
            selected: open && _selectedTabIndex == 1,
            onTap: () => _onTabTap(1),
          ),
          DrawerIconButton(
            icon: FontAwesomeIcons.fileDownload,
            selected: open && _selectedTabIndex == 2,
            onTap: () => _onTabTap(2),
          ),
          Spacer(),
          DrawerIconButton(
            icon: FontAwesomeIcons.undo,
            onTap: frame.undoAvailable && !playing ? frame.undo : null,
          ),
          DrawerIconButton(
            icon: FontAwesomeIcons.redo,
            onTap: frame.redoAvailable && !playing ? frame.redo : null,
          ),
        ],
      ),
    );
  }

  void _onTabTap(int tabIndex) {
    if (_selectedTabIndex == tabIndex && open) {
      _closeDrawer();
    } else {
      setState(() {
        _selectedTabIndex = tabIndex;
      });
      if (!open) _openDrawer();
    }
  }

  void _openDrawer() {
    setState(() {
      open = true;
    });
    _animateDrawer();
  }

  void _closeDrawer() {
    setState(() {
      open = false;
    });
    _animateDrawer();
  }

  void _animateDrawer() {
    if (open) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }
}
