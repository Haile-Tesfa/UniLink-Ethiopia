class Post {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String content;
  final String? imageUrl;
  final int likeCount;
  final int commentCount;
  final DateTime createdAt;
  final bool isLiked;
  final bool isSaved;

  const Post({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.content,
    this.imageUrl,
    required this.likeCount,
    required this.commentCount,
    required this.createdAt,
    this.isLiked = false,
    this.isSaved = false,
  });
}