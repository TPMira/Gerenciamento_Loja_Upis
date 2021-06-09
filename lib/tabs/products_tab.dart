import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gerenciamento_loja_upis/widgets/category_tile.dart';


class ProductsTab extends StatefulWidget {
  @override
  _ProductsTabState createState() => _ProductsTabState();
}

class _ProductsTabState extends State<ProductsTab> with AutomaticKeepAliveClientMixin {

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection("products").snapshots(),
        builder: (context, snaphot){
          if(!snaphot.hasData) return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ),
          );
          return ListView.builder(
              itemCount: snaphot.data.documents.length,
              itemBuilder: (context, index){
                return CategoryTile(snaphot.data.documents[index]);
              }
          );
        }
    );
  }

  @override
  bool get wantKeepAlive => true;
}

