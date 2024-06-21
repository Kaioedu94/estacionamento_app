// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReservaController {
  // Adicionar Reserva
  Future<void> adicionarReserva(BuildContext context, String vagaId) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Obtenha os detalhes da vaga
        DocumentSnapshot vagaDoc = await FirebaseFirestore.instance.collection('vagas').doc(vagaId).get();
        Map<String, dynamic> vagaData = vagaDoc.data() as Map<String, dynamic>;

        // Atualizar o status da vaga para ocupada
        await FirebaseFirestore.instance.collection('vagas').doc(vagaId).update({
          'disponivel': false,
        });

        // Adicionar a reserva à coleção 'reservas'
        await FirebaseFirestore.instance.collection('reservas').add({
          'usuarioId': user.uid,
          'data': FieldValue.serverTimestamp(),
          'status': 'ativa',
          'numero': vagaData['numero'],
          'tipo': vagaData['tipo'],
          'fileira': vagaData['fileira'],
        });

        scaffoldMessenger.showSnackBar(SnackBar(content: Text('Reserva feita com sucesso!')));
      } else {
        scaffoldMessenger.showSnackBar(SnackBar(content: Text('Usuário não autenticado.')));
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text('Erro ao fazer reserva: $e')));
      if (kDebugMode) {
        print('Erro ao fazer reserva: $e');
      }
    }
  }

  // Concluir Reserva
  Future<void> concluirReserva(BuildContext context, String reservaId) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await FirebaseFirestore.instance.collection('reservas').doc(reservaId).update({
        'status': 'concluída',
      });

      scaffoldMessenger.showSnackBar(SnackBar(content: Text('Reserva concluída com sucesso!')));
    } catch (e) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text('Erro ao concluir reserva: $e')));
      if (kDebugMode) {
        print('Erro ao concluir reserva: $e');
      }
    }
  }

  // Cancelar Reserva
  Future<void> cancelarReserva(BuildContext context, String reservaId, String vagaNumero) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await FirebaseFirestore.instance.collection('reservas').doc(reservaId).update({
        'status': 'cancelada',
      });

      // Atualizar a vaga para disponível
      QuerySnapshot vagaSnapshot = await FirebaseFirestore.instance
          .collection('vagas')
          .where('numero', isEqualTo: vagaNumero)
          .limit(1)
          .get();
      if (vagaSnapshot.docs.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('vagas')
            .doc(vagaSnapshot.docs.first.id)
            .update({'disponivel': true});
      }

      scaffoldMessenger.showSnackBar(SnackBar(content: Text('Reserva cancelada com sucesso!')));
    } catch (e) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text('Erro ao cancelar reserva: $e')));
      if (kDebugMode) {
        print('Erro ao cancelar reserva: $e');
      }
    }
  }
}
