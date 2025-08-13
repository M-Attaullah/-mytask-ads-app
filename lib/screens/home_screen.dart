import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/task_view_model.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/task_view_model.dart' show NoteViewModel;
import '../widgets/note_card.dart';
import '../widgets/banner_container.dart';
import '../services/ad_manager.dart';
import '../models/task_model.dart';
import 'add_edit_note_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  int _navigationCount = 0; // Track navigation count for interstitial ads

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NoteViewModel>().loadNotes();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<AuthViewModel>(
          builder: (context, authViewModel, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Notes'),
                if (authViewModel.currentUser != null)
                  Text(
                    'Welcome, ${authViewModel.currentUser!.name}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
              ],
            );
          },
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                final authViewModel = Provider.of<AuthViewModel>(
                  context,
                  listen: false,
                );
                await authViewModel.signOut();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Logout'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'All Notes'),
            Tab(text: 'Today'),
            Tab(text: 'Favorites'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search section
          Container(
            color: Theme.of(context).primaryColor,
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          Expanded(
            child: Consumer<NoteViewModel>(
              builder: (context, noteViewModel, child) {
                if (noteViewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildNoteList(noteViewModel.notes, noteViewModel),
                    _buildNoteList(
                      noteViewModel.getTodayNotes(),
                      noteViewModel,
                    ),
                    Center(child: Text('Favorites feature coming soon!')),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddNote(context),
        child: const Icon(Icons.add),
        tooltip: 'Add new note',
      ),
      bottomNavigationBar: const BannerContainer(), // Add banner ad at bottom
    );
  }

  Widget _buildNoteList(List<Note> notes, NoteViewModel noteViewModel) {
    List<Note> filteredNotes = notes;
    if (_searchQuery.isNotEmpty) {
      filteredNotes = noteViewModel
          .searchNotes(_searchQuery)
          .where((note) => notes.contains(note))
          .toList();
    }
    if (filteredNotes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note_alt, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No notes yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add a new note',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => noteViewModel.loadNotes(),
      child: ListView.builder(
        itemCount: filteredNotes.length,
        itemBuilder: (context, index) {
          final note = filteredNotes[index];
          return NoteCard(
            note: note,
            onTap: () => _navigateToEditNote(context, note),
            onDelete: () => _showDeleteDialog(context, note, noteViewModel),
          );
        },
      ),
    );
  }

  void _navigateToAddNote(BuildContext context) {
    _navigationCount++; // Increment navigation count
    
    // Show debug info
    debugPrint('Navigation count: $_navigationCount');
    
    // Show interstitial ad after every 3rd navigation
    if (_navigationCount % 3 == 0) {
      debugPrint('Attempting to show interstitial ad...');
      AdManager.instance.showInterstitialBeforeNavigate(() {
        debugPrint('Interstitial ad dismissed, navigating...');
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const AddEditNoteScreen()),
        );
      });
    } else {
      debugPrint('No ad this time, navigating directly...');
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const AddEditNoteScreen()),
      );
    }
  }

  void _navigateToEditNote(BuildContext context, Note note) {
    _navigationCount++; // Increment navigation count
    
    // Show interstitial ad after every 3rd navigation
    if (_navigationCount % 3 == 0) {
      AdManager.instance.showInterstitialBeforeNavigate(() {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => AddEditNoteScreen(note: note)),
        );
      });
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => AddEditNoteScreen(note: note)),
      );
    }
  }

  void _showDeleteDialog(
    BuildContext context,
    Note note,
    NoteViewModel noteViewModel,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Note'),
          content: Text('Are you sure you want to delete "${note.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteNote(note, noteViewModel);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _deleteNote(Note note, NoteViewModel noteViewModel) async {
    final success = await noteViewModel.deleteNote(note.id!);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Note "${note.title}" deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete note'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
