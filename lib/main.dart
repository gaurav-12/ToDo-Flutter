import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() {
  runApp(MaterialApp(
    title: "Todo App",
    home: App(),
  ));
}

class ToDoListItem extends StatefulWidget {
  String todoText;
  bool todoCheck;
  TextEditingController popUpTextController = TextEditingController();
  List<ToDoListItem> widgetList;
  List<String> keysList;

  final Key key;

  ToDoListItem(this.todoText, this.todoCheck, this.popUpTextController,
      this.widgetList, this.keysList, this.key);

  @override
  ToDoListItemState createState() {
    return ToDoListItemState();
  }
}

class ToDoListItemState extends State<ToDoListItem>
    with TickerProviderStateMixin {
  double opacity = 0;

  Tween<double> animation = Tween(begin: 0.9, end: 1);
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller = new AnimationController(
          vsync: this, duration: Duration(milliseconds: 500))
        ..forward();
      setState(() {
        opacity = 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: ScaleTransition(
            scale: animation.animate(
                CurvedAnimation(parent: controller, curve: Curves.bounceOut)),
            child: GestureDetector(
              key: Key(widget.todoText),
              child: Dismissible(
                key: Key(widget.todoText),
                child: Container(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: CheckboxListTile(
                      value: widget.todoCheck,
                      title: StrikeThrough(widget.todoText, widget.todoCheck),
                      onChanged: (checkValue) {
                        //_strikethrough toggle
                        setState(() {
                          if (!checkValue) {
                            widget.todoCheck = false;
                          } else {
                            widget.todoCheck = true;
                          }
                        });
                      },
                    )),
                secondaryBackground: Container(
                  child: Icon(
                    Icons.delete,
                    color: Colors.black,
                  ),
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 30),
                  color: Colors.redAccent,
                ),
                background: Container(
                  child: Icon(
                    Icons.done,
                    color: Colors.white,
                  ),
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 30),
                  color: Colors.blue,
                ),
                confirmDismiss: (dismissDirection) {
                  if (dismissDirection == DismissDirection.endToStart)
                    return showCupertinoModalPopup(
                        //On Dismissing
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Delete Todo?"),
                            actions: <Widget>[
                              FlatButton(
                                child: Text("OK"),
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                              ), //OK Button
                              FlatButton(
                                child: Text("Cancel"),
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                              ), //Cancel Button
                            ],
                          );
                        });
                  else
                    setState(() {
                      if (widget.todoCheck) {
                        widget.todoCheck = false;
                      } else {
                        widget.todoCheck = true;
                      }
                    });
                },
                movementDuration: const Duration(milliseconds: 200),
                onDismissed: (dismissDirection) {
                  //Delete Todo
                  widget.widgetList.remove(widget);
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text("To-Do deleted!"),
                  ));
                },
              ),
              onDoubleTap: () {
                widget.popUpTextController.text = widget.todoText;
                //For Editing Todo
                showCupertinoModalPopup(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Edit Todo"),
                        content: TextFormField(
                          autofocus: true,
                          controller: widget.popUpTextController,
                          onFieldSubmitted: (_) {
                            setState(() {
                              widget.todoText = widget.popUpTextController.text;
                            });
                            Navigator.of(context).pop(true);
                          },
                        ),
                        actions: <Widget>[
                          FlatButton(
                            child: Text("OK"),
                            onPressed: () {
                              setState(() {
                                widget.todoText =
                                    widget.popUpTextController.text;
                              });
                              Navigator.of(context).pop(true);
                            },
                          ), //OK Button
                          FlatButton(
                            child: Text("Cancel"),
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                          ), //Cancel Button
                        ],
                      );
                    });
              },
            )));
  }
}

class StrikeThrough extends StatelessWidget {
  final String todoText;
  final bool todoCheck;
  StrikeThrough(this.todoText, this.todoCheck) : super();

  Widget _widget() {
    if (todoCheck) {
      return Text(
        todoText,
        style: TextStyle(
          decoration: TextDecoration.lineThrough,
          fontStyle: FontStyle.italic,
          fontSize: 22.0,
          color: Colors.blue,
        ),
      );
    } else {
      return Text(
        todoText,
        style: TextStyle(fontSize: 22.0),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _widget();
  }
}

class App extends StatefulWidget {
  @override
  AppState createState() {
    return AppState();
  }
}

class AppState extends State<App> {
  var counter = 0;

  double loaderOpacity = 1;
  Matrix4 loaderScale = new Matrix4.identity();

  var textController = TextEditingController();
  var popUpTextController = TextEditingController();
  var listItemScrollController = ScrollController();

  var buildContext;
  double headerBlurRadius = 0;

  List<ToDoListItem> widgetList = [];
  List<String> keysList = [];

  AppState() {
    listItemScrollController.addListener(onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Timer(Duration(seconds: 2), () {
        setState(() {
          loaderOpacity = 0;
        });
      });
    });
  }

  onScroll() {
    double pixels = listItemScrollController.position.pixels;
    if (pixels > 10 && headerBlurRadius != 10) {
      setState(() {
        headerBlurRadius = 10;
      });
    } else if (pixels <= 10 && headerBlurRadius != 0) {
      setState(() {
        headerBlurRadius = 0;
      });
    }
  }

  @override
  void dispose() {
    textController.dispose();
    popUpTextController.dispose();
    listItemScrollController.removeListener(onScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Flutter Todo List"),
          iconTheme: IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        body: Builder(
          builder: (context) {
            buildContext = context;
            return Stack(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    AnimatedContainer(
                      decoration: BoxDecoration(boxShadow: [
                        BoxShadow(
                          blurRadius: headerBlurRadius,
                          color: Colors.black87,
                        )
                      ], color: Colors.white),
                      padding: EdgeInsets.only(top: 15),
                      duration: Duration(milliseconds: 300),
                      child: TextField(
                        decoration: InputDecoration(
                            hintText: "Enter Todo Text Here",
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 15)),
                        style: TextStyle(
                          fontSize: 22.0,
                        ),
                        controller: textController,
                        autocorrect: true,
                        autofocus: true,
                        onSubmitted: (value) {
                          if (textController.text.isNotEmpty) {
                            listItemScrollController.position.moveTo(
                                listItemScrollController
                                    .position.maxScrollExtent,
                                duration: Duration(milliseconds: 250),
                                curve: Curves.easeInOut);
                            keysList.add(textController.text);
                            widgetList.add(new ToDoListItem(
                                textController.text,
                                false,
                                popUpTextController,
                                widgetList,
                                keysList,
                                Key(textController.text)));
                            setState(() {
                              textController.clear();
                            });
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: ReorderableListView(
                        scrollController: listItemScrollController,
                        children: <Widget>[
                          for (final widget in widgetList) widget
                        ],
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (oldIndex < newIndex) {
                              newIndex -= 1;
                            }
                            var replaceWiget = widgetList.removeAt(oldIndex);
                            widgetList.insert(newIndex, replaceWiget);
                          });
                        },
                      ),
                    ),
                  ],
                ),
                
                Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: ButtonTheme(
                          minWidth: 0.35 * MediaQuery.of(context).size.width,
                          height: 60,
                          child: RaisedButton(
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100)),
                            color: Colors.blue,
                            child: Text(
                              "Add Todo",
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              if (textController.text.isNotEmpty) {
                                listItemScrollController.position.moveTo(
                                    listItemScrollController
                                        .position.maxScrollExtent,
                                    duration: Duration(milliseconds: 250),
                                    curve: Curves.easeInOut);
                                keysList.add(textController.text);
                                widgetList.add(new ToDoListItem(
                                    textController.text,
                                    false,
                                    popUpTextController,
                                    widgetList,
                                    keysList,
                                    Key(textController.text)));
                                setState(() {
                                  textController.clear();
                                });
                              }
                            },
                          )),
                    )
                ),

                AnimatedOpacity(
                  onEnd: () {
                    setState(() {
                      loaderScale = new Matrix4.identity()..scale(0, 0);
                    });
                  },
                  duration: Duration(milliseconds: 250),
                  opacity: loaderOpacity,
                  child: Container(
                    transform: loaderScale,
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white,
                    child: Align(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              ],
            );
          },
        ));
  }
}
