import 'package:flutter/material.dart';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // setup the URL for your API here
  Future<List<dynamic>> fetchItems() async {
    final response = await http
      .get(Uri.parse('https://www.themealdb.com/api/json/v1/1/search.php?f=a'));

    if (response.statusCode == 200) {
      return json.decode(response.body)['meals'];
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Unit 7 - API Calls | Meals"),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchItems(),
        builder: (context, snapshot) {
          // Consider 3 cases here
          // when the process is ongoing
          // return CircularProgressIndicator();
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // when the process is completed:
          if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            final items = snapshot.data!;
          // successful
          // Use the library here
            return ExpandedTileList.builder(
                itemCount: items.length,
                itemBuilder: (context, index, con) {
                  final item = items[index];
                  final tileController = ExpandedTileController();

                  return ExpandedTile(
                    controller: tileController,
                    title: Text(
                      item['strMeal'] ?? 'No Title',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    leading: item['strMealThumb'] != null
                        ? Image.network(
                          item['strMealThumb'], 
                          width: 200, 
                          height: 200,
                        )
                        : const Icon(Icons.image),
                    content: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Text("Category: ${item['strCategory'] ?? 'No Category'}"),
                          const SizedBox(height: 10),
                          Text("Instructions: ${item['strInstructions'] ?? 'No Instructions'}"),
                        ]
                      ),
                    ),
                  );
                },
              );
            }
            // error
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
          }
          return const Center(child: Text("No data found"));
        },
      ),
    );
  }
}