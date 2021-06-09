import 'dart:async';

class LoginValidators {
  final validateEmail = StreamTransformer<String, String>.fromHandlers( // StreamTransforme<source type, transformed type>
    handleData: (email, sink) {
      if(email.contains('@')) {
        sink.add(email);
      } else {
        sink.add(null);
        sink.addError('Insira um e-mail válido.');
      }
    },
  );

  final validadePass = StreamTransformer<String, String>.fromHandlers( // StreamTransforme<source type, transformed type>
    handleData: (pass, sink) {
      if(pass.length > 5) {
        sink.add(pass);
      } else {
        sink.add(null);
        sink.addError('Senha tem de conter 6 ou mais caracteres');
      }
    },
  );
}