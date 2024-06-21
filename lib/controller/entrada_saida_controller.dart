// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';


class EntradaSaidaController {
  Future<void> registrarEntrada(
      String usuarioId, String vagaId) async {
    final vagaDoc = await FirebaseFirestore.instance.collection('vagas').doc(vagaId).get();
    if (vagaDoc.exists) {
      final vagaData = vagaDoc.data();
      await FirebaseFirestore.instance.collection('entradas_saidas').add({
        'usuarioId': usuarioId,
        'numeroVaga': vagaData?['numero'],
        'fileira': vagaData?['fileira'],
        'tipo': vagaData?['tipo'],
        'timestamp': FieldValue.serverTimestamp(),
        'operacao': 'entrada',
      });
    }
  }

  Future<void> registrarSaida(
      String usuarioId, String vagaId) async {
    final vagaDoc = await FirebaseFirestore.instance.collection('vagas').doc(vagaId).get();
    if (vagaDoc.exists) {
      final vagaData = vagaDoc.data();
      await FirebaseFirestore.instance.collection('entradas_saidas').add({
        'usuarioId': usuarioId,
        'numeroVaga': vagaData?['numero'],
        'fileira': vagaData?['fileira'],
        'tipo': vagaData?['tipo'],
        'timestamp': FieldValue.serverTimestamp(),
        'operacao': 'saida',
      });
    }
  }
}
