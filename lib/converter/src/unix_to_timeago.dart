extension UnixToTimeago on int {
  String timeago() {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(this * 1000);
    Duration difference = DateTime.now().difference(dateTime);
    String timeAgo = '';

    if (difference.inDays > 0) {
      timeAgo =
          '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      timeAgo =
          '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      timeAgo =
          '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      timeAgo = 'just now';
    }

    return timeAgo;
  }
}
