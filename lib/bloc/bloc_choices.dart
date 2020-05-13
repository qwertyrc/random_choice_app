import 'package:rxdart/rxdart.dart';


class Choice {
  final int seqNum;
  final int priority;
  String label;

  Choice(this.seqNum, this.priority, {this.label});
}


class ChoicesBloc{
  PublishSubject<Choice> choiceSubject = new PublishSubject<Choice>();
  BehaviorSubject<List<Choice>> choicesSubject = new BehaviorSubject.seeded([]);
  Stream<List<Choice>> get choices => choicesSubject.stream;

  int _seqNum = 0;
  List<Choice> _choices = [];

  ChoicesBloc(){
    addOne();
  }

  List<Choice> getChoices(){
    return _choices;
  }

  void addOne(){
    _seqNum += 1;
    _choices.add(Choice(_seqNum, 1, label: ""));
    choicesSubject.sink.add(_choices);
  }

  void deleteOne(){
    if(_choices.length >= 2){
      _choices.removeAt(_choices.length-1);
      choicesSubject.sink.add(_choices);
    }
  }

  void updateChoices(){
    choicesSubject.sink.add(_choices);
  }

  void dispose(){
    choiceSubject.close();
    choicesSubject.close();
  }
}