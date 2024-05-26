class Session {
  int? id;
  int? userId;
  int? sender;
  int? contactId;
  String? lastMessage;
  int? messageType;
  int? lastSender;
  int? lastSentAt;
  int? unreadCount;
  bool? isGroupChat;
  String? groupChatName;
  bool? deleteNot;
  int? seq;

  Session({
    this.id,
    this.userId,
    this.sender,
    this.contactId,
    this.lastMessage,
    this.messageType,
    this.lastSender,
    this.lastSentAt,
    this.unreadCount,
    this.isGroupChat,
    this.groupChatName,
    this.deleteNot,
    this.seq,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'sender': sender,
      'contact_id': contactId,
      'last_message': lastMessage,
      'message_type': messageType,
      'last_sender': lastSender,
      'last_sent_at': lastSentAt,
      'unread_count': unreadCount,
      'is_group_chat': isGroupChat,
      'group_chat_name': groupChatName,
      'delete_not': deleteNot,
      'seq': seq,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'sender': sender,
      'contact_id': contactId,
      'last_message': lastMessage,
      'message_type': messageType,
      'last_sender': lastSender,
      'last_sent_at': lastSentAt,
      'unread_count': unreadCount,
      'is_group_chat': isGroupChat,
      'group_chat_name': groupChatName,
      'delete_not': deleteNot,
      'seq': seq,
    };
  }

  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      id: map['id'],
      userId: map['user_id'],
      sender: map['user_id'],
      contactId: map['contact_id'],
      lastMessage: map['last_message'],
      messageType: map['message_type'],
      lastSender: map['last_sender'],
      lastSentAt: map['last_sent_at'],
      unreadCount: map['unread_count'],
      isGroupChat: map['is_group_chat'],
      groupChatName: map['group_chat_name'],
      deleteNot: map['delete_not'],
      seq: map['seq'],
    );
  }

  factory Session.fromMapSession(Map<String, dynamic> map) {
    return Session(
      id: map['id'],
      userId: map['user_id'],
      sender: map['sender'],
      contactId: map['contact_id'],
      lastMessage: map['last_message'],
      messageType: map['message_type'],
      lastSender: map['last_sender'],
      lastSentAt: map['last_sent_at'],
      unreadCount: map['unread_count'],
      isGroupChat: map['is_group_chat'],
      groupChatName: map['group_chat_name'],
      deleteNot: map['delete_not'],
      seq: map['seq'],
    );
  }
}
