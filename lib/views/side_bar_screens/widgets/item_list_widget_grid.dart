import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ItemListWidgetGrid extends StatelessWidget {
  const ItemListWidgetGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _itemsStream =
        FirebaseFirestore.instance.collection('items').snapshots();
    return StreamBuilder<QuerySnapshot>(
        stream: _itemsStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }

          return GridView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.docs.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6, mainAxisSpacing: 8, crossAxisSpacing: 8),
              itemBuilder: (context, index) {
                final itemData = snapshot.data!.docs[index];
                return Column(
                  children: [
                    Image.network(
                      itemData["imageUrl"],
                      height: 100,
                      width: 100,
                    ),
                    Text(
                      itemData["title"],
                    ),
                    Text(
                      itemData["id"],
                    ),
                  ],
                );
              });
        });
  }
}
