import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:xml2json/xml2json.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Курсы валют на сегодня'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var currencies;

  @override
  void initState() {
    super.initState();
    currencies =  { // pass nulls
      'BYN':1.0,
      'USD':1.0,
      'EUR':1.0,
      'KZT':1.0
    };
    _refresh(); // first refresh on startup
  }//initState

  _makeGetRequest() async {
    // magic for convert xml to json
    final Xml2Json xml2Json = Xml2Json();
    // make async GET request
    String url = 'http://www.cbr.ru/scripts/XML_daily.asp';
    Response response = await get(url);
    // response contains xml
    if (response.statusCode == 200) { // OK
      String xmlString = response.body; // get xml
      xml2Json.parse(xmlString); // parse and convert to json (Dart wants json!)
      var jsonString = xml2Json.toParker();
      var map = jsonDecode(jsonString); // convert json to map and return
      return map;
    }
    else {
      throw Exception('Failed to load currencies'); // not OK
    }
  }

  _refresh() {
    _makeGetRequest().then((var map) { // after async
      // get map and find some currencies
      map['ValCurs']['Valute'].forEach((arrayItem)
      {
        switch(arrayItem['CharCode']) {
          case 'USD':
            currencies['USD'] = double.tryParse (arrayItem['Value'].replaceAll(new RegExp(r','), '.'));
            break;
          case 'EUR':
            currencies['EUR'] = double.tryParse (arrayItem['Value'].replaceAll(new RegExp(r','), '.'));
            break;
          case 'KZT':
            currencies['KZT'] = double.tryParse (arrayItem['Value'].replaceAll(new RegExp(r','), '.'));
            break;
          case 'BYN':
            currencies['BYN'] = double.tryParse (arrayItem['Value'].replaceAll(new RegExp(r','), '.'));
            break;
        }
      }
      );
      setState(() {}); // refresh info on screen
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Курс белорусского рубля:',
            ),
            Text(
              currencies['BYN'].toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              'Курс доллара:',
            ),
            Text(
              currencies['USD'].toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              'Курс евро:',
            ),
            Text(
              currencies['EUR'].toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              'Курс тенге:',
            ),
            Text(
              currencies['KZT'].toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refresh,
        tooltip: 'Обновить',
        child: Icon(Icons.autorenew),
      ),
    );
  }
}
