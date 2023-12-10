class Post {
  final String title;
  final String description;
  final String createdate;
  final int postId;
  Post({
    required this.title,
    required this.description,
    required this.createdate,
    required this.postId,
  });
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      title: json['title'],
      description: json['description'],
      createdate: json['createDate'],
      postId: json['id'],
    );
  }
}