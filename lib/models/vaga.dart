class Vaga {
  final String id;
  final String numero;
  final bool disponivel;
  final String tipo; // 'coberta' ou 'descoberta'
  final String fileira; // 'A', 'B', etc.

  Vaga({
    required this.id,
    required this.numero,
    required this.disponivel,
    required this.tipo,
    required this.fileira,
  });

  // Transforma um OBJETO em JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numero': numero,
      'disponivel': disponivel,
      'tipo': tipo,
      'fileira': fileira,
    };
  }

  // Transforma um JSON em OBJETO
  factory Vaga.fromJson(Map<String, dynamic> json) {
    return Vaga(
      id: json['id'] ?? '',
      numero: json['numero'] ?? '',
      disponivel: json['disponivel'] ?? true,
      tipo: json['tipo'] ?? 'descoberta',
      fileira: json['fileira'] ?? 'A',
    );
  }
}
