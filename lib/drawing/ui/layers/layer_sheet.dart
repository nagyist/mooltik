import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mooltik/common/data/project/project.dart';
import 'package:mooltik/common/ui/app_icon_button.dart';
import 'package:mooltik/common/ui/labeled_icon_button.dart';
import 'package:mooltik/drawing/data/frame_reel_model.dart';
import 'package:mooltik/drawing/ui/frame_thumbnail.dart';
import 'package:provider/provider.dart';
import 'package:mooltik/drawing/data/reel_stack_model.dart';

class LayerSheet extends StatelessWidget {
  const LayerSheet({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final reelStack = context.watch<ReelStackModel>();

    return ClipRect(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Expanded(
            child: ReorderableListView(
              onReorder: reelStack.onLayerReorder,
              children: [
                for (final reel in reelStack.reels)
                  _buildInteractiveLayerRow(reel, reelStack),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Row _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildTitle(),
        Spacer(),
        AddLayerButton(),
      ],
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        'Layers',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Slidable _buildInteractiveLayerRow(
    FrameReelModel reel,
    ReelStackModel reelStack,
  ) {
    return Slidable(
      key: Key(reel.currentFrame.file.path),
      actionPane: SlidableDrawerActionPane(),
      closeOnScroll: true,
      secondaryActions: [
        SlideAction(
          color: Colors.red,
          closeOnTap: true,
          child: LabeledIconButton(
            icon: FontAwesomeIcons.trashAlt,
            label: 'Delete',
            color: Colors.white,
            onTap: reelStack.canDeleteLayer
                ? () => reelStack.deleteLayer(reelStack.reels.indexOf(reel))
                : null,
          ),
        ),
      ],
      child: LayerRow(
        selected: reel == reelStack.activeReel,
        reel: reel,
        onTap: () => reelStack.changeActiveReel(reel),
      ),
    );
  }
}

class AddLayerButton extends StatelessWidget {
  const AddLayerButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppIconButton(
      icon: FontAwesomeIcons.plus,
      onTap: () async {
        final reelStack = context.read<ReelStackModel>();
        final project = context.read<Project>();

        reelStack.addLayerAboveActive(await project.createNewSceneLayer());
      },
    );
  }
}

class LayerRow extends StatelessWidget {
  const LayerRow({
    Key key,
    this.selected,
    this.reel,
    this.onTap,
  }) : super(key: key);

  final bool selected;
  final FrameReelModel reel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Material(
        color: selected
            ? Theme.of(context).colorScheme.primary
            : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.all(8.0),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FrameThumbnail(frame: reel.currentFrame),
              ),
              SizedBox(width: 4),
              _buildLabel(context),
            ],
          ),
        ),
      ),
    );
  }

  Text _buildLabel(BuildContext context) {
    final count = reel.frameSeq.length;
    final appendix = count > 1 ? 'frames' : 'frame';
    return Text(
      '$count $appendix',
      style: selected
          ? TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            )
          : null,
    );
  }
}