import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/message.dart';

class ChatMessageWidget extends StatelessWidget {
  final Message message;

  const ChatMessageWidget({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == 'user';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          // Message content with flexible width
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Message bubble
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: isUser
                      ? Text(
                          message.content,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        )
                      : FormattedMessageContent(content: message.content),
                ),

                // Action buttons
                if (!isUser)
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(
                        Icons.content_copy,
                        size: 18,
                        color: Colors.grey[600],
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: message.content));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Message copied to clipboard'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      tooltip: 'Copy to clipboard',
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FormattedMessageContent extends StatelessWidget {
  final String content;

  const FormattedMessageContent({
    Key? key,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Parse the content to find formatted elements
    final List<Widget> formattedWidgets = [];

    // Split content by formatted elements
    // We'll process the content sequentially looking for our special tags
    String remainingContent = content;

    // Prevent infinite loops with a safety counter
    int safetyCounter = 0;
    final int maxIterations = 1000; // Reasonable limit to prevent freezing

    while (remainingContent.isNotEmpty && safetyCounter < maxIterations) {
      safetyCounter++;

      // Check for code blocks first (they're the most complex)
      final codeBlockMatch =
          RegExp(r'<code language="([^"]*)">([^<]*)</code>').firstMatch(
              remainingContent);

      if (codeBlockMatch != null && codeBlockMatch.start == 0) {
        // We found a code block at the start of the remaining content
        final language = codeBlockMatch.group(1) ?? '';
        final code = _unescapeHtml(codeBlockMatch.group(2) ?? '');

        formattedWidgets.add(_buildCodeBlock(code, language));
        remainingContent = remainingContent.substring(codeBlockMatch.end);
        continue;
      }

      // Check for inline code
      final inlineCodeMatch =
          RegExp(r'<code-inline>([^<]*)</code-inline>').firstMatch(
              remainingContent);

      if (inlineCodeMatch != null && inlineCodeMatch.start == 0) {
        // We found inline code at the start
        final code = _unescapeHtml(inlineCodeMatch.group(1) ?? '');

        formattedWidgets.add(_buildInlineCode(code));
        remainingContent = remainingContent.substring(inlineCodeMatch.end);
        continue;
      }

      // Check for bold text
      final boldMatch = RegExp(r'<bold>([^<]*)</bold>').firstMatch(
          remainingContent);

      if (boldMatch != null && boldMatch.start == 0) {
        // We found bold text at the start
        final text = boldMatch.group(1) ?? '';

        formattedWidgets.add(_buildBoldText(text));
        remainingContent = remainingContent.substring(boldMatch.end);
        continue;
      }

      // Check for links
      final linkMatch = RegExp(r'<link url="([^"]*)">([^<]*)</link>').firstMatch(
          remainingContent);

      if (linkMatch != null && linkMatch.start == 0) {
        // We found a link at the start
        final url = linkMatch.group(1) ?? '';
        final text = linkMatch.group(2) ?? '';

        formattedWidgets.add(_buildLink(text, url, context));
        remainingContent = remainingContent.substring(linkMatch.end);
        continue;
      }

      // If we get here, we didn't find any formatted content at the start
      // So we'll look for the next formatted element
      final nextFormatStart = _findNextFormatIndex(remainingContent);

      if (nextFormatStart > 0) {
        // There's regular text before the next format
        final plainText = remainingContent.substring(0, nextFormatStart);
        formattedWidgets.add(_buildPlainText(plainText));
        remainingContent = remainingContent.substring(nextFormatStart);
      } else if (nextFormatStart == -1) {
        // No more formatted content, just add the rest as plain text
        formattedWidgets.add(_buildPlainText(remainingContent));
        break;
      } else if (nextFormatStart == 0) {
        // We found a format tag but couldn't parse it correctly
        // Skip the first character to avoid infinite loop
        if (remainingContent.length > 1) {
          formattedWidgets.add(_buildPlainText(remainingContent.substring(0, 1)));
          remainingContent = remainingContent.substring(1);
        } else {
          break; // Avoid infinite loop with single character
        }
      }
    }

    // If we hit the safety limit, add any remaining content as plain text
    if (safetyCounter >= maxIterations && remainingContent.isNotEmpty) {
      formattedWidgets.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Error: Message parsing was interrupted due to complexity. Some content may not be displayed correctly.",
            style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold),
          ),
        )
      );
      formattedWidgets.add(_buildPlainText(remainingContent));
    }

    // Return the widgets in a scrollable column
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: formattedWidgets,
      ),
    );
  }

  // Find the index of the next formatted element
  int _findNextFormatIndex(String content) {
    final formats = [
      '<code language="',
      '<code-inline>',
      '<bold>',
      '<link url="',
    ];

    int earliestIndex = -1;

    for (final format in formats) {
      final index = content.indexOf(format);
      if (index != -1 && (earliestIndex == -1 || index < earliestIndex)) {
        earliestIndex = index;
      }
    }

    return earliestIndex;
  }

  // Build widgets for different formatted elements
  Widget _buildPlainText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildCodeBlock(String code, String language) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Language indicator (if available)
          if (language.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    language,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 12.0,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.copy, size: 16.0, color: Colors.grey[700]),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: code));
                    },
                    tooltip: 'Copy code',
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),

          // Code content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SelectableText(
                code,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.blue,
                  fontSize: 14.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineCode(String code) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2.0),
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(
        code,
        style: const TextStyle(
          fontFamily: 'monospace',
          color: Colors.blue,
          fontSize: 14.0,
        ),
      ),
    );
  }

  Widget _buildBoldText(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.black87,
        fontWeight: FontWeight.bold,
        fontSize: 15,
      ),
    );
  }

  Widget _buildLink(String text, String url, BuildContext context) {
    return InkWell(
      onTap: () {
        // Open URL (You may want to use url_launcher package)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening link: $url'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
          fontSize: 15,
        ),
      ),
    );
  }

  // Helper method to unescape HTML entities
  String _unescapeHtml(String text) {
    return text
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'")
        .replaceAll('&amp;', '&');
  }
}
