import 'package:flutter/material.dart';

class TextFieldTags extends StatefulWidget {
  const TextFieldTags({super.key, required this.tags, this.onTagsChanged});
  final List<String> tags;
  final void Function(List<String>)? onTagsChanged;

  @override
  TextFieldTagsState createState() => TextFieldTagsState();
}

class TextFieldTagsState extends State<TextFieldTags> {
  TextEditingController tagsController = TextEditingController();

  FocusNode tagsFocus = FocusNode();

  String inputTags = '';

  late List<String> tags;

  bool done = true;

  @override
  void initState() {
    super.initState();
    tags = widget.tags;
    if (tags.isNotEmpty) {
      inputTags = tags.join(',');
    }
    tagsController.text = inputTags;
  }

  void removeTag(int index) {
    setState(() {
      widget.tags.removeAt(index);
      inputTags = widget.tags.join(',');
    });
    widget.onTagsChanged?.call(tags);
  }

  void setTags() {
    if (tagsController.text != '') {
      setState(() {
        tagsController.text = tagsController.text.replaceAll(",,", ",");
        tagsController.text =
            tagsController.text.replaceAll(RegExp(r'\s+'), ' ');
        tags = tagsController.text.split(',');
        tags.removeWhere((item) => item.isEmpty);
        tags = tags.map((s) => s.trim()).toList();
        inputTags = tags.join(',');
        tagsController.text = '';
        done = true;
      });
      widget.onTagsChanged?.call(tags);
    }
  }

  @override
  void dispose() {
    tagsController.dispose();
    tagsFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return done
        ? Wrap(
            spacing: 5,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.center,
            children: [
                const Text("Tags"),
                const SizedBox(width: 10),
                for (var tag in widget.tags)
                  InputChip(
                      avatar: const Icon(Icons.tag),
                      label: Text(tag),
                      isEnabled: true,
                      onDeleted: () {
                        setState(() {
                          removeTag(tags.indexOf(tag));
                        });
                      }),
                const SizedBox(width: 10),
                IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () {
                      tagsController.text = inputTags;
                      tagsFocus.requestFocus();
                      setState(() {
                        done = false;
                      });
                    })
              ])
        : TextFormField(
            decoration: const InputDecoration(
              label: Text('Tags'),
              hintText: 'Enter tags separated by commas',
            ),
            controller: tagsController,
            focusNode: tagsFocus,
            onEditingComplete: () {
              setTags();
            },
            onTapOutside: (_) {
              setTags();
            },
            onFieldSubmitted: (_) {
              setTags();
            });
  }
}
