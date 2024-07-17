import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:flutter/services.dart';

class FilePicker extends StatefulWidget {
  const FilePicker(
      {super.key,
      this.onSelect,
      this.fab = false,
      this.extendedFab = false,
      this.allowMultiple = true});
  final void Function(List<XFile>?)? onSelect;
  final bool fab;
  final bool extendedFab;
  final bool allowMultiple;

  @override
  State<FilePicker> createState() => FilePickerState();
}

class FilePickerState extends State<FilePicker> {
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
  }

  void _pickFiles() async {
    fp.FilePickerResult? paths;
    try {
      paths = (await fp.FilePicker.platform.pickFiles(
        lockParentWindow: true,
        compressionQuality: 30,
        allowMultiple: widget.allowMultiple,
        onFileLoading: (fp.FilePickerStatus status) => print(status),
        dialogTitle: "Librairian",
      ));
    } on PlatformException catch (e) {
      _logException('Unsupported operation: $e');
    } catch (e) {
      _logException(e.toString());
    }
    if (!mounted) return;
    widget.onSelect?.call(paths?.xFiles);
  }

  void _logException(String message) {
    print(message);
    _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    _scaffoldMessengerKey.currentState?.showSnackBar(
      const SnackBar(
        content: Text(
          "Une erreur est survenue",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.fab) {
      return FloatingActionButton(
        tooltip: "Add files",
        child: const Icon(Icons.add),
        onPressed: () {
          _pickFiles();
        },
      );
    }
    if (widget.extendedFab) {
      return FloatingActionButton.extended(
        onPressed: () {
          _pickFiles();
        },
        label: const Text("Add files"),
        icon: const Icon(Icons.add),
      );
    }
    return IconButton(
      tooltip: widget.allowMultiple ? "Add files" : "Add file",
      icon: const Icon(Icons.add),
      onPressed: () {
        _pickFiles();
      },
    );
  }
}
