import 'package:fsrs/fsrs.dart';
import 'package:test/test.dart';
import 'package:collection/collection.dart';

void main() {
  group('A group of tests', () {
    // final awesome = Awesome();

    setUp(() {
      // Additional setup goes here.
    });

    test('First Test', () {
      // expect(awesome.isAwesome, isTrue);
      testRepeat();
    });
  });
}

void printSchedulingCards(Map<Rating, SchedulingInfo> schedulingCards) {
  print("again.card: ${schedulingCards[Rating.Again]?.card}");
  print("again.reviewLog: ${schedulingCards[Rating.Again]?.reviewLog}");
  print("hard.card: ${schedulingCards[Rating.Hard]?.card}");
  print("hard.reviewLog: ${schedulingCards[Rating.Hard]?.reviewLog}");
  print("good.card: ${schedulingCards[Rating.Good]?.card}");
  print("good.reviewLog: ${schedulingCards[Rating.Good]?.reviewLog}");
  print("easy.card: ${schedulingCards[Rating.Easy]?.card}");
  print("easy.reviewLog: ${schedulingCards[Rating.Easy]?.reviewLog}");
  print("");
}

void testRepeat() {
  var f = FSRS();
  f.p.w = [
    1.14,
    1.01,
    5.44,
    14.67,
    5.3024,
    1.5662,
    1.2503,
    0.0028,
    1.5489,
    0.1763,
    0.9953,
    2.7473,
    0.0179,
    0.3105,
    0.3976,
    0.0,
    2.0902
  ];
  var card = Card();
  var now = DateTime(2022, 11, 29, 12, 30, 0, 0);
  var schedulingCards = f.repeat(card, now);
  printSchedulingCards(schedulingCards);

  var ratings = [
    Rating.Good,
    Rating.Good,
    Rating.Good,
    Rating.Good,
    Rating.Good,
    Rating.Good,
    Rating.Again,
    Rating.Again,
    Rating.Good,
    Rating.Good,
    Rating.Good,
    Rating.Good,
    Rating.Good,
  ];
  var ivlHistory = <int>[];

  for (var rating in ratings) {
    card = schedulingCards[rating]?.card ?? Card();
    var ivl = card.scheduledDays;
    ivlHistory.add(ivl);
    now = card.due;
    schedulingCards = f.repeat(card, now);
    printSchedulingCards(schedulingCards);
  }

  print(ivlHistory);
  assert(ListEquality()
      .equals(ivlHistory, [0, 5, 16, 43, 106, 236, 0, 0, 12, 25, 47, 85, 147]));
}
