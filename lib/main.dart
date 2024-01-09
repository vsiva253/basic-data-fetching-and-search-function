import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> apiData = [];
  List<Map<String, dynamic>> filteredData = [];
  bool isLoading = true;

  Future<void> _fetchData() async {
    try {
      final Uri uri = Uri.parse('https://retoolapi.dev/2zNmJf/Bavdata');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic>? data =
            json.decode(response.body) as List<dynamic>?;
        if (data != null) {
          setState(() {
            apiData = data.cast<Map<String, dynamic>>();
            filteredData = List.from(apiData);
            isLoading = false;
          });
        }
        print(apiData);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching data'),
            backgroundColor: Colors.red,
          ),
        );
        print('Error: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Exception during data fetching: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterData(String query) {
    setState(() {
      filteredData = apiData
          .where((element) =>
              element['id'].toString().contains(query) ||
              element['Column 1'].toString().toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Flutter Demo Home Page',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: TextField(
              controller: searchController,
              onChanged: (query) {
                filterData(query);
              },
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          filterData('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredData.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 2,
                        child: ListTile(
                          title: Text('ID: ${filteredData[index]['id']}'),
                          subtitle: Text(filteredData[index]['Column 1']),
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}
