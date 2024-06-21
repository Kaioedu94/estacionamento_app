import 'package:cloud_firestore/cloud_firestore.dart';

class Reserva {
  final String usuarioId;
  final DateTime data;
  final String status;
  final String numero; // Número da vaga
  final String tipo; // Tipo da vaga
  final String fileira; // Fileira da vaga

  Reserva(this.usuarioId, this.data, this.status, this.numero, this.tipo, this.fileira);

  // Transforma um OBJETO em JSON
  Map<String, dynamic> toJson() {
    return {
      'usuarioId': usuarioId,
      'data': data,
      'status': status,
      'numero': numero,
      'tipo': tipo,
      'fileira': fileira,
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
    );
  }
}
