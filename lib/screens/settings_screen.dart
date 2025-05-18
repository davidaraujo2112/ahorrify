import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        centerTitle: true,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return ListView(
            children: [
              _buildSection(
                title: 'Apariencia',
                children: [
                  _buildThemeSelector(settings),
                ],
              ),
              _buildSection(
                title: 'Moneda',
                children: [
                  _buildCurrencySelector(settings),
                ],
              ),
              _buildSection(
                title: 'Idioma',
                children: [
                  _buildLanguageSelector(settings),
                ],
              ),
              _buildSection(
                title: 'Datos',
                children: [
                  _buildBackupOptions(context),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }

  Widget _buildThemeSelector(SettingsProvider settings) {
    return ListTile(
      title: const Text('Tema'),
      subtitle: Text(_getThemeLabel(settings.theme)),
      trailing: DropdownButton<String>(
        value: settings.theme,
        items: const [
          DropdownMenuItem(
            value: 'system',
            child: Text('Sistema'),
          ),
          DropdownMenuItem(
            value: 'light',
            child: Text('Claro'),
          ),
          DropdownMenuItem(
            value: 'dark',
            child: Text('Oscuro'),
          ),
        ],
        onChanged: (value) {
          if (value != null) {
            settings.setTheme(value);
          }
        },
      ),
    );
  }

  Widget _buildCurrencySelector(SettingsProvider settings) {
    return ListTile(
      title: Text('Moneda actual: ${settings.currency}'),
      trailing: DropdownButton<String>(
        value: settings.currency,
        items: const [
          DropdownMenuItem(
            value: 'USD',
            child: Text('Dólar (\$)'),
          ),
          DropdownMenuItem(
            value: 'EUR',
            child: Text('Euro (€)'),
          ),
          DropdownMenuItem(
            value: 'SVC',
            child: Text('Colón (₡)'),
          ),
          DropdownMenuItem(
            value: 'MXN',
            child: Text('Peso Mexicano (MXN)'),
          ),
        ],
        onChanged: (value) {
          if (value != null) {
            settings.setCurrency(value);
          }
        },
      ),
    );
  }

  Widget _buildLanguageSelector(SettingsProvider settings) {
    return ListTile(
      title: Text(
          'Idioma actual: ${settings.language == 'es' ? 'Español' : 'Inglés'}'),
      trailing: DropdownButton<String>(
        value: settings.language,
        items: const [
          DropdownMenuItem(
            value: 'es',
            child: Text('Español'),
          ),
          DropdownMenuItem(
            value: 'en',
            child: Text('English'),
          ),
        ],
        onChanged: (value) {
          if (value != null) {
            settings.setLanguage(value);
          }
        },
      ),
    );
  }

  Widget _buildBackupOptions(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.backup),
          title: const Text('Crear Respaldo'),
          subtitle: const Text('Guarda tus datos en un archivo'),
          onTap: () => _createBackup(context),
        ),
        ListTile(
          leading: const Icon(Icons.restore),
          title: const Text('Restaurar Respaldo'),
          subtitle: const Text('Recupera tus datos desde un archivo'),
          onTap: () => _restoreBackup(context),
        ),
      ],
    );
  }

  Future<void> _createBackup(BuildContext context) async {
    try {
      final provider = Provider.of<TransactionProvider>(context, listen: false);
      final path = await provider.createBackup();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Respaldo creado en: $path'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear respaldo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _restoreBackup(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurar Respaldo'),
        content: const Text(
          '¿Estás seguro de que deseas restaurar el respaldo? '
          'Esta acción reemplazará todos los datos actuales.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final provider =
            Provider.of<TransactionProvider>(context, listen: false);
        await provider.restoreFromBackup();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Respaldo restaurado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al restaurar respaldo: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String _getThemeLabel(String theme) {
    switch (theme) {
      case 'light':
        return 'Claro';
      case 'dark':
        return 'Oscuro';
      case 'system':
      default:
        return 'Sistema';
    }
  }
}
