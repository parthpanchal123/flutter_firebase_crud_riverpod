import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_demo_firebase/models/Movie.dart';
import 'package:riverpod_demo_firebase/providers/DatabaseProvider.dart';

class AddMovie extends StatefulWidget {
  bool isFromEdit;
  String documentId;
  Map<String, dynamic> movie;

  AddMovie({this.isFromEdit, this.movie, this.documentId});
  @override
  _AddMovieState createState() => _AddMovieState();
}

class _AddMovieState extends State<AddMovie> {
  final _formKey = GlobalKey<FormState>();
  String _name = '', _posterURL = '', _length = '', _error = '';
  bool _isLoading = false;
  static GlobalKey<ScaffoldState> _keyScaffold = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: widget.isFromEdit ? Text('Edit a movie') : Text('Add a movie'),
        ),
        key: _keyScaffold,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Movie name',
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Name can be empty !';
                        }
                        return null;
                      },
                      initialValue:
                          widget.isFromEdit ? widget.movie['name'] : '',
                      onChanged: (val) {
                        _name = val;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Movie poster url',
                      ),
                      onChanged: (val) {
                        _posterURL = val;
                      },
                      initialValue:
                          widget.isFromEdit ? widget.movie['poster'] : '',
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Movie length',
                      ),
                      onChanged: (val) {
                        _length = val;
                      },
                      initialValue:
                          widget.isFromEdit ? widget.movie['length'] : '',
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RaisedButton.icon(
                        icon: Icon(widget.isFromEdit ? Icons.edit : Icons.add),
                        label: widget.isFromEdit ? Text('Edit') : Text('Add'),
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            final response = context.read(databaseProvider);
                            setState(() {
                              _isLoading = true;
                            });

                            try {
                              if (!widget.isFromEdit) {
                                Movie _m =
                                    new Movie(_name, _posterURL, _length);

                                await response.addNewMovie(_m);
                                setState(() {
                                  _isLoading = false;
                                  _error = '';
                                });
                              } else {
                                _name =
                                    _name != '' ? _name : widget.movie['name'];
                                _posterURL = _posterURL != ''
                                    ? _posterURL
                                    : widget.movie['poster'];
                                _length = _length != ''
                                    ? _length
                                    : widget.movie['length'];
                                Movie _m =
                                    new Movie(_name, _posterURL, _length);

                                await response.editMovie(_m, widget.documentId);
                                setState(() {
                                  _isLoading = false;
                                  _error = '';
                                });
                              }
                              final successSnackbar = SnackBar(
                                content: Text(widget.isFromEdit
                                    ? 'Edited Successfully !'
                                    : 'Added Successfully !'),
                                duration: Duration(seconds: 2),
                              );
                              _keyScaffold.currentState
                                  .showSnackBar(successSnackbar)
                                  .closed
                                  .then((data) => {Navigator.pop(context)});
                            } catch (e) {
                              setState(() {
                                _isLoading = false;
                                _error = e.message;
                              });
                              final failureSnackbar =
                                  SnackBar(content: Text('Error : $_error'));
                              _keyScaffold.currentState
                                  .showSnackBar(failureSnackbar);
                            }

                            setState(() {
                              _isLoading = false;
                            });
                          }
                        },
                      ),
                    ),
                    _isLoading ? CircularProgressIndicator() : Container(),
                    _error == ''
                        ? Text('')
                        : Text(
                            _error,
                            style: TextStyle(color: Colors.red),
                          ),
                  ],
                ),
              ),
            )
          ],
        ));
  }
}

