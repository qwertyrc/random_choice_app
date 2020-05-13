import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:provider/provider.dart';
import 'bloc/bloc_choices.dart';
import 'dart:math';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'random choice app',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Provider<ChoicesBloc>(
        create: (_) => ChoicesBloc(),
        dispose: (_, choicesBloc) => choicesBloc.dispose(),
        child: MyHomePage(title: 'Random Choice App'),
      )
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

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<ChoicesBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          new FloatingActionButton(
            child: Icon(Icons.exposure_plus_1),
            onPressed: (){
              bloc.addOne();
            },
          ),
          new FloatingActionButton(
            child: Icon(Icons.exposure_neg_1),
            onPressed: (){
              bloc.deleteOne();
            },
          )
        ])
      ,
      body: Row( children:[
        Flexible(
          flex: 1,
          child: Center(
            child: SlotMachineWidget(),
          ),
        ),
        Flexible(
          flex: 1,
          child: new SingleChildScrollView(
              child: StreamBuilder<List<Choice>>(
                stream: bloc.choices,
                initialData: [],
                builder: (context, snapshot) {
                  return ListView(
                    shrinkWrap: true,
                    children: snapshot.data.map((choice){
                      return ChoiceItem(choice, Icon(Icons.wb_sunny), key: ValueKey(choice.seqNum));
                    }).toList(),
                  );
                }
              ),
            ),
          ),
      ]),
    );
  }
}

class ChoiceItem extends StatelessWidget {
  ChoiceItem(this.choice, this.icon, {Key key}): super(key: key);
  final Choice choice;
  final Icon icon;

  @override
  Widget build(BuildContext context){
    final bloc = Provider.of<ChoicesBloc>(context);
    final label = choice.label;

    return Container(
      decoration: new BoxDecoration(
        border: new Border(bottom: BorderSide(width: 1.0, color: Colors.grey))
      ),
      child:ListTile(
        leading: icon,
        title: TextFormField(
          enabled: true,
          initialValue: label,
          onChanged: (str){
            bloc.getChoices().firstWhere((c) => c.seqNum == choice.seqNum)
              .label = str;
            bloc.updateChoices();
          }
        ),
      ),
    );
  }
}


class SlotMachineWidget extends StatelessWidget{

  @override
  Widget build(BuildContext context){
    final bloc = Provider.of<ChoicesBloc>(context);
    return Stack(
          children: <Widget>[
            Center(child: SizedBox(height: 400, width:400,
              child: StreamBuilder<List<Choice>>(
                stream: bloc.choices,
                initialData: [],
                builder: (context, snapshot) {
                  print(snapshot.data);
                  return DonutPieChart.withChoices(snapshot.data);
                }
              ),
            ),),
            
            Center(child: ChoiceText()),
          ],
        );
  }
}

class ChoiceText extends StatefulWidget{
  ChoiceText({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ChoiceTextState();
  }
}

class ChoiceTextState extends State<ChoiceText>{
  String str = "これだ！";
  
  @override
  Widget build(BuildContext context) {
    var bloc = Provider.of<ChoicesBloc>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FlatButton(
          child: Text("あなたがやるべきことは...", style: TextStyle(color: Colors.white),),
          color: Colors.lightBlue,
          onPressed: (){
            final choices = bloc.getChoices();
            final random = new Random();
            setState(() {
              str = choices[random.nextInt(choices.length)].label;
            });
          },
        ),
        Text(
          str,
          style: Theme.of(context).textTheme.headline4,
        ),
      ],
    );
  }
}

class DonutPieChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  DonutPieChart(this.seriesList, {this.animate});

  factory DonutPieChart.withSampleData() {
    final data = [
      new Choice(2, 1, label:"あれ"),
      new Choice(3, 1, label:"これ"),
      new Choice(1, 1, label:"それ"),
      new Choice(0, 1, label:"どれ"),
    ];

    return new DonutPieChart(
      _createSampleData(data),
      animate: true,
    );
  }

  factory DonutPieChart.withChoices(List<Choice> data){
    return new DonutPieChart(
      _createSampleData(data),
      animate: true,
    );
  }


  @override
  Widget build(BuildContext context) {
    return new charts.PieChart(seriesList,
        animate: animate,
        // ドーナツの内側半径・ラベルのinside/outsideの設定
        defaultRenderer: new charts.ArcRendererConfig(
          arcWidth: 60,
          arcRendererDecorators: [
            new charts.ArcLabelDecorator(
              labelPosition: charts.ArcLabelPosition.inside,
            ),
          ])
      );
  }

  static List<charts.Series<Choice, int>> _createSampleData(List<Choice> data) {

    return [
      new charts.Series<Choice, int>(
        id: 'Sales',
        domainFn: (Choice choice, _) => choice.seqNum,
        measureFn: (Choice choice, _) => choice.priority,
        data: data,
        // ラベル設定
        labelAccessorFn: (Choice choice, _) => choice.label,
      )
    ];
  }
}
