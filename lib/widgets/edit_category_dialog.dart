import 'dart:io';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gerenciamento_loja_upis/blocs/category_bloc.dart';

import 'image_source_sheet.dart';


class EditCategoryDialog extends StatelessWidget {

  final CategoryBloc _categoryBloc;

  final TextEditingController _controller;

  EditCategoryDialog({DocumentSnapshot category}) :
      _categoryBloc = CategoryBloc(category),
      _controller = TextEditingController(text: category != null ?
          category.data["title"] : ""
      );


  @override
  Widget build(BuildContext context) {

    Future<void> _showMyDialog() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('ATENÇÃO: ÚLTIMO AVISO',
              style: TextStyle(fontSize: 25),),
            backgroundColor: Color.fromARGB(255, 255, 255, 255),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Realmente deseja excluir? Ao excluir irá apagar todos os produtos da categoria caso tenha!'),
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
                  _categoryBloc.delete();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    return Dialog(
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: GestureDetector(
                onTap: (){
                  showModalBottomSheet(context: context,
                      builder: (context) => ImageSourceSheet(
                        onImageSelected: (image){
                          Navigator.of(context).pop();
                          _categoryBloc.setImage(image);
                        },
                      )
                  );
                },
                child: StreamBuilder(
                  stream: _categoryBloc.outImage,
                  builder: (context, snapshot){
                    if(snapshot.data != null)
                      return CircleAvatar(
                        child: snapshot.data is File ? Image.file(snapshot.data, fit: BoxFit.cover) : Image.network(snapshot.data, fit: BoxFit.cover,),
                        backgroundColor: Colors.transparent,
                      );
                    else return Icon(Icons.image);
                  },
                )
              ),
              title: StreamBuilder<String>(
                stream: _categoryBloc.outTitle,
                builder: (contex, snapshot){
                  return TextField(
                    controller: _controller,
                    onChanged: _categoryBloc.setTitle,
                    decoration: InputDecoration(
                        errorText: snapshot.hasError ? snapshot.error : null
                    ),
                  );
                },
              )
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                StreamBuilder<bool>(
                  stream: _categoryBloc.outDelete,
                    builder: (context, snapshot){
                    if(!snapshot.hasData) return Container();
                    return TextButton(
                      onPressed: snapshot.data ? (){
                        _showMyDialog();
                      } : null,
                      child: Text("Excluir"),
                      style: TextButton.styleFrom(primary: Colors.red),
                    );
                    }
                ),
                StreamBuilder<bool>(
                  stream: _categoryBloc.submitValid,
                    builder: (context, snapshot){
                    return TextButton(
                      onPressed: snapshot.hasData ? () async{
                        await _categoryBloc.saveData();
                        Navigator.of(context).pop();
                      } : null,
                      child: Text("Salvar"),
                      style: TextButton.styleFrom(primary: Colors.green),
                    );
                    }
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
