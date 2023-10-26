import 'package:http/http.dart' as http;
import 'dart:convert';

class News {
  final int id;
  final String title;
  final String image;
  final String description;

  News({
    required this.id,
    required this.title,
    required this.image,
    required this.description,
  });
}

Future<void> loadNews() async {
  final url = 'http://192.168.76.55:5000/news';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);

      List<News> newsList = data.map((json) => News(
        id: json['id'],
        title: json['title'],
        image: json['image'],
        description: json['description'],
      )).toList();

      // Здесь вы можете присвоить данные переменной или состоянию вашего виджета, как вам нужно.
      
    } else {
      print('Ошибка при загрузке новостей');
    }
  } catch (e) {
    print('Ошибка при загрузке новостей: $e');
  }
}

