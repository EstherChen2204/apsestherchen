import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

enum Estado { pendente, sincronizado, erro }

class ItemFila {
  ItemFila(this.chave, this.payload, this.estado, this.ultimoErro);
  final String chave;
  final Map<String, dynamic> payload;
  final Estado estado;
  final String? ultimoErro;
}

/// Fila local (SQLite) de ocorrências criadas, inclusive sem internet.
class Outbox {
  Database? _db;
  Future<Database> get db async => _db ??= await openDatabase(
        join(await getDatabasesPath(), 'outbox.db'),
        version: 1,
        onCreate: (d, _) => d.execute('CREATE TABLE fila('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, chave TEXT UNIQUE NOT NULL,'
            'payload TEXT NOT NULL, estado TEXT NOT NULL DEFAULT "pendente",'
            'ultimo_erro TEXT)'),
      );

  Future<String> enfileirar(Map<String, dynamic> payload) async {
    final chave = const Uuid().v4(); // vira o Idempotency-Key
    await (await db).insert('fila', {'chave': chave, 'payload': jsonEncode(payload)});
    return chave;
  }

  Future<List<ItemFila>> pendentes() async {
    final rs = await (await db).query('fila', where: 'estado = ?', whereArgs: ['pendente'], orderBy: 'id');
    return rs.map(_item).toList();
  }

  Future<List<ItemFila>> todos() async =>
      (await (await db).query('fila', orderBy: 'id DESC')).map(_item).toList();

  // CORREÇÃO 1: Trocado 'e.name' por 'e.toString().split('.').last'
  Future<void> marcar(String chave, Estado e, {String? erro}) async =>
      (await db).update('fila', {'estado': e.toString().split('.').last, 'ultimo_erro': erro}, where: 'chave = ?', whereArgs: [chave]);

  // CORREÇÃO 2: Trocado 'byName' por uma busca segura no enum
  ItemFila _item(Map<String, Object?> r) {
    final estadoStr = r['estado'] as String;
    final estado = Estado.values.firstWhere(
      (e) => e.toString().split('.').last == estadoStr,
      orElse: () => Estado.pendente,
    );
    
    return ItemFila(
      r['chave'] as String,
      jsonDecode(r['payload'] as String),
      estado,
      r['ultimo_erro'] as String?,
    );
  }
}