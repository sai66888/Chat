import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final String time;
  final String userImageUrl;
  final bool isSent;

  const ChatBubble({
    Key? key,
    required this.message,
    required this.time,
    required this.userImageUrl,
    required this.isSent
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isSent ? SizedBox() : CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(userImageUrl),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: !isSent? CrossAxisAlignment.start: CrossAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: (!isSent ?Colors.grey.shade200:Colors.blue[200]),
                  ),
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 3, bottom: 3),
                  child: Text(
                    message,
                    style: const TextStyle(fontSize: 16),
                    textAlign: isSent? TextAlign.left :  TextAlign.right,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          !isSent ? SizedBox() : CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(userImageUrl),
          ),
        ],
      ),
    );
  }
}