import 'package:flutter/material.dart';
import 'package:gerenciamento_loja_upis/blocs/login_bloc.dart';
import 'package:gerenciamento_loja_upis/widgets/input_field.dart';

import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

// stateful because the screen will change with opening and closing the keyboard
class _LoginScreenState extends State<LoginScreen> {

  final LoginBloc _loginBloc = LoginBloc();

  @override
  void initState() {
    super.initState();
    // we cannot switch screens or display dialogs within the StreamBuilder because...
    _loginBloc.outState.listen( (state) {
      switch(state) {
        case LoginState.SUCCESS:
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => HomeScreen())
          );
          break;
        case LoginState.FAIL:
        // both not an admin or not an user at all errors
          showDialog(context: context, builder: (context) => AlertDialog(
            title: Text('Erro'),
            content: Text('Você não possui os privilégios necessários'),
          ));
          break;
        case LoginState.LOADING:
        case LoginState.IDLE:
        // nothing to do because we already address those states in build method
      }
    });
  }

  @override
  void dispose() {
    _loginBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[850],
        body: StreamBuilder<LoginState>(
            stream: _loginBloc.outState,
            initialData: LoginState.LOADING,
            builder: (context, snapshot) {
              print('[LoginScreenState.build] ${snapshot.data}');
              switch(snapshot.data) {
                case LoginState.LOADING:
                  return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.pinkAccent)));
                case LoginState.FAIL:
                case LoginState.IDLE:
                case LoginState.SUCCESS:
                default:
                  return Stack( // center child, but needed an empty container as its child
                    alignment: Alignment.center,
                    children: [
                      Container(),
                      SingleChildScrollView(
                          child: Container( // just to set margins
                            margin: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Icon(Icons.store_mall_directory,
                                    color: Colors.pinkAccent,
                                    size: 160
                                ),
                                InputField(icon: Icons.person_outline,
                                  obscure: false,
                                  label: 'Usuário (a)',
                                  stream: _loginBloc.outEmail,
                                  onChanged: _loginBloc.changeEmail,
                                ),
                                InputField(icon: Icons.person_outline,
                                  obscure: true,
                                  label: 'Senha',
                                  stream: _loginBloc.outPass,
                                  onChanged: _loginBloc.changePass,
                                ),
                                SizedBox(height: 32), // space between column's items
                                StreamBuilder<bool>(
                                    stream: _loginBloc.outSubmittedValid,
                                    builder: (context, snapshot) {
                                      return SizedBox( // just to set the button's height
                                        child: ElevatedButton(
                                            child: Text('Entrar'),
                                            onPressed: snapshot.hasData && snapshot.data ?
                                            _loginBloc.submit : null,
                                            style: ElevatedButton.styleFrom(
                                              onSurface: Colors.pinkAccent.withAlpha(140), // disabled color
                                              primary: Colors.pinkAccent,
                                              //onPrimary: Colors.grey[850],
                                            )
                                        ),
                                        height: 50,
                                      );
                                    }
                                )
                              ],
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                            ),
                          )
                      ),
                    ],
                  );
              }
            }
        ) // scrollable content
    );
  }
}