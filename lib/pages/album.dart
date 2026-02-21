import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mediar/models/album.dart';
import 'package:mediar/pages/image_viewer.dart';
import 'package:mediar/widgets/media.dart';
import '../models/album_details.dart';
import '../services/album_service.dart';
import '../services/api.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';


class AlbumPage extends StatefulWidget  {
  final int albumId;

  const AlbumPage({super.key, required this.albumId});

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}


class _AlbumPageState extends State<AlbumPage> {

  late Future<AlbumDetailModel> _albumFuture;

  @override
  void initState() {
    super.initState();
    _albumFuture = AlbumService.fetchAlbum(widget.albumId);
  }


  void _reloadAlbum() {
    setState(() {
      _albumFuture = AlbumService.fetchAlbum(widget.albumId);
    });
  }

  Future<void> _refreshAlbum() async {
    setState(() {
      _albumFuture = AlbumService.fetchAlbum(widget.albumId);
    });
    await _albumFuture;
  }


  Widget _buildAddMediaDialog(int albumId) {
    final ImagePicker picker = ImagePicker();
    File? selectedImage;
    bool isLoading = false;

    return StatefulBuilder(
      builder: (context, setState) {
        Future<void> pickImage() async {
          final XFile? image =
              await picker.pickImage(source: ImageSource.gallery);

          if (image != null) {
            setState(() {
              selectedImage = File(image.path);
            });
          }
        }

        return AlertDialog(
          title: const Text('Add Media'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton.icon(
                onPressed: pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Select image'),
              ),
              const SizedBox(height: 8),
              if (selectedImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    selectedImage!,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed:
                  isLoading ? null : () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (selectedImage == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Image is required'),
                          ),
                        );
                        return;
                      }

                      setState(() => isLoading = true);

                      try {
                        await AlbumService.createMedia(
                          albumId: albumId,
                          image: selectedImage!,
                        );

                        if (!context.mounted) return;
                        Navigator.pop(context, true);
                      } catch (e) {
                        setState(() => isLoading = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to add media'),
                          ),
                        );
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEditAlbumDialog(AlbumModel album) {
    final ImagePicker picker = ImagePicker();
    final nameController = TextEditingController(text: album.name);
    final descriptionController =
        TextEditingController(text: album.description);

    File? selectedImage;
    bool isLoading = false;

    return StatefulBuilder(
      builder: (context, setState) {
        Future<void> pickImage() async {
          final XFile? image =
              await picker.pickImage(source: ImageSource.gallery);

          if (image != null) {
            setState(() {
              selectedImage = File(image.path);
            });
          }
        }

        return AlertDialog(
          title: const Text('Edit Album'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Album name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text('Change cover image'),
                ),
                const SizedBox(height: 8),
                if (selectedImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      selectedImage!,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed:
                  isLoading ? null : () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      final name = nameController.text.trim();
                      final description =
                          descriptionController.text.trim();

                      if (name.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Album name is required'),
                          ),
                        );
                        return;
                      }

                      setState(() => isLoading = true);

                      try {
                        await AlbumService.updateAlbum(
                          albumId: album.id,
                          name: name,
                          description: description,
                          image: selectedImage,
                        );

                        if (!context.mounted) return;
                        Navigator.pop(context, true);
                      } catch (e) {
                        setState(() => isLoading = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to update album'),
                          ),
                        );
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {

    String formatDate(DateTime date) {
      return '${date.day}/${date.month}/${date.year}';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Album",
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 24,
          ),
        ),
      ),

      body: FutureBuilder<AlbumDetailModel>(
        future: _albumFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final albumDetail = snapshot.data!;
          final album = albumDetail.album;
          final mediaList = albumDetail.media;

          return RefreshIndicator(
            onRefresh: _refreshAlbum,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16), 
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Image.network(
                            '${API.apiBaseUrl}${album.coverImageUrl}',
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),


                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: 250,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Theme.of(context).colorScheme.surface,
                              ],
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            Text(
                              album.name,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 26,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              album.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 18
                              ),
                            ),

                            const SizedBox(height: 6),
                            
                            Text(
                              formatDate(album.dateCreated),
                              style: TextStyle(
                                color: const Color.fromARGB(221, 139, 139, 139),
                                fontSize: 14
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  
                  if (mediaList.isNotEmpty) 
                    Text(
                      "Media", 
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 22,
                      ),
                    ),

                  const SizedBox(height: 12),

                  if (mediaList.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo_outlined,
                              size: 64,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No media yet',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap + to add your first photo',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )



                  else
                    MasonryGridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      itemCount: mediaList.length,
                      itemBuilder: (context, index) {
                        final media = mediaList[index];

                        return GestureDetector(
                          onLongPress: () async {
                            final shouldDelete = await showDialog<bool>(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Delete media'),
                                  content: const Text(
                                    'Are you sure you want to delete this media item?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (shouldDelete == true) {
                              try {
                                await AlbumService.deleteMedia(mediaId: media.id);
                                _reloadAlbum(); 
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Failed to delete media')),
                                );
                              }
                              
                            }
                          },
                          onTap: () => {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ImageViewerPage(
                                  imageUrl: '${API.apiBaseUrl}${media.imageUrl}',
                                ),
                              ),
                            )
                          },
                          child: Media(
                            id: media.id,
                            imageUrl: media.imageUrl,
                          ),
                        );
                      },
                    )


                ],
              ),
            ),
          );
        },
      ),
      
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            mini: true,
            heroTag: 'miniFab',
            onPressed: () async {
              final albumDetail = await _albumFuture;

              final updated = await showDialog<bool>(
                context: context,
                builder: (_) => _buildEditAlbumDialog(albumDetail.album),
              );

              if (updated == true) {
                _reloadAlbum();
              }
            },
            child: const Icon(Icons.edit),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'mainFab',
            onPressed: () async {
              final added = await showDialog<bool>(
                context: context,
                builder: (_) => _buildAddMediaDialog(widget.albumId),
              );

              if (added == true) {
                _reloadAlbum();
              }
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),

    );
  }
}
