import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatInputWidget extends StatefulWidget {
  final Function(String) onSendMessage;
  final RxBool isProcessing;

  const ChatInputWidget({
    Key? key,
    required this.onSendMessage,
    required this.isProcessing,
  }) : super(key: key);

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  RxBool hasText = false.obs;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      hasText.value = _textController.text.isNotEmpty;
    });
  }

  void _handleSubmitted() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    widget.onSendMessage(text);
    _textController.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Row(
        children: [
          // Text input field
          Expanded(
            child: Obx(() => TextField(
              controller: _textController,
              focusNode: _focusNode,
              enabled: !widget.isProcessing.value,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: widget.isProcessing.value
                    ? 'Waiting for response...'
                    : 'Ask me anything...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10.0,
                ),
              ),
              minLines: 1,
              maxLines: 5,
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline,
              onSubmitted: (_) {
                if (hasText.value) _handleSubmitted();
              },
            )),
          ),

          // Send button
          Obx(() => IconButton(
            icon: Icon(
              Icons.send_rounded,
              color: hasText.value && !widget.isProcessing.value
                  ? Colors.tealAccent
                  : Colors.grey[600],
            ),
            onPressed: (hasText.value && !widget.isProcessing.value)
                ? _handleSubmitted
                : null,
          )),
        ],
      ),
    );
  }
}
