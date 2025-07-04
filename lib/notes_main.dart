import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'appbar.dart';
import 'firebase/notes_service.dart';
import 'note.dart';
import 'note_edit_screen.dart';
import 'package:intl/intl.dart';

class NotesHome extends StatefulWidget {
  @override
  _NotesHomeState createState() => _NotesHomeState();
}

class _NotesHomeState extends State<NotesHome> {
  String _searchQuery = '';
  List<Note> notes = [];
  late TextEditingController _controller;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;

    return PopScope(
      canPop: false, // Set to false to prevent popping (going back)
      onPopInvoked: (bool didPop) {
        // This callback runs when a pop (back) is attempted.
        // didPop == true if the pop succeeded, false if blocked by canPop.
        if (!didPop) {
          // Optionally show a dialog or snackbar here
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        //backgroundColor: Colors.transparent,

        body: Container(
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: SafeArea(
            child: Column(
              children: [
                //SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight),
                // if (user != null) UserProfileColumn(user: user),
                SizedBox(height: 15,),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right:10.0,left: 28),
                      child: Text('notes',style: TextStyle(
                        fontWeight: FontWeight.w600,

                        fontSize: 29
                      ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Icon(FontAwesomeIcons.book,
                        color: Colors.pinkAccent,
                      ),
                    ),
                  ],
                ),


                Padding(
                  padding: const EdgeInsets.only(left: 17.0,top: 12.0,right: 15),
                  child:
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          onChanged: (query) {
                            setState(() {
                              _searchQuery = query;
                            });
                          },
                          style: TextStyle(color: Colors.indigo),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.search, color: Colors.purpleAccent),
                            hintText: "Search notes...",
                            hintStyle: TextStyle(color: Colors.blueGrey),
                            filled: true,
                            fillColor: Color(0xFFE6F7F7),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
                Expanded(
                  child: StreamBuilder<List<Note>>(
                    stream: FirestoreService().getNotes(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return _buildEmptyState(context);
                      }
                      final notes = snapshot.data!;
                      final filteredNotes = _searchQuery.isEmpty
                          ? notes
                          : notes.where((note) =>
                      note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          note.content.toLowerCase().contains(_searchQuery.toLowerCase())
                      ).toList();
                    /*
                      filteredNotes.sort((a, b) {
                        if (a.lastEdited == null && b.lastEdited == null) return 0;
                        if (a.lastEdited == null) return 1;
                        if (b.lastEdited == null) return -1;
                        return b.lastEdited!.compareTo(a.lastEdited!);
                      });
                     */
                      if (filteredNotes.isEmpty) {
                        print('No notes match the search: $_searchQuery');
                        return Center(
                          child: Text(
                            "No notes found for your search.",
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: EdgeInsets.fromLTRB(16, 20, 16, 80),
                        itemCount: filteredNotes.length,
                        separatorBuilder: (_, __) => SizedBox(height: 18),
                        itemBuilder: (context, index) {
                          final note = filteredNotes[index];
                          return InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () async {
                              final editedNote = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NoteEditScreen(note: note),
                                ),
                              );
                              if (editedNote != null) {
                                await FirestoreService().updateNote(editedNote.id, editedNote);
                              }
                            },
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              color: Colors.white.withOpacity(0.97),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 13),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            note.title,
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF3A3A77),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(FontAwesomeIcons.fileEdit, color: Color(0xFF5B5EFA)),
                                          tooltip: "Edit Note",
                                          onPressed: () async {
                                            final editedNote = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => NoteEditScreen(note: note),
                                              ),
                                            );
                                            if (editedNote != null) {
                                              await FirestoreService().updateNote(editedNote.id,
                                                editedNote.copyWith(lastEdited: DateTime.now()),);
                                            }
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(FontAwesomeIcons.remove, color: Colors.redAccent),
                                          tooltip: "Delete Note",
                                          onPressed: () => FirestoreService().deleteNote(note.id),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      note.content,
                                      maxLines: 1, // Show only the first line
                                      overflow: TextOverflow.ellipsis, // Add "..." if the content is longer
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey.shade800,
                                      ),
                                    ),

                                    SizedBox(height: 7),
                                    Text(
                                      note.lastEdited != null
                                          ? '${DateFormat.yMMMd().format(note.lastEdited!)}'
                                          : '',
                                      style: TextStyle(fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          icon: Icon(Icons.add),
          label: Text('Add Note'),
          backgroundColor: Color(0xFFE6F7F7),
          onPressed: () async {
            final newNote = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NoteEditScreen(),
              ),
            );
            if (newNote != null) {
              await FirestoreService().addNote(newNote);
            }
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 120.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sticky_note_2_rounded, size: 90, color: Colors.white70),
            SizedBox(height: 24),
            Text(
              "No notes yet",
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Tap the '+' button to create your first note.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}


