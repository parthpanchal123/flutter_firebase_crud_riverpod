import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_demo_firebase/pages/AddMovie.dart';
import 'package:riverpod_demo_firebase/providers/DatabaseProvider.dart';

class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final database = context.read(databaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Riverpod Firebase Demo'),
      ),
      body: Center(
          child: StreamBuilder(
        stream: database.allMovies,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.error != null) {
            return Center(child: Text('Some error occurred'));
          }
          return MovieList(snapshot.data.docs);
        },
      )),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddMovie(
                      isFromEdit: false,
                    )),
          );
        },
      ),
    );
  }
}

class MovieList extends StatelessWidget {
  List<QueryDocumentSnapshot> _movieList;
  MovieList(this._movieList);

  @override
  Widget build(BuildContext context) {
    final database = context.read(databaseProvider);
    return _movieList.length != 0
        ? ListView.separated(
            itemCount: _movieList.length,
            separatorBuilder: (BuildContext context, int index) => Divider(),
            itemBuilder: (BuildContext context, int index) {
              final _currentMovie = _movieList[index].data();
              return Dismissible(
                onDismissed: (_) async {
                  await database.removeMovie(_movieList[index].id).then((res) {
                    if (res) {
                    } else {}
                  });
                },
                key: Key(_movieList[index].id),
                child: ListTile(
                    leading: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.network(_currentMovie['poster']),
                    ),
                    title: Text(
                      _currentMovie['name'],
                    ),
                    subtitle: Text(_currentMovie['length']),
                    trailing: IconButton(
                      icon: Icon(Icons.edit_outlined),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddMovie(
                                    isFromEdit: true,
                                    movie: _currentMovie,
                                    documentId: _movieList[index].id,
                                  )),
                        );
                      },
                    )),
              );
            })
        : Center(child: Text('No Movies yet'));
  }
}
