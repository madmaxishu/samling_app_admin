import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:samling_app_web/views/side_bar_screens/widgets/type_list_widget_grid.dart';
import 'package:samling_app_web/views/side_bar_screens/widgets/type_list_widget_list.dart';

class TypesScreen extends StatefulWidget {
  static const String id = "/types-screen";
  const TypesScreen({super.key});

  @override
  State<TypesScreen> createState() => _TypesScreenState();
}

class _TypesScreenState extends State<TypesScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  dynamic _image;
  String? fileName;
  late String typeTitle;
  late String typeId;
  List<String> selectedCategories = [];
  final TextEditingController _typeTitleController = TextEditingController();
  final TextEditingController _typeIdController = TextEditingController();

  pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null) {
      setState(() {
        _image = result.files.first.bytes;
        fileName = result.files.first.name;
      });
    }
  }

  _uploadImageToStorage(dynamic image) async {
    Reference ref = _firebaseStorage.ref().child("types").child(fileName!);
    UploadTask uploadTask = ref.putData(image);
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }

  uploadToFirestore() async {
    if (_formKey.currentState!.validate()) {
      if (_image != null) {
        String imageUrl = await _uploadImageToStorage(_image);
        await _firebaseFirestore.collection("types").doc(fileName).set({
          "title": typeTitle,
          "imageUrl": imageUrl,
          "categories": selectedCategories,
          "id": typeId,
        });
        _clearForm();
      }
    }
  }

  _clearForm() {
    setState(() {
      _image = null;
      fileName = null;
      _typeTitleController.clear();
      _typeIdController.clear();
      selectedCategories = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 900) {
            // Wide screen layout
            return _buildWideScreenLayout();
          } else {
            // Narrow screen layout
            return _buildNarrowScreenLayout();
          }
        },
      ),
    );
  }

  Widget _buildWideScreenLayout() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            alignment: Alignment.topLeft,
            child: const Text(
              "Types",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const Divider(
          color: Colors.grey,
        ),
        Row(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 140,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      border: Border.all(color: Colors.grey.shade800),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: _image != null
                          ? Image.memory(
                              _image,
                              fit: BoxFit.fill,
                            )
                          : const Text(
                              "Upload Image",
                            ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      pickImage();
                    },
                    child: const Text(
                      "Upload Image",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(
              width: 30,
            ),
            SizedBox(
              width: 150,
              child: TextFormField(
                controller: _typeTitleController,
                onChanged: (value) {
                  typeTitle = value;
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter Type Title";
                  } else {
                    return null;
                  }
                },
                decoration: const InputDecoration(
                  labelText: "Type Title",
                ),
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            SizedBox(
              width: 150,
              child: TextFormField(
                controller: _typeIdController,
                onChanged: (value) {
                  typeId = value;
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter Type Id";
                  } else {
                    return null;
                  }
                },
                decoration: const InputDecoration(
                  labelText: "Type Id",
                ),
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            SizedBox(
              width: 300,
              child: MultiSelectDialogField<String>(
                items: categories
                    .map((category) =>
                        MultiSelectItem<String>(category, category))
                    .toList(),
                title: const Text("Categories"),
                selectedColor: Colors.blue,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  border: Border.all(
                    color: Colors.grey,
                    width: 1,
                  ),
                ),
                buttonIcon: const Icon(
                  Icons.category,
                  color: Colors.grey,
                ),
                buttonText: const Text(
                  "Select Categories",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                onConfirm: (results) {
                  setState(() {
                    selectedCategories = results;
                  });
                },
              ),
            ),
            TextButton(
              onPressed: () {
                uploadToFirestore();
              },
              child: const Text("Save"),
            )
          ],
        ),
        TypeListWidgetGrid(),
      ],
    );
  }

  Widget _buildNarrowScreenLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              alignment: Alignment.topLeft,
              child: const Text(
                "Types",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const Divider(
            color: Colors.grey,
          ),
          Column(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 140,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        border: Border.all(color: Colors.grey.shade800),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: _image != null
                            ? Image.memory(
                                _image,
                                fit: BoxFit.fill,
                              )
                            : const Text(
                                "Upload Image",
                              ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        pickImage();
                      },
                      child: const Text(
                        "Upload Image",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(
                width: 30,
              ),
              SizedBox(
                width: 150,
                child: TextFormField(
                  controller: _typeTitleController,
                  onChanged: (value) {
                    typeTitle = value;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please enter Type Title";
                    } else {
                      return null;
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: "Type Title",
                  ),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              SizedBox(
                width: 150,
                child: TextFormField(
                  controller: _typeIdController,
                  onChanged: (value) {
                    typeId = value;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please enter Type Id";
                    } else {
                      return null;
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: "Type Id",
                  ),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              SizedBox(
                width: 300,
                child: MultiSelectDialogField<String>(
                  items: categories
                      .map((category) =>
                          MultiSelectItem<String>(category, category))
                      .toList(),
                  title: const Text("Categories"),
                  selectedColor: Colors.blue,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    border: Border.all(
                      color: Colors.grey,
                      width: 1,
                    ),
                  ),
                  buttonIcon: const Icon(
                    Icons.category,
                    color: Colors.grey,
                  ),
                  buttonText: const Text(
                    "Select Categories",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  onConfirm: (results) {
                    setState(() {
                      selectedCategories = results;
                    });
                  },
                ),
              ),
              TextButton(
                onPressed: () {
                  uploadToFirestore();
                },
                child: const Text("Save"),
              ),
            ],
          ),
          TypeListWidgetList(),
        ],
      ),
    );
  }
}

const List<String> categories = [
  'c1',
  'c2',
  'c3',
  'c4',
  'c5',
  'c6',
  'c7',
  'c8',
  'c9',
  'c10'
];
