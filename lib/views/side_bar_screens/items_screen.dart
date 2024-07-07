import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:samling_app_web/views/side_bar_screens/widgets/item_list_widget_grid.dart';
import 'package:samling_app_web/views/side_bar_screens/widgets/item_list_widget_list.dart';

class ItemsScreen extends StatefulWidget {
  static const String id = "/items-screen";
  const ItemsScreen({super.key});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  dynamic _image;
  String? fileName;
  late String itemTitle;
  late String itemId;
  late String description;
  List<String> selectedTypes = [];
  List<MultiSelectItem<String>> availableTypeIds = [];
  final TextEditingController _itemTitleController = TextEditingController();
  final TextEditingController _itemIdController = TextEditingController();
  final TextEditingController _itemDescriptionController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchTypeIds();
  }

  Future<void> _fetchTypeIds() async {
    QuerySnapshot snapshot = await _firebaseFirestore.collection('types').get();
    List<MultiSelectItem<String>> typeIds = snapshot.docs.map((doc) {
      String typeId = doc['id'] as String;
      return MultiSelectItem<String>(typeId, typeId);
    }).toList();

    setState(() {
      availableTypeIds = typeIds;
    });
  }

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
    Reference ref = _firebaseStorage.ref().child("items").child(fileName!);
    UploadTask uploadTask = ref.putData(image);
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }

  uploadToFirestore() async {
    if (_formKey.currentState!.validate()) {
      if (_image != null) {
        String imageUrl = await _uploadImageToStorage(_image);
        await _firebaseFirestore.collection("items").doc(fileName).set({
          "title": itemTitle,
          "imageUrl": imageUrl,
          "categories": selectedTypes,
          "id": itemId,
          "description": description,
        });
        _clearForm();
      }
    }
  }

  _clearForm() {
    setState(() {
      _image = null;
      fileName = null;
      _itemTitleController.clear();
      _itemIdController.clear();
      _itemDescriptionController.clear();
      selectedTypes = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 1100) {
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
              "Items",
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
                controller: _itemTitleController,
                onChanged: (value) {
                  itemTitle = value;
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter Item Title";
                  } else {
                    return null;
                  }
                },
                decoration: const InputDecoration(
                  labelText: "Item Title",
                ),
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            SizedBox(
              width: 150,
              child: TextFormField(
                controller: _itemIdController,
                onChanged: (value) {
                  itemId = value;
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter Item Id";
                  } else {
                    return null;
                  }
                },
                decoration: const InputDecoration(
                  labelText: "Item Id",
                ),
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            SizedBox(
              width: 150,
              child: TextFormField(
                controller: _itemDescriptionController,
                onChanged: (value) {
                  description = value;
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter Item Description";
                  } else {
                    return null;
                  }
                },
                decoration: const InputDecoration(
                  labelText: "Item Description",
                ),
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            SizedBox(
              width: 300,
              child: MultiSelectDialogField<String>(
                items: availableTypeIds,
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
                    selectedTypes = results;
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
        ItemListWidgetGrid(),
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
                "Items",
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
                  controller: _itemTitleController,
                  onChanged: (value) {
                    itemTitle = value;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please enter Item Title";
                    } else {
                      return null;
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: "Item Title",
                  ),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              SizedBox(
                width: 150,
                child: TextFormField(
                  controller: _itemIdController,
                  onChanged: (value) {
                    itemId = value;
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
                width: 150,
                child: TextFormField(
                  controller: _itemDescriptionController,
                  onChanged: (value) {
                    description = value;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please enter Item Description";
                    } else {
                      return null;
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: "Item Description",
                  ),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              SizedBox(
                width: 300,
                child: MultiSelectDialogField<String>(
                  items: availableTypeIds,
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
                    "Select Types",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  onConfirm: (results) {
                    setState(() {
                      selectedTypes = results;
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
          ItemListWidgetList(),
        ],
      ),
    );
  }
}
