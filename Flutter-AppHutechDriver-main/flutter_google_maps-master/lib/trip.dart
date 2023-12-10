class Trip {
  final String startLocation;
  final String endLocation;
  final String timeBook;
  final double price;
  final String status;
  final int? driverId;
  final int userId;
  final int tripId;
  Trip({
    required this.startLocation,
    required this.endLocation,
    required this.timeBook,
    required this.price,
    required this.status,
    required this.userId,
    this.driverId,
    required this.tripId,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      startLocation: json['startLocation'],
      endLocation: json['endLocation'],
      timeBook: json['timeBook'],
      price: json['price'],
      status: json['status'],
      userId: json['userId'],
      driverId: json['driverId'],
      tripId: json['id'],
    );
  }
}