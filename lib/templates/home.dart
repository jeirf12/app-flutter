import 'package:gallery_saver/gallery_saver.dart';
import 'package:example_flutter/models/options.dart';
import 'package:example_flutter/services/api.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';

ApiService apiService = ApiService();

String title = "Download Videos";

final List<Option> _options = [
  Option('Downloads', Icons.download, (context) => {print("download")}),
  Option(
      'Exit',
      Icons.exit_to_app,
      (context) => {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Exit App"),
                    content: Text("¿Desea salir de la aplicación?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          print("Cancel");
                          Navigator.of(context).pop();
                        },
                        child: Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          print("Si");
                          exit(0);
                        },
                        child: Text("Si"),
                      ),
                    ],
                  );
                })
          }),
];

class Home extends StatelessWidget {
  const Home({super.key});

  void _menuOptions(context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          final _optionsWidget = _options.map(
            (element) {
              return InkWell(
                  onTap: () {
                    element.action(context);
                  },
                  child: ListTile(
                    title: Text(
                      element.name,
                      style: Theme.of(context).textTheme.headline3,
                    ),
                    leading: Icon(
                      element.icon,
                      color: Colors.blue[300],
                    ),
                  ));
            },
          );
          return Scaffold(
            appBar: AppBar(
              title: const Text('Settings'),
            ),
            body: ListView(
              children: _optionsWidget.toList(),
            ),
          );
        },
      ),
    );
  }

  _getCards(BuildContext context) {
    return FutureBuilder(
      future:
          apiService.getAll().then((value) => jsonDecode(value.body)["items"]),
      builder: ((context, snapshot) {
        if (!snapshot.hasData)
          return const Center(
            child: Text("No hay datos"),
          );
        return ListView.builder(
            itemCount: snapshot.hasData ? snapshot.data.length : 0,
            itemBuilder: ((context, index) {
              var data = snapshot.data[index]["snippet"];
              return InkWell(
                onTap: () {
                  return;
                },
                child: Container(
                  // padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Container(
                        height: 320,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(
                                data["thumbnails"]["standard"]["url"]),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      ListTile(
                        leading: CircleAvatar(child: Text(data["title"][0])),
                        title: Text(data["title"]),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              );
            }));
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          onPressed: () {
            _menuOptions(context);
          },
          icon: const Icon(Icons.menu),
        ),
      ),
      body: _getCards(context),
    );
  }
}
