class Message {
  final String id;
  final String content;
  final String sender; // 'user' or 'assistant'
  final DateTime timestamp;
  final String? conversationId;

  Message({
    required this.id,
    required this.content,
    required this.sender,
    required this.timestamp,
    this.conversationId,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'] ?? json['id'] ?? '',
      content: (json['message'] ?? json['content'] ?? ''),
      sender: json['sender'] ?? 'assistant',
      timestamp: json['timestamp'] != null || json['createdAt'] != null
          ? DateTime.parse(json['timestamp'] ?? json['createdAt'])
          : DateTime.now(),
      conversationId: json['conversationId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'sender': sender,
      'timestamp': timestamp.toIso8601String(),
      'conversationId': conversationId,
    };
  }
}
