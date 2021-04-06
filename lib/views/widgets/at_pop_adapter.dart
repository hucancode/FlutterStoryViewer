// @dart=2.9
import 'package:enough_mail/enough_mail.dart';

class AtPopAdapter {
  final server = 'mail.atpop.info';

  static Future<ImapClient> login({String userName, String password}) async {
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
      {ImapClient client, int maxResult}) async {
    final mailboxes = await client.listMailboxes();
    print('mailboxes: $mailboxes');
    await client.selectInbox();
    // fetch 10 most recent messages:
    final fetchResult = await client.fetchRecentMessages(
        messageCount: maxResult, criteria: 'BODY.PEEK[]');
    return fetchResult.messages;
  }

  static Future<void> logout({ImapClient client}) async {
    await client.logout();
  }
}
