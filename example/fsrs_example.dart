import 'package:fsrs/fsrs.dart';

void main() {
  var f = FSRS();
  var card = Card();
  var now = DateTime(2022, 11, 29, 12, 30, 0, 0);
  var schedulingCards = f.repeat(card, now);
  printSchedulingCards(schedulingCards);

  // There are four ratings:
  Rating.Again; // forget; incorrect response
  Rating.Hard; // recall; correct response recalled with serious difficulty
  Rating.Good; // recall; correct response after a hesitation
  Rating.Easy; // recall; perfect response

  // Get the new state of card for each rating:
  var cardAgain = schedulingCards[Rating.Again]!.card;
  var cardHard = schedulingCards[Rating.Hard]!.card;
  var cardGood = schedulingCards[Rating.Good]!.card;
  var cardEasy = schedulingCards[Rating.Easy]!.card;

  // Get the scheduled days for each rating:
  cardAgain.scheduledDays;
  cardHard.scheduledDays;
  cardGood.scheduledDays;
  cardEasy.scheduledDays;

  // Update the card after rating `Good`:
  card = schedulingCards[Rating.Good]!.card;

  // Get the review log after rating `Good`:
  var reviewLog = schedulingCards[Rating.Good]!.reviewLog;

  // Get the due date for card:
  var due = card.due;

  // There are four states:
  State.New; // Never been studied
  State.Learning; // Been studied for the first time recently
  State.Review; // Graduate from learning state
  State.Relearning; // Forgotten in review state
}
