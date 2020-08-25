import 'package:flutter/material.dart';

enum Tools {
  pencil,
  eraser,
}

class ToolBar extends StatelessWidget {
  const ToolBar({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.edit),
        ),
        IconButton(
          icon: Icon(Icons.clear),
        ),
      ],
    );
  }
}
