import 'dart:ui' as ui;

import 'package:mooltik/editor/gif.dart' show pictureFromFrame;
import 'package:flutter/material.dart';

import 'stroke.dart';

/// Maximum number of stored snapshots.
///
/// Each stroke generates a new snapshot.
/// Snapshot is a bitmap image.
/// This value minus 1 equals maximum number of undo's.
const int maxSnapshotCount = 16;

class FrameModel extends ChangeNotifier {
  FrameModel({ui.Image initialSnapshot})
      : unrasterizedStrokes = [],
        _snapshots = [initialSnapshot],
        _selectedSnapshotId = 0,
        _duration = 1;

  final List<Stroke> unrasterizedStrokes;

  /// Must contain at least one snapshot. [null] represents an empty screen.
  List<ui.Image> _snapshots;
  int _selectedSnapshotId;

  double get width => 1280;

  double get height => 720;

  ui.Image get snapshot => _snapshots[_selectedSnapshotId];

  bool get undoAvailable => _selectedSnapshotId > 0;

  bool get redoAvailable => _selectedSnapshotId + 1 < _snapshots.length;

  int get duration => _duration;
  int _duration;

  void undo() {
    if (undoAvailable) {
      _selectedSnapshotId--;
      notifyListeners();
    }
  }

  void redo() {
    if (redoAvailable) {
      _selectedSnapshotId++;
      notifyListeners();
    }
  }

  void add(Stroke stroke) {
    unrasterizedStrokes.add(stroke);
    _generateLastSnapshot();
  }

  Future<void> _generateLastSnapshot() async {
    final pic = pictureFromFrame(this);
    final snapshot = await pic.toImage(width.toInt(), height.toInt());

    // Remove redoable snapshots on new stroke.
    if (_selectedSnapshotId >= 0) {
      _snapshots.removeRange(_selectedSnapshotId + 1, _snapshots.length);
    }

    _snapshots.add(snapshot);
    if (_snapshots.length > maxSnapshotCount) {
      _snapshots.removeRange(0, _snapshots.length - maxSnapshotCount);
    }
    _selectedSnapshotId = _snapshots.length - 1;

    unrasterizedStrokes.clear();
    notifyListeners();
  }
}
