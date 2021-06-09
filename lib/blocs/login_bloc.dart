import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gerenciamento_loja_upis/validators/login_validators.dart';
import 'package:rxdart/rxdart.dart';

enum LoginState {IDLE, LOADING, SUCCESS, FAIL}

class LoginBloc extends BlocBase with LoginValidators {

  final _emailController = BehaviorSubject<String>();
  final _passController = BehaviorSubject<String>();
  final _stateController = BehaviorSubject<LoginState>();

  Stream<String> get outEmail => _emailController.stream.transform(validateEmail);
  Stream<String> get outPass => _passController.stream.transform(validadePass);
  // combine only emits if all streams have already emitted at least one value each
  Stream<bool> get outSubmittedValid => Rx.combineLatest2(outEmail, outPass,
          (a, b) => a != null && b != null
  );
  Stream<LoginState> get outState => _stateController.stream;

  Function(String) get changeEmail => _emailController.sink.add;
  Function(String) get changePass => _passController.sink.add;

  StreamSubscription _streamSubscription;

  LoginBloc() {

    //Logout
    //FirebaseAuth.instance.signOut();
    _streamSubscription = FirebaseAuth.instance.onAuthStateChanged.listen((firebaseUser) async {
      if(firebaseUser != null) {
        if(await verifyPrivileges(firebaseUser)) {
          print('[onAuthStateChanged] É admin!');
          _stateController.add(LoginState.SUCCESS);
        } else {
          print('[onAuthStateChanged] NÃO é admin!');
          FirebaseAuth.instance.signOut();
          _stateController.add(LoginState.FAIL);
        }
      } else {
        print('[onAuthStateChanged] esperando!');
        _stateController.add(LoginState.IDLE);
      }
    });
  }

  void submit() {

    final email = _emailController.value;
    final pass = _passController.value;

    _stateController.add(LoginState.LOADING);

    FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email, password: pass
    ).catchError( (e) {
      _stateController.add(LoginState.FAIL);
    });
  }

  Future<bool> verifyPrivileges(FirebaseUser user) async {
    print('[verifyPrivileges] ${user.uid}');
    return await Firestore.instance.collection('admins').document(user.uid).get()
        .then( (doc) => doc.data != null) // is admin if data user was found in admins collections and returned
        .catchError( (error) => false ); // not an admin, or does not event has access to the admins collections
  }

  @override
  void dispose() {
    _emailController.close();
    _passController.close();
    _stateController.close();
    _streamSubscription.cancel();

    super.dispose();
  }
}