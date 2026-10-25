class ChatMessageModel {
  final String text;
  final bool isUser; // true = user ne bheja, false = AI ka jawab

  ChatMessageModel({required this.text, required this.isUser});
}
