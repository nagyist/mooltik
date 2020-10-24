import 'package:flutter/material.dart';
import 'package:mooltik/editor/toolbox/toolbox_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart' as fcp;

class ColorPicker extends StatelessWidget {
  const ColorPicker({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final toolbox = context.watch<ToolboxModel>();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showColorPicker(context),
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: ClipOval(
            child: CustomPaint(
              painter: TileBackgroundPainter(),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: toolbox.selectedColor,
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    final toolbox = context.read<ToolboxModel>();

    showDialog(
      context: context,
      child: AlertDialog(
        titlePadding: EdgeInsets.all(0.0),
        contentPadding: EdgeInsets.all(0.0),
        content: SingleChildScrollView(
          child: fcp.ColorPicker(
            pickerColor: toolbox.selectedColor,
            onColorChanged: (color) {
              toolbox.selectColor(color);
            },
            showLabel: false,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
      ),
    );
  }
}

class TileBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Size tileSize = Size(size.width / 7, size.height / 7);
    final Paint greyPaint = Paint()..color = const Color(0xFFCCCCCC);
    final Paint whitePaint = Paint()..color = Colors.white;
    List.generate((size.height / tileSize.height).round(), (int y) {
      List.generate((size.width / tileSize.width).round(), (int x) {
        canvas.drawRect(
          Offset(tileSize.width * x, tileSize.height * y) & tileSize,
          (x + y) % 2 != 0 ? whitePaint : greyPaint,
        );
      });
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}