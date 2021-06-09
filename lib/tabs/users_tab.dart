import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:gerenciamento_loja_upis/blocs/user_bloc.dart';
import 'package:gerenciamento_loja_upis/widgets/user_tile.dart';



class UsersTab extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    final _userBloc = BlocProvider.getBloc<UserBloc>();

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Pesquisar',
                hintStyle: TextStyle(color: Colors.white),
                icon: Icon(Icons.search, color: Colors.white,),
              ),
            onChanged: _userBloc.onChangedSearch,
          ),
        ),
        Expanded( // just to avoid runtime error due to Column -> ListView.separated hierarchy
          // where those 2 widgets try to reach the height limite when there is not one
          child: StreamBuilder<List>(
            stream: _userBloc.outUsers,
            builder: (context, snapshot) {

              if(!snapshot.hasData)
                return Center(child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.pinkAccent),
                  ),
                );
              else if(snapshot.data.length == 0)
                return Center(
                  child: Text("Nenhum usuario encontrado!",
                  style: TextStyle(
                    color: Colors.pinkAccent
                    ),
                  ),
                );
              else
              return ListView.separated(
                  itemBuilder: (context, index) {
                    return UserTile(snapshot.data[index]);
                  },
                  separatorBuilder: (context, index) {
                    return Divider(
                      color: Colors.white,
                    );
                  },
                  itemCount: snapshot.data.length
              );
            }
          ),
        )
      ],
    );
  }
}