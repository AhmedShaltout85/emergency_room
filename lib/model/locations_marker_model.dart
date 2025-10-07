class LocationsMarkerModel {
  final int id;
  final String address;
  final double latitude;
  final double longitude;
  final String url;

  LocationsMarkerModel({
    required this.id,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.url,
  });

  factory LocationsMarkerModel.fromJson(Map<String, dynamic> json) {
    return LocationsMarkerModel(
      id: json['id'],
      address: json['address'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'url': url,
    };
  }
}



// class Post {
//   final int userId;
//   final int id;
//   final String title;
//   final String body;
//   Post(
//       {required this.userId,
//       required this.id,
//       required this.title,
//       required this.body});
//   factory Post.fromJson(Map<String, dynamic> json) {
//     return Post(
//       userId: json['userId'],
//       id: json['id'],
//       title: json['title'],
//       body: json['body'],
//     );
//   }
//   Map<String, dynamic> toJson() => {
//         'userId': userId,
//         'id': id,
//         'title': title,
//         'body': body,
//       };
// }

// import 'package:dio/dio.dart';
// import 'package:flutter_api_example/post.dart';  // Import Post model
// class ApiService {
//   static const String baseUrl = 'https://jsonplaceholder.typicode.com'; // Replace with your API endpoint
//   static Future<Post> fetchPost(int postId) async {
//     final dio = Dio();
//     final response = await dio.get('$baseUrl/posts/$postId');
//     if (response.statusCode == 200) {
//       return Post.fromJson(response.data);
//     } else {
//       throw Exception('Failed to fetch post: ${response.statusCode}');
//     }
//   }
//   static Future<void> createPost(Post post) async {
//     final dio = Dio();
//     final response = await dio.post('$baseUrl/posts', data: post.toJson());
//     if (response.statusCode == 201) {
//       print('Post created successfully!');
//     } else {
//       throw Exception('Failed to create post: ${response.statusCode}');
//     }
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:flutter_api_example/api_service.dart';
// import 'package:flutter_api_example/post.dart';
// void main() => runApp(MyApp());
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'API Example',
//       home: MyHomePage(),
//     );
//   }
// }
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key});
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
// class _MyHomePageState extends State<MyHomePage> {
//   Future<Post?> _post;
//   String _errorMessage = '';
//   @override
//   void initState() {
//     super.initState();
//     _fetchData(); // Fetch data on app launch
//   }
//   Future<void> _fetchData() async {
//     setState(() {
//       _errorMessage = ''; // Clear any previous error messages
//       _post = null;         // Reset the post state
//     });
//     try {
//       final post = await ApiService.fetchPost(1); // Assuming post ID is 1
//       setState(() {
//         _post = post;
//       });
//     } on Exception catch (e) {
//       setState(() {
//         _errorMessage = e.toString();
//       });
//       print('Error: $e');
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('API Example'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             if (_post != null)
//             Text('Title: ${_post.title}'),
//             if (_post != null)
//             Text('Body: ${_post.body}'),
//             if (_errorMessage.isNotEmpty)
//               Text(
//                 'Error: $_errorMessage',
//                 style: const TextStyle(color: Colors.red),
//               ),
//             ElevatedButton(
//               onPressed: _fetchData,
//               child: const Text('Fetch Post'),
//             ),
//                     ElevatedButton(
//                       onPressed: () async {
//                         // Example of posting data (replace with your data)
//                         final post = Post(userId: 1, id: 2, title: 'New Post', body: 'Here is a new post');
//                         await ApiService.createPost(post);
//                       }
//              )
//           ],
//         ),
//       ),
//     );
//   }
// }
