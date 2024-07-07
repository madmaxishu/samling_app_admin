import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TypeListWidgetList extends StatelessWidget {
  const TypeListWidgetList({super.key});

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
            return const Text("Loading");
          }

          return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.docs.length,
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
