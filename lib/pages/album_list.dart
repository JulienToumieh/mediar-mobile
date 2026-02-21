import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mediar/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../models/album.dart';
import '../services/album_service.dart';
import '../widgets/album.dart';
import 'album.dart';
import 'profile.dart';
import 'login.dart';

class AlbumListPage extends StatefulWidget {
  const AlbumListPage({super.key});

  @override
  State<AlbumListPage> createState() => _AlbumListPageState();
}

class _AlbumListPageState extends State<AlbumListPage> with RouteAware {
  late Future<List<AlbumModel>> _albumsFuture;

  @override
  void initState() {
    super.initState();
    _albumsFuture = _loadAlbums();
  }

  @override
  void didPopNext() {
    _refreshAlbums();
    super.didPopNext();
  }

  @override
  void dispose() {
    MyApp.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      MyApp.routeObserver.subscribe(this, route);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mediar',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 28,
            fontFamily: 'JetBrainsMono',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            iconSize: 34,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: _buildAlbumGrid(),
      floatingActionButton: FloatingActionButton(
        onPressed: _onCreateAlbum,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<List<AlbumModel>> _loadAlbums() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt');

      if (token == null) {
        _redirectToLogin();
        return [];
      }

      return await AlbumService.fetchAlbums();
    } catch (e) {
      if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
        _redirectToLogin();
      }
      return [];
    }
  }

  void _redirectToLogin() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  Future<void> _refreshAlbums() async {
    setState(() {
      _albumsFuture = _loadAlbums();
    });
    await _albumsFuture;
  }



  Widget _buildAlbumGrid() {
    return FutureBuilder<List<AlbumModel>>(
      future: _albumsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final albums = snapshot.data ?? [];

        if (albums.isEmpty) {
          return RefreshIndicator(
            onRefresh: _refreshAlbums,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              children: [
                SizedBox(height: 120),
                Icon(
                  Icons.photo_album_outlined,
                  size: 72,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Center(
                  child: Text(
                    'There are no albums yet :)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Center(
                  child: Text(
                    'Tap + to create your first album',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshAlbums,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: MasonryGridView.count(
              physics: const AlwaysScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              itemCount: albums.length,
              itemBuilder: (context, index) {
                final album = albums[index];

                return GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AlbumPage(albumId: album.id),
                      ),
                    );
                  },
                  onLongPress: () => _confirmDelete(album),
                  child: Album(
                    id: album.id,
                    imageUrl: album.coverImageUrl,
                    title: album.name,
                    date: album.dateCreated,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(AlbumModel album) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete album'),
        content: Text('Are you sure you want to delete "${album.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await AlbumService.deleteAlbum(albumId: album.id);
      _refreshAlbums();
    }
  }

  Future<void> _onCreateAlbum() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (_) => _createAlbumDialog(),
    );

    if (created == true) {
      _refreshAlbums();
    }
  }

  Widget _createAlbumDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final picker = ImagePicker();

    File? selectedImage;
    bool isLoading = false;

    return StatefulBuilder(
      builder: (context, setState) {
        Future<void> pickImage() async {
          final image = await picker.pickImage(source: ImageSource.gallery);
          if (image != null) {
            setState(() => selectedImage = File(image.path));
          }
        }

        return AlertDialog(
          title: const Text('Create Album'),
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
                  label: const Text('Select cover image'),
                ),
                if (selectedImage != null) ...[
                  const SizedBox(height: 8),
                  Image.file(selectedImage!, height: 120, fit: BoxFit.cover),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (nameController.text.trim().isEmpty ||
                          selectedImage == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Name and image required')),
                        );
                        return;
                      }

                      setState(() => isLoading = true);
                      await AlbumService.createAlbum(
                        name: nameController.text.trim(),
                        description: descriptionController.text.trim(),
                        image: selectedImage!,
                      );

                      Navigator.pop(context, true);
                    },
              child: isLoading
                  ? const CircularProgressIndicator(strokeWidth: 2)
                  : const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
