import 'package:fsrs/fsrs.dart';

void main() {
  var f = FSRS();
  var card = Card();
  var now = DateTime(2022, 11, 29, 12, 30, 0, 0);
  print("Now: $now");
  var schedulingCards = f.repeat(card, now);
  // printSchedulingCards(schedulingCards);

  // There are four ratings:
  Rating.again; // forget; incorrect response
  Rating.hard; // recall; correct response recalled with serious difficulty
  Rating.good; // recall; correct response after a hesitation
  Rating.easy; // recall; perfect response

  // Get the new state of card for each rating:
  var cardAgain = schedulingCards[Rating.again]!.card;
  var cardHard = schedulingCards[Rating.hard]!.card;
  var cardGood = schedulingCards[Rating.good]!.card;
  var cardEasy = schedulingCards[Rating.easy]!.card;

  // Get the scheduled days for each rating:
  cardAgain.scheduledDays;
  cardHard.scheduledDays;
  cardGood.scheduledDays;
  cardEasy.scheduledDays;

  // Update the card after rating `Easy`:
  card = schedulingCards[Rating.easy]!.card;

  // Get the review log after rating `Good`:
  // ignore: unused_local_variable
  var reviewLog = schedulingCards[Rating.good]!.reviewLog;

  // Get the due date for card:
  // ignore: unused_local_variable
  var due = card.due;
  print("Due: $due");

  // There are four states:
  State.newState; // Never been studied
  State.learning; // Been studied for the first time recently
  State.review; // Graduate from learning state
  State.relearning; // Forgotten in review state
}
