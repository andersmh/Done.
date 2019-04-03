import '../model/item.dart';
import '../util/database_client.dart';
import 'package:flutter/material.dart';

class HomeContentPage extends StatefulWidget {
  @override
  _HomeContentPageState createState() => _HomeContentPageState();
}

class _HomeContentPageState extends State<HomeContentPage> {
  final _textEditingController = new TextEditingController();
  var db = new DatabaseHelper();
  final List<Item> _itemList = <Item>[];

  @override
  void initState() {
    _readNoDoList();
  }

  void _handleSubmitted(String text) async {
    Item noDoItem = new Item(text);
    int savedItemId = await db.saveItem(noDoItem);
    Item addedItem = await db.getItem(savedItemId);

    setState(() {
      _itemList.insert(0, addedItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(vertical: 20.0),
            height: 220,
            color: Color(0xFF020E38),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                myCategory('Physics\nAssignment'),
                myCategory('Reparing\nThe\nCar'),
                myCategory('Dinne\ningrediens'),
              ],
            ),
          ),
          Flexible(
            child: ListView.builder(
              padding: EdgeInsets.all(8.0),
              reverse: false,
              itemCount: _itemList.length,
              itemBuilder: (_, int index) {
                return Card(
                  color: Colors.white,
                  elevation: 0,
                  child: ListTile(
                    title: _itemList[index],
                    onLongPress: () => _updateItem(_itemList[index], index),
                    trailing: Listener(
                      key: Key(_itemList[index].itemName),
                      child: Icon(Icons.remove_circle, color: Colors.redAccent),
                      onPointerDown: (pointerEvent) =>
                          _deleteNoDo(_itemList[index].id, index),
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(
            height: 1.0,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showFormDialog,
        tooltip: "Add Task",
        backgroundColor: Color(0xff020E38),
        child: ListTile(
          title: Icon(
            Icons.add,
          ),
        ),
      ),
    );
  }

  void _showFormDialog() {
    var alert = AlertDialog(
      content: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _textEditingController,
              autofocus: true,
              decoration: InputDecoration(
                  labelText: "Task",
                  hintText: "Task description here",
                  icon: Icon(Icons.note_add)),
            ),
          )
        ],
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            _handleSubmitted(_textEditingController.text);
            _textEditingController.clear();
            Navigator.pop(context);
          },
          child: Text("Save"),
        ),
        FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        ),
      ],
    );
    showDialog(
        context: context,
        builder: (_) {
          return alert;
        });
  }

  _readNoDoList() async {
    List items = await db.getAllItems();
    items.forEach((item) {
      setState(() {
        _itemList.add(Item.map(item));
      });
    });
  }

  _deleteNoDo(int id, int index) async {
    await db.deleteItem(id);
    setState(() {
      _itemList.removeAt(index);
    });
  }

  _updateItem(Item item, int index) {
    var alert = AlertDialog(
      title: Text("Update Item"),
      content: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _textEditingController,
              autofocus: true,
              decoration: InputDecoration(
                  labelText: "Task",
                  hintText: "Task description here",
                  icon: Icon(Icons.update)),
            ),
          )
        ],
      ),
      actions: <Widget>[
        FlatButton(
            onPressed: () async {
              Item newItemUpdated = Item.fromMap(
                  {"itemName": _textEditingController.text, "id": item.id});

              _handleSubmittedUpdate(index, item);
              await db.updateItem(newItemUpdated);
              setState(() {
                _readNoDoList();
              });
              Navigator.pop(context);
            },
            child: Text("Update")),
        FlatButton(
            onPressed: () => Navigator.pop(context), child: Text("Cancel"))
      ],
    );

    showDialog(
      context: context,
      builder: (_) {
        return alert;
      },
    );
  }

  void _handleSubmittedUpdate(int index, Item item) {
    setState(() {
      _itemList.removeWhere((element) {
        _itemList[index].itemName = item.itemName;
      });
    });
  }

//#C418F7 pink
//#007ECE blue
  Container myCategory(String categoryName) {
    return Container(
      width: 250.0,
      height: 250.0,
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 25),
      child: DecoratedBox(
        decoration: new BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          gradient: new LinearGradient(
            begin: FractionalOffset.topLeft,
            end: FractionalOffset.bottomCenter,
            colors: [
              const Color(0xff007ECE),
              const Color(0xffC418F7),
            ],
          ),
        ),
        child: Wrap(
          children: <Widget>[
            SizedBox(
              height: 40,
              width: 40,
            ),
            Text(
              categoryName,
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Futura',
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }
}
