import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'order_header.dart';

class OrderTile extends StatelessWidget {

  final DocumentSnapshot order;

  OrderTile(this.order);

  final states = [
    "", "Pagamento", "Em preparação", "Em transporte", "Aguardando Entrega", "Entregue"
  ];

  @override
  Widget build(BuildContext context) {

    Future<void> _showMyDialog() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('ATENÇÃO: ÚLTIMO AVISO'),
            backgroundColor: Color.fromARGB(255, 255, 255, 255),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Realmente deseja excluir?'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('CANCELAR',
                  style: TextStyle(
                      color: Colors.grey[700]
                  ),),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Sim',
                  style: TextStyle(
                      color: Colors.red
                  ),),
                onPressed: () {
                  Firestore.instance
                      .collection("users")
                      .document(order["clientId"])
                      .collection("orders")
                      .document(order.documentID)
                      .delete();
                  order.reference.delete();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        child: ExpansionTile(
          key: Key(order.documentID),
          initiallyExpanded: order.data["status"] != 5,
          title: Text(
            "#${order.documentID.substring(order.documentID.length -6, order.documentID.length)} - "
            "${states[order.data["status"]]}",
            style: TextStyle(
              color: order.data["status"] != 5 ? Colors.grey[850] : Colors.green
            ),
          ),
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  OrderHeader(order),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: order.data["products"].map<Widget>((p){
                      return ListTile(
                        title: Text(
                          p["product"]["title"]
                        ),
                        subtitle: Text(
                            p["category"] + "/" + p["pid"]
                        ),
                        trailing: Text(
                          p["quantity"].toString(),
                          style: TextStyle(
                              fontSize: 20
                          ),
                        ),
                        contentPadding: EdgeInsets.zero,
                      );
                  }).toList(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      TextButton(
                        onPressed: (){_showMyDialog();},
                        style: TextButton.styleFrom(primary: Colors.red),
                        child: Text(
                          "Excluir"
                        ),
                      ),
                      TextButton(
                        onPressed: order.data["status"] > 1 ? (){
                          order.reference.updateData({"status": order.data["status"] - 1});
                        } : null ,
                        style: TextButton.styleFrom(primary: Colors.grey[850]),
                        child: Text(
                            "Regredir"
                        ),
                      ),
                      TextButton(
                        onPressed: order.data["status"] < 5 ? (){
                          order.reference.updateData({"status": order.data["status"] + 1});
                        } : null,
                        style: TextButton.styleFrom(primary: Colors.green),
                        child: Text(
                            "Avançar"
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
