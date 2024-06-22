import 'package:cloud_firestore/cloud_firestore.dart';

class Reserva {
  final String usuarioId;
  final DateTime data;
  final String status;
  final String numero;
  final String tipo;
  final String fileira;
  final DateTime? entrada; // Adicionado
  final DateTime? saida;   // Adicionado

  Reserva(this.usuarioId, this.data, this.status, this.numero, this.tipo, this.fileira, this.entrada, this.saida);

  // Transforma um OBJETO em JSON
  Map<String, dynamic> toJson() {
    return {
      'usuarioId': usuarioId,
      'data': data,
      'status': status,
      'numero': numero,
      'tipo': tipo,
      'fileira': fileira,
      'entrada': entrada,
      'saida': saida,
    };
  }

  // Transforma um JSON em OBJETO
  factory Reserva.fromJson(Map<String, dynamic> json) {
    return Reserva(
      json['usuarioId'],
      (json['data'] as Timestamp).toDate(),
      json['status'],
      json['numero'],
      json['tipo'],
      json['fileira'],
      json['entrada'] != null ? (json['entrada'] as Timestamp).toDate() : null,
      json['saida'] != null ? (json['saida'] as Timestamp).toDate() : null,
    );
  }
}
