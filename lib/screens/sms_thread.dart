import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../models/sms.dart';
import '../services/sms_api_service.dart';

class SMSThread extends StatefulWidget {
  final Map<String, List<SMS>> smsGrouped;
  final String originatingAddress;
  final void Function() callback;

  const SMSThread(
      {super.key,
      required this.smsGrouped,
      required this.originatingAddress,
      required this.callback});

  @override
  SMSThreadState createState() => SMSThreadState();
}

class SMSThreadState extends State<SMSThread> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      final double maxScroll = _scrollController.position.maxScrollExtent;
      final double viewportHeight =
          _scrollController.position.viewportDimension;

      if (_scrollController.position.pixels < maxScroll) {
        _scrollController.jumpTo(maxScroll + viewportHeight + 147);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back,
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Text(
              widget.originatingAddress,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.0),
            child: Container(
              height: 1.0,
              color: Colors.grey,
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    widget.callback();
                  });
                },
                child: widget.smsGrouped[widget.originatingAddress]!.isEmpty
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: widget
                            .smsGrouped[widget.originatingAddress]!.length,
                        itemBuilder: (context, index) {
                          SMS msg = widget
                              .smsGrouped[widget.originatingAddress]![index];
                          bool isSent = msg.type == "SENT";
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(
                              alignment: isSent
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: isSent
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: SelectableText(
                                      msg.contents,
                                      style: const TextStyle(fontSize: 16),
                                      textAlign: isSent
                                          ? TextAlign.right
                                          : TextAlign.left,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${msg.date} ${msg.time}',
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                    textAlign: isSent
                                        ? TextAlign.right
                                        : TextAlign.left,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: ListTile(
                  contentPadding: EdgeInsets.fromLTRB(12.0, 2.0, 2.0, 4.0),
                  title: TextField(
                    controller: _textController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  trailing: IconButton(
                      onPressed: () {
                        setState(() {
                          final newMsg = SMS(
                            destinationAddress: widget.originatingAddress,
                            type: "SENT",
                            contents: _textController.text,
                            date:
                                "", // server handles this for now but will need for local db
                            time: "", // """"
                          );
                          postNewSMS(newMsg, widget.callback);
                          _textController.clear();
                          FocusScope.of(context).unfocus();
                        });
                        _scrollToBottom();
                      },
                      icon: Icon(Icons.send)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
