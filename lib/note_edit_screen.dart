import 'dart:async';
import 'dart:io';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:notes_app/appbar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'firebase/notes_service.dart';
import 'note.dart';


class NoteEditScreen extends StatefulWidget {
  final Note? note;

  const NoteEditScreen({super.key, this.note});

  @override
  _NoteEditScreenState createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  Timer? _debounce;
  String? _noteId;
  bool _isCreatingNote = false;


  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _noteId = widget.note?.id;

    _titleController.addListener(_onNoteChanged);
    _contentController.addListener(_onNoteChanged);
  }
  void _onNoteChanged() {
    // Debounce: wait 600ms after last change before saving
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      _autoSaveNote();
    });
  }
  void _autoSaveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isNotEmpty || content.isNotEmpty) {
      if (_noteId != null && _noteId!.isNotEmpty) {
        // Update existing note
        await FirestoreService().updateNote(_noteId!, Note(id: _noteId!, title: title, content: content));
      } else if (!_isCreatingNote) {
        // Add new note, get its ID
        _isCreatingNote = true;
        final newId = await FirestoreService().addNote(Note(title: title, content: content, id: ''));
        setState(() {
          _noteId = newId;
          _isCreatingNote = false;
        });
      }
    }
  }



  @override
  void dispose() {
    _debounce?.cancel();
    _autoSaveNote();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    if (_titleController.text.trim().isEmpty && _contentController.text.trim().isEmpty) {
      Navigator.pop(context); // Don't save empty notes, just close
      return;
    }
    final note = Note(
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      id: widget.note?.id ?? '',

    );
    Navigator.pop(context, note);
  }
  void _shareNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nothing to share!')),
      );
      return;
    }

    try {
      // 1. Get a temporary directory
      final tempDir = await getTemporaryDirectory();

      // 2. Sanitize filename
      final safeFilename = (title.isNotEmpty ? title : 'note')
          .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');

      // 3. Create the file
      final file = File('${tempDir.path}/$safeFilename.txt');
      await file.writeAsString('$title\n\n$content');

      // 4. Share as file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Sharing my note: $title',
        subject: title,
      );
    } catch (e) {
      print('Error sharing note as file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share note as file!')),
      );
    }
  }



  Future<void> downloadNoteWithCustomName(String filename, String title, String content) async {
    try {
      final downloadsDirectory = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);
      final safeFilename = filename.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      final filePath = '$downloadsDirectory/$safeFilename.txt';

      // Print the download path for testing
      print('Download path: $filePath');

      final file = File(filePath);
      await file.writeAsString('$title\n\n$content');
      print('Note saved to: $filePath');
    } catch (e) {
      print('Error saving note: $e');
    }
  }







  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Field
            Padding(
              padding: EdgeInsets.only(top: screenWidth * 0.12),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(FontAwesomeIcons.backward,
                        color: Colors.pinkAccent,
                        size: screenWidth * 0.08),

                    onPressed: () {
                      Navigator.pop(context);
                    },

                  ),

                  Spacer(),
                  IconButton(
                    icon: Icon(FontAwesomeIcons.solidShareFromSquare,
                        color:Colors.pinkAccent,
                        size: screenWidth * 0.075),
                    tooltip: 'Share',
                    onPressed: _shareNote,
                  ),

                  IconButton(
                    icon: Icon(FontAwesomeIcons.download,
                        color:Colors.pinkAccent,
                        size: 30),
                    tooltip: 'Save',
                    onPressed: () async {
                      final title = _titleController.text.trim();
                      final content = _contentController.text.trim();

                      // Prompt for filename, default to title or 'note'
                      final filename = title;

                      if (filename == null) return; // User cancelled

                      await downloadNoteWithCustomName(filename, title, content);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.download_done_rounded, color: Colors.pinkAccent),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Saved as "$filename.txt"!',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                              Text('🎉', style: TextStyle(fontSize: 18)),
                            ],
                          ),
                          backgroundColor: Color(0xFFFBB4C4), // Baby pink for a girly, modern touch
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          margin: EdgeInsets.all(16),
                          duration: Duration(seconds: 3),
                          elevation: 6,
                        ),
                      );

                      Future.delayed(Duration(seconds: 2), () {
                        ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                      });
                    },
                  ),


                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              controller: _titleController,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: 0.2,
              ),
              decoration: InputDecoration(
                hintText: 'Title',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
                border: InputBorder.none,
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
              ),
              textInputAction: TextInputAction.next,
              maxLines: 1,
            ),
            // Divider between title and content
            SizedBox(height: 6),
            // Content Field
            Expanded(
              child: TextField(
                controller: _contentController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                expands: true,
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: 'Start typing...',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 17,
                  ),
                  border: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
