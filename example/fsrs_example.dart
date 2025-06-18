import 'package:fsrs/fsrs.dart';

void main() async {
  // note: the following arguments are also the defaults
  var scheduler = Scheduler(
    parameters: [
      0.2172,
      1.1771,
      3.2602,
      16.1507,
      7.0114,
      0.57,
      2.0966,
      0.0069,
      1.5261,
      0.112,
      1.0178,
      1.849,
      0.1133,
      0.3127,
      2.2934,
      0.2191,
      3.0004,
      0.7536,
      0.3332,
      0.1437,
      0.2,
    ],
    desiredRetention: 0.9,
    learningSteps: [
      Duration(minutes: 1),
      Duration(minutes: 10),
    ],
    relearningSteps: [
      Duration(minutes: 10),
    ],
    maximumInterval: 36500,
    enableFuzzing: true,
  );

  final cardInitial = await Card.create();

  // Rating.Again (==1) forgot the card
  // Rating.Hard (==2) remembered the card with serious difficulty
  // Rating.Good (==3) remembered the card after a hesitation
  // Rating.Easy (==4) remembered the card easily

  final rating = Rating.again;

  final (:card, :reviewLog) = scheduler.reviewCard(cardInitial, rating);

  print("Card rated ${reviewLog.rating} at ${reviewLog.reviewDateTime}");

  final due = card.due;

  // how much time between when the card is due and now
  final timeDelta = due.difference(DateTime.now());

  print("Card due on $due");
  print("Card due in ${timeDelta.inSeconds} seconds");

  final retrievability = scheduler.getCardRetrievability(card);

  print("There is a $retrievability probability that this card is remembered.");

  // serialize before storage
  final schedulerDict = scheduler.toMap();
  final cardDict = card.toMap();
  final reviewLogDict = reviewLog.toMap();

  // deserialize from dict
  final newScheduler = Scheduler.fromMap(schedulerDict);
  final newCard = Card.fromMap(cardDict);
  final newReviewLog = ReviewLog.fromMap(reviewLogDict);

  print(
      "Are the original and deserialized schedulers equal? ${scheduler == newScheduler}");
  print("Are the original and deserialized cards equal? ${card == newCard}");
  print(
      "Are the original and deserialized review logs equal? ${reviewLog == newReviewLog}");
}
