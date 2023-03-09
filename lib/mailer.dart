import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'custom_snackbar.dart';

class MailerSender extends StatefulWidget {
  const MailerSender({super.key});

  @override
  State<MailerSender> createState() => _MailerSenderState();
}

class _MailerSenderState extends State<MailerSender> {
  String subject = "";
  String body = "";
  bool _isSending = false;
  void _onPressed() {
    setState(() {
      subject = _subject.text;
      body = _message.text;
      _isSending = true;
    });
  }

  void _onClose() {
    _isSending = false;
    Navigator.pop(context);
    _message.clear();
    _subject.clear();
  }

  final TextEditingController _recipent = TextEditingController();
  final TextEditingController _subject = TextEditingController();
  final TextEditingController _message = TextEditingController();
  List<String> _emails = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mail Sender"),
      ),
      body: _isSending
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    TextField(
                      onChanged: (text) {
                        _emails = text
                            .split(";")
                            .map((email) => email.trim())
                            .toList();
                      },
                      controller: _recipent,
                      decoration: const InputDecoration(
                          hintText: "Email", border: OutlineInputBorder()),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    TextField(
                      controller: _subject,
                      decoration: const InputDecoration(
                          hintText: "Subject", border: OutlineInputBorder()),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _message,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: const InputDecoration(
                            hintText: 'Body', border: OutlineInputBorder()),
                      ),
                    ),
                    ElevatedButton(
                        onPressed: () {
                          _onPressed();
                          sendEmail();
                          _emails = _recipent.text
                              .split(";")
                              .map((email) => email.trim())
                              .toList();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text("Send"),
                            SizedBox(
                              width: 20,
                            ),
                            Icon(Icons.send)
                          ],
                        )),
                  ],
                ),
              ),
            ),
    );
  }

  sendEmail() async {
    String username = 'email';
    String password = 'password';

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'Mail Demo')
      ..recipients = _emails
      ..subject = subject
      ..text = body;

    try {
      final sendReport = await send(message, smtpServer);

      // ignore: use_build_context_synchronously
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Email send successfully!'),
              content: const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
              ),
              actions: [
                TextButton(
                  onPressed: _onClose,
                  child: const Text('OK'),
                ),
              ],
            );
          });
    } on MailerException catch (e) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Email not sent!'),
              content: const Icon(
                Icons.close,
                color: Colors.red,
              ),
              actions: [
                TextButton(
                  onPressed: _onClose,
                  child: const Text('OK'),
                ),
              ],
            );
          });
      for (var p in e.problems) {
        _isSending = false;
        ScaffoldMessenger.of(context).showSnackBar(
            getMySnackbar(context, 'Problem: ${p.code}: ${p.msg}'));
      }
    }
  }
}
