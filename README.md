<div align="center">
  <img src="https://raw.githubusercontent.com/open-spaced-repetition/py-fsrs/main/osr_logo.png" height="100" alt="Open Spaced Repetition logo"/>
</div>
<div align="center">

# Dart-FSRS

</div>
<div align="center">
  <em>🧠🔄 Build your own Spaced Repetition System in Dart 🧠🔄   </em>
</div>
<br />
<div align="center" style="text-decoration: none;">
    <a href="https://pub.dev/packages/fsrs"><img src="https://img.shields.io/pub/v/fsrs?label=pub.dev&labelColor=333940&logo=dart"></a>
    <a href="https://github.com/open-spaced-repetition/py-fsrs/blob/main/LICENSE" style="text-decoration: none;"><img src="https://img.shields.io/badge/License-MIT-brightgreen.svg"></a>
    <a href="https://github.com/open-spaced-repetition/dart-fsrs/actions/workflows/dart.yml" style="text-decoration: none;"><img src="https://img.shields.io/github/actions/workflow/status/open-spaced-repetition/dart-fsrs/dart.yml?branch=main&label=CI&labelColor=333940&logo=github"></a>
</div>
<br />

**Dart-FSRS is a dart package that allows developers to easily create their own spaced repetition system using the <a href="https://github.com/open-spaced-repetition/free-spaced-repetition-scheduler">Free Spaced Repetition Scheduler algorithm</a>.**

## Table of Contents

- [Installation](#installation)
- [Quickstart](#quickstart)
- [Usage](#usage)
- [Reference](#reference)
- [License](#license)
- [More Info](#more-info)
- [Online development](#online-development)

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  fsrs: ^2.0.0
```

and then run:

```bash
dart pub get
```

Or just install it with dart cli:

```bash
dart pub add fsrs
```

## Quickstart

Import and initialize the FSRS scheduler

```dart
import 'package:fsrs/fsrs.dart';

var scheduler = Scheduler();
```

Create a new Card object

```dart
// note: all new cards are 'due' immediately upon creation
final card = Card(cardId: 1);
// alternatively, you can let fsrs generate a unique ID for you
final card = await Card.create();
```

Choose a rating and review the card with the scheduler

```dart
// Rating.Again (==1) forgot the card
// Rating.Hard (==2) remembered the card with serious difficulty
// Rating.Good (==3) remembered the card after a hesitation
// Rating.Easy (==4) remembered the card easily

final rating = Rating.good;

final (:card, :reviewLog) = scheduler.reviewCard(card, rating);

print("Card rated ${reviewLog.rating} at ${reviewLog.reviewDateTime}");
// > Card rated 3 at 2024-11-30 17:46:58.856497Z
```

See when the card is due next

```dart
final due = card.due;

// how much time between when the card is due and now
final timeDelta = due.difference(DateTime.now());

print("Card due on $due");
print("Card due in ${timeDelta.inSeconds} seconds");

// > Card due on 2024-12-01 17:46:58.856497Z
// > Card due in 599 seconds
```

## Usage

### Custom parameters

You can initialize the FSRS scheduler with your own custom parameters.

```dart
// note: the following arguments are also the defaults
scheduler = Scheduler(
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
```

#### Explanation of parameters

`parameters` are a set of 21 model weights that affect how the FSRS scheduler will schedule future reviews. If you're not familiar with optimizing FSRS, it is best not to modify these default values.

`desired_retention` is a value between 0 and 1 that sets the desired minimum retention rate for cards when scheduled with the scheduler. For example, with the default value of `desired_retention=0.9`, a card will be scheduled at a time in the future when the predicted probability of the user correctly recalling that card falls to 90%. A higher `desired_retention` rate will lead to more reviews and a lower rate will lead to fewer reviews.

`learning_steps` are custom time intervals that schedule new cards in the Learning state. By default, cards in the Learning state have short intervals of 1 minute then 10 minutes. You can also disable `learning_steps` with `Scheduler(learning_steps=())`

`relearning_steps` are analogous to `learning_steps` except they apply to cards in the Relearning state. Cards transition to the Relearning state if they were previously in the Review state, then were rated Again - this is also known as a 'lapse'. If you specify `Scheduler(relearning_steps=())`, cards in the Review state, when lapsed, will not move to the Relearning state, but instead stay in the Review state.

`maximum_interval` sets the cap for the maximum days into the future the scheduler is capable of scheduling cards. For example, if you never want the scheduler to schedule a card more than one year into the future, you'd set `Scheduler(maximum_interval=365)`.

`enable_fuzzing`, if set to True, will apply a small amount of random 'fuzz' to calculated intervals. For example, a card that would've been due in 50 days, after fuzzing, might be due in 49, or 51 days.

### Timezone

**Dart-FSRS uses UTC only.**

You can still specify custom datetimes, but they must use the UTC timezone.

### Retrievability

You can calculate the current probability of correctly recalling a card (its 'retrievability') with

```dart
final retrievability = scheduler.getCardRetrievability(card);

print("There is a $retrievability probability that this card is remembered.");
// > There is a 0.94 probability that this card is remembered.
```

### Serialization

`Scheduler`, `Card` and `ReviewLog` classes are all JSON-serializable via their `toMap` and `fromMap` methods for easy database storage:

```dart
// serialize before storage
final schedulerDict = scheduler.toMap();
final cardDict = card.toMap();
final reviewLogDict = reviewLog.toMap();

// deserialize from dict
final newScheduler = Scheduler.fromMap(schedulerDict);
final newCard = Card.fromMap(cardDict);
final newReviewLog = ReviewLog.fromMap(reviewLogDict);
```

## Reference

Card objects have one of three possible states

```dart
State.Learning # (==1) new card being studied for the first time
State.Review # (==2) card that has "graduated" from the Learning state
State.Relearning # (==3) card that has "lapsed" from the Review state
```

There are four possible ratings when reviewing a card object:

```dart
Rating.Again # (==1) forgot the card
Rating.Hard # (==2) remembered the card with serious difficulty
Rating.Good # (==3) remembered the card after a hesitation
Rating.Easy # (==4) remembered the card easily
```

## License

Distributed under the MIT License. See `LICENSE` for more information.

## More Info:

Port from [open-spaced-repetition/py-fsrs@6fd0857](https://github.com/open-spaced-repetition/py-fsrs/tree/6fd0857)

## Online development

<https://idx.google.com/import>
