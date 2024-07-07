import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TypeListWidgetGrid extends StatelessWidget {
  const TypeListWidgetGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _typesStream =
        FirebaseFirestore.instance.collection('types').snapshots();
    return StreamBuilder<QuerySnapshot>(
        stream: _typesStream,
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
                final typeData = snapshot.data!.docs[index];
                return Column(
                  children: [
                    Image.network(
                      typeData["imageUrl"],
                      height: 100,
                      width: 100,
                    ),
                    Text(
                      typeData["title"],
                    ),
                    Text(
                      typeData["id"],
                    ),
                  ],
                );
              });
        });
  }
}
