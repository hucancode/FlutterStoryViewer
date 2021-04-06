import 'package:enough_mail/enough_mail.dart';

class AtPopAdapter {
  final server = 'mail.atpop.info';

  static Future<ImapClient> login({required String userName, required String password}) async {
    final client = ImapClient(isLogEnabled: false);
    try {
      await client.connectToServer('mail.atpop.info', 993, isSecure: true);
      await client.login(userName, password);
    } on ImapException catch (e) {
      print('IMAP failed with $e');
    }
    return client;
  }

  static Future<List<MimeMessage>> fetch(
      {required ImapClient client, int maxResult = 5}) async {
    final mailboxes = await client.listMailboxes();
    print('mailboxes: $mailboxes');
    await client.selectInbox();
    // fetch 10 most recent messages:
    final fetchResult = await client.fetchRecentMessages(
        messageCount: maxResult, criteria: 'BODY.PEEK[]');
    return fetchResult.messages;
  }

  static Future<void> logout({required ImapClient client}) async {
    await client.logout();
  }
}
