import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:sqllite/helper/dbhelper.dart';
import 'package:sqllite/pages/entryForm.dart';
import 'package:flutter/material.dart';
import '../model/item.dart';


class Home extends StatefulWidget {
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  DbHelper dbHelper = DbHelper();
  int count = 0;
  List<Item> itemList;
  
  @override
  void initState(){
    super.initState();
    updateListView();
  }
  //build diambil berulang ulang tergantung statenya
  Widget build(BuildContext context) {
    if (itemList == null) {
      // ignore: deprecated_member_use
      itemList = List<Item>();
    }
    return Scaffold(
        appBar: AppBar(
          title: Text('Daftar Item'),
        ),
        body: Column(
          children: [
            Expanded(
              child: createListView(),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: double.infinity,
                height: 50,
                // ignore: deprecated_member_use
                child: RaisedButton.icon(
                  onPressed: () async {
                    var item = await navigateToEntryForm(context, null);
                    if (item != null) {
                      //insert ke DB
                      int result = await dbHelper.insert(item);
                      if (result > 0) {
                        updateListView();
                      }
                    }
                  },
                  icon: Icon(Icons.add),
                  label: Text("Tambah Item",
                  style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            )
          ],
        )
      );
  }

  ListView createListView() {
    //TextStyle textStyle = Theme.of(context).textTheme.headline5;
    return ListView.builder(
      itemCount: count,
      itemBuilder: (buildContext, int index) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.red,
              child: Icon(Icons.ad_units),
            ),
            title: Row(
              children: [
                Container(
                  padding: EdgeInsets.only(right: 10),
                  child: Text("[" + this.itemList[index].kodeBarang + "]",
                  style: TextStyle(fontWeight: FontWeight.bold,
                  fontSize: 18,
                  ),
                  ),
                ),
                Container(
                  child: Text(
                    this.itemList[index].name,
                    style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18,),
                  )
                )
              ],
            ),
            subtitle: Row(
               crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.only(top: 5),
                  child: Text(
                    "Rp " + this.itemList[index].price.toString(),
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 5),
                  child: Text(
                    "; Stok: " + this.itemList[index].stok.toString(),
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            trailing: GestureDetector(
              child: Icon(Icons.delete),
              onTap: () async {
                //fungsi delete
                dbHelper.delete(itemList[index].id);
                updateListView();
                //dbHelper.delete();
              },
            ),
            onTap: () async {
              //fungsi edit data
              var item = await navigateToEntryForm(context, this.itemList[index]);
              if(item != null) dbHelper.update(item);
              updateListView();
              //dbHelper.update();
            },
          ),
        );
      },
    );
  }

  Future<Item> navigateToEntryForm(BuildContext context, Item item) async {
    var result = await Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) {
      return EntryForm(item);
    }));
    return result;
  }

  void updateListView() {
    final Future<Database> dbFuture = dbHelper.initDb();
    dbFuture.then((database) {
      //select data
      Future<List<Item>> itemListFuture = dbHelper.getItemList();
      itemListFuture.then((itemList) {
        setState(() {
          this.itemList = itemList;
          this.count = itemList.length;
        });
      });
    });
  }
}
