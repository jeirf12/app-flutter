import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup Name Generator',
      theme: ThemeData(
          appBarTheme: const AppBarTheme(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      )),
      home: RandomWords(),
    );
  }
}

class RandomWords extends StatefulWidget {
  const RandomWords({super.key});

  @override
  State<RandomWords> createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final _saved = <WordPair>{};
  final _biggerFont = const TextStyle(fontSize: 18);

  void _pushSaved() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      final tiles = _saved.map((pair) {
        return ListTile(
          title: Text(
            pair.asPascalCase,
            style: _biggerFont,
          ),
        );
      });
      final divided = tiles.isNotEmpty
          ? ListTile.divideTiles(tiles: tiles, context: context).toList()
          : <Widget>[];
      return Scaffold(
        appBar: AppBar(
          title: const Text('Saved Suggestions'),
        ),
        body: ListView(children: divided),
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Startup Name Generator"),
          actions: [
            IconButton(
              onPressed: _pushSaved,
              icon: const Icon(Icons.list),
              tooltip: 'Saved Suggestions',
            )
          ],
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemBuilder: (context, index) {
            if (index.isOdd) return const Divider();
            final index2 = index ~/ 2;
            if (index2 >= _suggestions.length)
              _suggestions.addAll(generateWordPairs().take(10));
            final alreadySaved = _saved.contains(_suggestions[index2]);
            return ListTile(
              title: Text(
                _suggestions[index2].asPascalCase,
                style: _biggerFont,
              ),
              trailing: Icon(
                alreadySaved ? Icons.favorite : Icons.favorite_border,
                color: alreadySaved ? Colors.red : null,
                semanticLabel: alreadySaved ? 'Remove from saved' : 'Save',
              ),
              onTap: () {
                setState(() {
                  if (alreadySaved)
                    _saved.remove(_suggestions[index2]);
                  else
                    _saved.add(_suggestions[index2]);
                });
              },
            );
          },
        ));
  }
}
