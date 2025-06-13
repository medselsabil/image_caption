import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'gallery_provider.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Gallery')),
        body: Consumer<GalleryProvider>(
          builder: (context, gallery, _) {
            if (gallery.gallery.isEmpty) {
              return Center(
                child: Text(
                  'No images yet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize:
                            MediaQuery.of(context).size.width > 600 ? 24 : 18,
                      ),
                ),
              );
            }

            final screenWidth = MediaQuery.of(context).size.width;
            final crossAxisCount = screenWidth > 600 ? 5 : 3;

            return GridView.builder(
              padding: EdgeInsets.all(screenWidth > 600 ? 16 : 8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: gallery.gallery.length,
              itemBuilder: (context, index) {
                final imageFile = gallery.gallery[index];
                return Dismissible(
                  key: ValueKey(imageFile.path),
                  direction: DismissDirection.horizontal,
                  background: Container(
                    alignment: Alignment.centerLeft,
                    color: Colors.red[400],
                    child: const Padding(
                      padding: EdgeInsets.only(left: 24.0),
                      child: Icon(Icons.delete, color: Colors.white, size: 32),
                    ),
                  ),
                  secondaryBackground: Container(
                    alignment: Alignment.centerRight,
                    color: Colors.red[400],
                    child: const Padding(
                      padding: EdgeInsets.only(right: 24.0),
                      child: Icon(Icons.delete, color: Colors.white, size: 32),
                    ),
                  ),
                  onDismissed: (direction) {
                    gallery.removeImage(index);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Image deleted'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () => gallery.undoRemove(),
                        ),
                      ),
                    );
                  },
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            imageFile,
                            fit: BoxFit.cover,
                            cacheWidth: (screenWidth ~/ crossAxisCount).toInt(),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
