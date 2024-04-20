## About The Project

dart-fsrs is a Dart Package implements [Free Spaced Repetition Scheduler algorithm](https://github.com/open-spaced-repetition/free-spaced-repetition-scheduler). It helps developers apply FSRS in their flashcard apps.

## Getting Started

```
dart pub add fsrs
```

## Usage

Create a card and review it at a given time:
```dart
import 'package:fsrs/fsrs.dart';

var f = FSRS();
var card = Card();
var now = DateTime(2022, 11, 29, 12, 30, 0, 0);
var schedulingCards = f.repeat(card, now);
printSchedulingCards(schedulingCards);
```

There are four ratings:
```dart
Rating.again; // forget; incorrect response
Rating.hard; // recall; correct response recalled with serious difficulty
Rating.good; // recall; correct response after a hesitation
Rating.easy; // recall; perfect response
```


Get the new state of card for each rating:
```dart
var cardAgain = schedulingCards[Rating.again]!.card;
var cardHard = schedulingCards[Rating.hard]!.card;
var cardGood = schedulingCards[Rating.good]!.card;
var cardEasy = schedulingCards[Rating.easy]!.card;
```

Get the scheduled days for each rating:
```dart
cardAgain.scheduledDays;
cardHard.scheduledDays;
cardGood.scheduledDays;
cardEasy.scheduledDays;
```

Update the card after rating `Good`:
```dart
card = schedulingCards[Rating.good]!.card;
```

Get the review log after rating `Good`:
```dart
var reviewLog = schedulingCards[Rating.good]!.reviewLog;
```

Get the due date for card:
```dart
due = card.due
```

There are four states:
```dart
State.newState; // Never been studied
State.learning; // Been studied for the first time recently
State.review; // Graduate from learning state
State.relearning; // Forgotten in review state
```

## License

Distributed under the MIT License. See `LICENSE` for more information.

## More Info: 
Port from git@github.com:open-spaced-repetition/py-fsrs.git
commit: 1b4cbe4
