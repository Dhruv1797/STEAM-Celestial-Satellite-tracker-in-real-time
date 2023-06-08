// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:get_it/get_it.dart';
import 'package:ssh2/ssh2.dart';

import '../models/ssh_entity.dart';
import 'lg_settings_service.dart';

/// Service that deals with the SSH management.
class SSHService {
  LGSettingsService get _settingsService => GetIt.I<LGSettingsService>();

  /// Property that defines the SSH client instance.
  late SSHClient _client;

  /// Property that defines the SSH client instance.
  SSHClient get client => _client;

  /// Sets a client with the given [ssh] info.
  void setClient(SSHEntity ssh) {
    _client = SSHClient(
      host: ssh.host,
      port: ssh.port,
      username: ssh.username,
      passwordOrKey: ssh.passwordOrKey,
    );
  }

  void init() {
    final settings = _settingsService.getSettings();
    setClient(SSHEntity(
      username: settings.username,
      host: settings.ip,
      passwordOrKey: settings.password,
      port: settings.port,
    ));
  }

  /// Connects to the current client, executes a command into it and then disconnects.
  Future<String?> execute(String command) async {
    String? result = await connect();

    String? execResult;

    if (result == 'session_connected') {
      execResult = await _client.execute(command);
    }

    await disconnect();
    return execResult;
  }

  /// Connects to a machine using the current client.
  Future<String?> connect() async {
    return _client.connect();
  }

  /// Disconnects from the a machine using the current client.
  Future<SSHClient> disconnect() async {
    await _client.disconnect();
    return _client;
  }

  /// Connects to the current client through SFTP, uploads a file into it and then disconnects.
  Future<void> upload(String filePath) async {
    await connect();
    String? result = await _client.connectSFTP();

    if (result == 'sftp_connected') {
      await _client.sftpUpload(
          path: filePath,
          toPath: '/var/www/html',
          callback: (progress) {
            print('Sent $progress');
          });
    }
  }
}