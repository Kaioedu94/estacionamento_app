// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import necessário
import '../components/util.dart';

class LoginController {
  //
  // CRIAR CONTA
  //
  criarConta(BuildContext context, String nome, String email, String senha) {
    FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: senha,
    ).then((resultado) async {
      User? user = resultado.user;
      if (user != null) {
        // Atualiza o displayName no Firebase Auth
        await user.updateDisplayName(nome);

        // Adiciona o usuário ao Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'nome': nome,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(), // Adiciona a data de criação
        });

        sucesso(context, 'Usuário criado com sucesso!');
        Navigator.pop(context);
      }
    }).catchError((e) {
      String errorMsg = 'Ocorreu um erro desconhecido.';
      switch (e.code) {
        case 'email-already-in-use':
          errorMsg = 'O e-mail já está em uso. Tente outro e-mail.';
          break;
        case 'invalid-email':
          errorMsg = 'O formato do e-mail é inválido. Verifique e tente novamente.';
          break;
        case 'weak-password':
          errorMsg = 'A senha é muito fraca. Escolha uma senha mais forte.';
          break;
        case 'operation-not-allowed':
          errorMsg = 'Operação não permitida. Contate o suporte.';
          break;
        default:
          errorMsg = 'ERRO: ${e.code.toString()}';
      }
      erro(context, errorMsg);
      if (kDebugMode) {
        print('Erro ao criar conta: ${e.code.toString()}');
      }
    });
  }

  //
  // LOGIN
  //
  login(BuildContext context, String email, String senha) {
    FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: senha)
        .then((resultado) {
      sucesso(context, 'Usuário autenticado com sucesso!');
      Navigator.pushNamed(context, 'principal');
    }).catchError((e) {
      String errorMsg = 'Ocorreu um erro desconhecido.';
      switch (e.code) {
        case 'user-not-found':
          errorMsg = 'Usuário não encontrado. Verifique o e-mail e tente novamente.';
          break;
        case 'wrong-password':
          errorMsg = 'Senha incorreta. Tente novamente.';
          break;
        case 'invalid-email':
          errorMsg = 'O formato do e-mail é inválido. Verifique e tente novamente.';
          break;
        default:
          errorMsg = 'ERRO: ${e.code.toString()}';
      }
      erro(context, errorMsg);
      if (kDebugMode) {
        print('Erro ao fazer login: ${e.code.toString()}');
      }
    });
  }

  //
  // ESQUECEU A SENHA
  //
  esqueceuSenha(BuildContext context, String email) {
    if (email.isNotEmpty) {
      FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      ).then((value) {
        sucesso(context, 'E-mail de recuperação enviado com sucesso!');
      }).catchError((e) {
        String errorMsg = 'Não foi possível enviar o e-mail.';
        switch (e.code) {
          case 'invalid-email':
            errorMsg = 'O formato do e-mail é inválido. Verifique e tente novamente.';
            break;
          case 'user-not-found':
            errorMsg = 'Usuário não encontrado. Verifique o e-mail e tente novamente.';
            break;
          default:
            errorMsg = 'ERRO: ${e.code.toString()}';
        }
        erro(context, errorMsg);
        if (kDebugMode) {
          print('Erro ao enviar e-mail de recuperação: ${e.code.toString()}');
        }
      });
    } else {
      erro(context, 'Por favor, insira um e-mail.');
    }
  }

  //
  // LOGOUT
  //
  logout() {
    FirebaseAuth.instance.signOut();
  }

  //
  // ID do Usuário Logado
  //
  String idUsuario() {
    final user = FirebaseAuth.instance.currentUser;
    return user != null ? user.uid : 'Usuário não logado';
  }
}
