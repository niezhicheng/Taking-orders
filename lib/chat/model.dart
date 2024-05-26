import 'package:intl/intl.dart';

class MessageM {
  int? id;
  int sender;
  int userid;
  int receiver;
  int? clientId;
  int messageType;
  String? context;
  String? voiceUrl;
  String? imageUrl;
  String? fileUrl;
  int seq;
  int? status;
  String? fileType;
  int? imageWidth;
  int? imageHeight;
  int? voiceDuration;
  String? createdAt;

  MessageM({
    this.id,
    required this.sender,
    required this.userid,
    required this.receiver,
    this.clientId,
    required this.messageType,
    this.context,
    this.voiceUrl,
    this.imageUrl,
    this.fileUrl,
    required this.seq,
    this.status,
    this.fileType,
    this.imageWidth,
    this.imageHeight,
    this.voiceDuration,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    var formattedDateTime = formatter.format(now).toString();
    // print(formattedDateTime.toString());
    return {
      'id': id,
      'user_id': userid,
      'sender': sender,
      'receiver': receiver,
      'client_id': clientId,
      'message_type': messageType,
      'context': context,
      'voice_url': voiceUrl,
      'image_url': imageUrl,
      'file_url': fileUrl,
      'seq': seq,
      'status': status,
      'file_type': fileType,
      'image_width': imageWidth,
      'image_height': imageHeight,
      'voice_duration': voiceDuration,
      'created_at': formattedDateTime,
    };
  }

  factory MessageM.fromMap(Map<String, dynamic> map) {
    print(map);
    var formattedDateTime = "";
    if (map['CreatedAt'] != null) {
      final parsedDateTime = DateTime.parse(map['CreatedAt']);
      final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
      var formattedDat = formatter.format(parsedDateTime);
      formattedDateTime = formattedDat;
      // print(formattedDateTime.toString());
    }

    return MessageM(
      id: map['id'],
      userid: map['sender'],
      sender: map['sender'],
      receiver: map['receiver'],
      clientId: map['client_id'],
      messageType: map['message_type'],
      context: map['context'],
      voiceUrl: map['voice_url'],
      imageUrl: map['image_url'],
      fileUrl: map['file_url'],
      seq: map['seq'],
      status: map['status'],
      fileType: map['file_type'],
      imageWidth: map['image_width'],
      imageHeight: map['image_height'],
      voiceDuration: map['voice_duration'],
      createdAt: formattedDateTime,
    );
  }

  static MessageM ConvertToMessageM(dynamic item) {
    return MessageM.fromMap(item);
  }
}
