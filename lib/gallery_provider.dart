import 'dart:io';
import 'package:flutter/material.dart';

class GalleryProvider extends ChangeNotifier {
  final List<File> _gallery = [];
  File? _lastRemovedImage;
  int? _lastRemovedIndex;

  List<File> get gallery => _gallery;

  void addImage(File image) {
    if (_gallery.any((f) => f.path == image.path)) {
      throw Exception('duplicate_image');
    }
    _gallery.insert(0, image);
    notifyListeners();
  }

  void removeImage(int index) {
    _lastRemovedImage = _gallery[index];
    _lastRemovedIndex = index;
    _gallery.removeAt(index);
    notifyListeners();
  }

  void undoRemove() {
    if (_lastRemovedImage != null && _lastRemovedIndex != null) {
      _gallery.insert(_lastRemovedIndex!, _lastRemovedImage!);
      _lastRemovedImage = null;
      _lastRemovedIndex = null;
      notifyListeners();
    }
  }
}
