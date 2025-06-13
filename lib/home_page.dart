import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import 'gallery_provider.dart';
import 'gallery_screen.dart';
import 'theme_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _imageFile;
  List<ImageLabel>? _labels;
  bool _isLoading = false;
  String? _caption;
  bool _isPicking = false;

  String _creativeCaption(List<ImageLabel> labels) {
    if (labels.isEmpty) return "A moment captured, a memory created.";
    final topLabels = labels.take(2).map((l) => l.label).toList();
    final funPhrases = [
      "Here's a glimpse into my world.",
      "A little piece of today, just for you.",
      "Life, paused for a second.",
      "Not just a photo—an experience.",
      "A snapshot of something special.",
      "A new memory, freshly made.",
      "This moment brought to you by serendipity.",
      "Every picture has a story—what's yours?",
    ];
    final phrase = (funPhrases..shuffle()).first;
    return "$phrase\nDetected: ${topLabels.join(', ')}";
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isPicking) return;
    _isPicking = true;
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: source, imageQuality: 90);
      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        setState(() {
          _imageFile = imageFile;
          _labels = null;
          _isLoading = true;
          _caption = null;
        });
        try {
          context.read<GalleryProvider>().addImage(imageFile);
        } catch (e) {
          if (e.toString().contains('duplicate_image')) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('This image is already in your gallery'),
                backgroundColor: Colors.red[700],
              ),
            );
            setState(() {
              _isLoading = false;
            });
            return;
          }
        }
        await _labelImage(imageFile);
      }
    } finally {
      _isPicking = false;
    }
  }

  Future<void> _labelImage(File image) async {
    final inputImage = InputImage.fromFile(image);
    final imageLabeler = ImageLabeler(options: ImageLabelerOptions());
    final labels = await imageLabeler.processImage(inputImage);
    await imageLabeler.close();

    setState(() {
      _labels = labels;
      _isLoading = false;
      _caption = _creativeCaption(labels);
    });
  }

  Future<void> _shareImageAndCaption() async {
    if (_imageFile == null || _caption == null) return;
    await Share.shareXFiles([XFile(_imageFile!.path)], text: _caption!);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final theme = Theme.of(context);

    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;
    final double padding = isLargeScreen ? 24 : 16;
    final double fontSize = isLargeScreen ? 20 : 16;

    // For label backgrounds and borders (matches screenshot)
    final Color labelBg = Colors.grey[300]!;
    final Color labelBorder = Colors.grey[700]!;
    final Color labelText = Colors.grey[800]!;

    final Color background = theme.colorScheme.surface;
    final Color surface = theme.colorScheme.surface;
    final Color primary = theme.colorScheme.primary;
    final Color onPrimary = theme.colorScheme.onPrimary;
    final Color textColor = theme.colorScheme.surface;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0.5,
        title: Text(
          'Gallery Moments',
          style: TextStyle(
            color: primary,
            fontWeight: FontWeight.w700,
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) =>
                  RotationTransition(turns: anim, child: child),
              child: themeProvider.isDarkMode
                  ? const Icon(Icons.nightlight_round,
                      key: ValueKey('moon'), color: Colors.white)
                  : const Icon(Icons.wb_sunny,
                      key: ValueKey('sun'), color: Colors.black),
            ),
            tooltip: themeProvider.isDarkMode ? 'Light mode' : 'Dark mode',
            onPressed: themeProvider.toggleTheme,
          ),
        ],
        iconTheme: IconThemeData(color: primary),
      ),
      drawer: Drawer(
        backgroundColor: background,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: surface,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.widgets, color: primary, size: 36),
                    const SizedBox(width: 12),
                    Text(
                      'Gallery Moments',
                      style: TextStyle(
                        color: primary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Roboto',
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home_filled, color: primary),
              title: Text('Home', style: TextStyle(color: primary)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.collections_bookmark, color: primary),
              title: Text('Gallery', style: TextStyle(color: primary)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GalleryScreen()),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(_imageFile!, fit: BoxFit.contain),
                        )
                      : Center(
                          child: Text(
                            'Tap below to add your first memory',
                            style: TextStyle(
                              color: textColor.withOpacity(0.7),
                              fontSize: fontSize,
                            ),
                          ),
                        ),
                ),
              ),
              SizedBox(height: isLargeScreen ? 24 : 18),
              _buildActionButtons(context, isLargeScreen),
              if (_isLoading) ...[
                const SizedBox(height: 20),
                const CircularProgressIndicator(),
              ],
              if (_labels != null)
                Container(
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(top: 16),
                  child: Column(
                    children: [
                      Text(
                        _caption ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: fontSize,
                          color: textColor,
                          letterSpacing: 0.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 12,
                        children: _labels!
                            .map(
                              (label) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 22, vertical: 10),
                                decoration: BoxDecoration(
                                  color: labelBg,
                                  border: Border.all(
                                    color: labelBorder,
                                    width: 1.3,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${label.label} (${(label.confidence * 100).toStringAsFixed(1)}%)',
                                  style: TextStyle(
                                    color: labelText,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 10),
                      Semantics(
                        button: true,
                        label: 'Share',
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.share, color: onPrimary),
                          label: const Text('Share'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: onPrimary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: EdgeInsets.symmetric(
                                horizontal: isLargeScreen ? 32 : 24,
                                vertical: isLargeScreen ? 16 : 12),
                            elevation: 2,
                          ),
                          onPressed: _shareImageAndCaption,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isLargeScreen) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildButton(
            context,
            icon: Icons.camera_alt,
            label: 'Camera',
            isLargeScreen: isLargeScreen,
            onPressed: () => _pickImage(ImageSource.camera),
          ),
          SizedBox(width: isLargeScreen ? 24 : 16),
          _buildButton(
            context,
            icon: Icons.photo_library,
            label: 'Gallery',
            isLargeScreen: isLargeScreen,
            onPressed: () => _pickImage(ImageSource.gallery),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isLargeScreen,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;
    return Semantics(
      button: true,
      label: label,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: isLargeScreen ? 24 : 20),
        label: Text(
          label,
          style: TextStyle(fontSize: isLargeScreen ? 18 : 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: EdgeInsets.symmetric(
            horizontal: isLargeScreen ? 32 : 24,
            vertical: isLargeScreen ? 16 : 12,
          ),
          elevation: 2,
        ),
        onPressed: _isPicking ? null : onPressed,
      ),
    );
  }
}
