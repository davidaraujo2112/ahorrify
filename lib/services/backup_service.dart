import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/transaction.dart';

class BackupService {
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return true;
  }

  Future<String> _getBackupDirectory() async {
    if (Platform.isAndroid) {
      final directory = Directory('/storage/emulated/0/Download/Ahorrify');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      return directory.path;
    } else {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }
  }

  Future<String> createBackup(List<Transaction> transactions) async {
    if (!await requestPermissions()) {
      throw Exception('Se requieren permisos para crear el respaldo');
    }

    final backupData = {
      'version': '1.0',
      'timestamp': DateTime.now().toIso8601String(),
      'transactions': transactions.map((t) => t.toJson()).toList(),
    };

    final jsonString = jsonEncode(backupData);
    final directory = await _getBackupDirectory();
    final fileName =
        'ahorrify_backup_${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File('$directory/$fileName');

    await file.writeAsString(jsonString);
    return file.path;
  }

  Future<List<Transaction>> restoreFromBackup() async {
    if (!await requestPermissions()) {
      throw Exception('Se requieren permisos para restaurar el respaldo');
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null) {
      throw Exception('No se seleccionó ningún archivo');
    }

    final file = File(result.files.single.path!);
    final jsonString = await file.readAsString();
    final backupData = jsonDecode(jsonString) as Map<String, dynamic>;

    if (backupData['version'] != '1.0') {
      throw Exception('Versión de respaldo no compatible');
    }

    final transactions = (backupData['transactions'] as List)
        .map((t) => Transaction.fromJson(t as Map<String, dynamic>))
        .toList();

    return transactions;
  }
}
