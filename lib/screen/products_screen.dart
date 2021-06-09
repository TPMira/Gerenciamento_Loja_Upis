import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gerenciamento_loja_upis/blocs/product_bloc.dart';
import 'package:gerenciamento_loja_upis/validators/products_validator.dart';
import 'package:gerenciamento_loja_upis/widgets/images_widget.dart';


class ProductScreen extends StatefulWidget {

  final String categoryId;
  final DocumentSnapshot product;

  ProductScreen({this.categoryId, this.product});

  @override
  _ProductScreenState createState() => _ProductScreenState(categoryId, product);
}

class _ProductScreenState extends State<ProductScreen> with ProductValidator {
  final ProductBloc _productBloc;

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  _ProductScreenState(String categoryId, DocumentSnapshot product)
      : _productBloc = ProductBloc(categoryId: categoryId, product: product);

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
                _productBloc.deleteProduct();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    InputDecoration _buildDecoration(String label) {
      return InputDecoration(
          labelText: label, labelStyle: TextStyle(color: Colors.white));
    }

    final _fieldStyle = TextStyle(color: Colors.white, fontSize: 16);



    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        elevation: 0,
        title: StreamBuilder<bool>(
          stream: _productBloc.outCreated,
          initialData: false,
          builder: (context, snapshot){
            return  Text(snapshot.data ? "Editar Produto" : "Criar Produto");
          }
        ),
        actions: <Widget>[
          StreamBuilder<bool>(
            stream: _productBloc.outCreated,
            initialData: false,
            builder: (context, snapshot){
              if(snapshot.data)
                return StreamBuilder<bool>(
                    stream: _productBloc.outLoading,
                    initialData: false,
                    builder: (context, snapshot){
                      return IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: snapshot.data ? null : (){
                          _showMyDialog();
                        },
                      );
                    }
                );
              else return Container();
            },
          ),
          StreamBuilder<bool>(
              stream: _productBloc.outLoading,
              initialData: false,
              builder: (context, snapshot){
                return IconButton(
                  icon: Icon(Icons.save),
                  onPressed: snapshot.data ? null : saveProduct,
                );
              }
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          Form(
              key: _formKey,
              child: StreamBuilder<Map>(
                stream: _productBloc.outData,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Container();
                  return ListView(
                    padding: EdgeInsets.all(16),
                    children: <Widget>[
                      Text(
                        "Imagens",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      ImagesWidget(
                        context: context,
                        initialValue: snapshot.data["image"],
                        onSaved: _productBloc.saveImage,
                        validator: validateImages,
                      ),
                      TextFormField(
                        initialValue: snapshot.data["title"],
                        style: _fieldStyle,
                        decoration: _buildDecoration("Titulo"),
                        onSaved: _productBloc.saveTitle,
                        validator: validateTitle,
                      ),
                      TextFormField(
                        initialValue: snapshot.data["description"],
                        maxLines: 6,
                        style: _fieldStyle,
                        decoration: _buildDecoration("Descrição"),
                        onSaved: _productBloc.saveDescription,
                        validator: validateDescription,
                      ),
                      TextFormField(
                        initialValue: snapshot.data["price"]?.toStringAsFixed(2),
                        keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                        style: _fieldStyle,
                        decoration: _buildDecoration("Preço"),
                        onSaved: _productBloc.savePrice,
                        validator: validatePrice,
                      ),
                    ],
                  );
                },
              )
          ),
          StreamBuilder<bool>(
              stream: _productBloc.outLoading,
              initialData: false,
              builder: (context, snapshot){
                return IgnorePointer(
                  ignoring: !snapshot.data,
                  child: Container(
                    color: snapshot.data ? Colors.black54 : Colors.transparent,
                  ),
                );
              }
          ),
        ],
      )
    );
  }

  void saveProduct() async{
    if(_formKey.currentState.validate()){
      _formKey.currentState.save();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("Salvando Produto...",
          style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.pinkAccent,
        duration: const Duration(minutes: 1),
      )
      );

      bool success = await _productBloc.saveProduct();

      ScaffoldMessenger.of(context).removeCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success ? "Produto salvo" : "Erro ao salvar",
          style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.pinkAccent,
      )
      );
      Navigator.of(context).pop();
    }
  }
}