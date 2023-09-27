import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:todo_app/models/item.dart';
import 'package:todo_app/screens/add_item.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDo Firebase',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
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
  List<Item> items = [];
  final url = Uri.https(
    'iuhgvb-775c0-default-rtdb.asia-southeast1.firebasedatabase.app',
    'todos.json',
  );

  bool isLoading = false;

  _deleteItem(Item item) async {
    final url = Uri.https(
      'iuhgvb-775c0-default-rtdb.asia-southeast1.firebasedatabase.app',
      'todos/${item.id}.json',
    );
    try {
      await http.delete(url);
      items.remove(item);
    } catch (err) {
      print(err);
    }
  }

  _loadItems() async {
    try {
      var response = await http.get(url);
      if (response.body == 'null') {
        setState(() {
          items = [];
          return;
        });
      }
      Map<String, dynamic> res = json.decode(response.body);
      // print(res);
      List<Item> ls = [];
      for (var item in res.entries) {
        ls.add(Item(item.value["name"], item.value["qty"], item.key));
      }
      setState(() {
        items = ls;
      });
    } catch (err) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error Occured')),
        );
      }
    }
  }

  @override
  void initState() {
    _loadItems();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Tasks'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Item item = await Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) {
              return const AddItemScreen();
            }),
          );
          setState(() {
            items.add(item);
          });
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          if (isLoading) const LinearProgressIndicator(),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (ctx, index) {
                Item item = items[index];
                return Dismissible(
                  key: ValueKey(item.id),
                  background: Container(
                    color: Colors.red,
                    child: const Row(
                      children: [
                        SizedBox(width: 16),
                        Icon(Icons.delete),
                      ],
                    ),
                  ),
                  child: ListTile(
                    title: Text(item.name),
                    trailing: Text(item.qty.toString()),
                  ),
                  onDismissed: (direction) {
                    _deleteItem(item);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
