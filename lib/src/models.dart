import 'dart:core';
import 'dart:math';
import 'dart:convert';

enum State {
  New(0),
  Learning(1),
  Review(2),
  Relearning(3);

  const State(this.val);

  final int val;
}

enum Rating {
  Again(1),
  Hard(2),
  Good(3),
  Easy(4);

  const Rating(this.val);

  final int val;
}

class ReviewLog {
  Rating rating;
  int scheduledDays;
  int elapsedDays;
  DateTime review;
  State state;

  ReviewLog(this.rating, this.scheduledDays, this.elapsedDays, this.review,
      this.state);
  @override
  String toString() {
    return jsonEncode({
      "rating": rating.toString(),
      "scheduledDays": scheduledDays,
      "elapsedDays": elapsedDays,
      "review": review.toString(),
      "state": state.toString(),
    });
  }
}

class Card {
  late DateTime due;
  double stability = 0;
  double difficulty = 0;
  int elapsedDays = 0;
  int scheduledDays = 0;
  int reps = 0;
  int lapses = 0;
  State state = State.New;
  late DateTime lastReview;

  @override
  String toString() {
    return jsonEncode({
      "due": due.toString(),
      "stability": stability,
      "difficulty": difficulty,
      "elapsedDays": elapsedDays,
      "scheduledDays": scheduledDays,
      "reps": reps,
      "lapses": lapses,
      "state": state.toString(),
      "lastReview": lastReview.toString(),
    });
  }

  Card() {
    due = DateTime.now().toUtc();
    lastReview = DateTime.now().toUtc();
  }

  // .from Constructor for copying
  factory Card.copyFrom(Card card) {
    Card newCard = Card();
    newCard.due = card.due;
    newCard.stability = card.stability;
    newCard.difficulty = card.difficulty;
    newCard.elapsedDays = card.elapsedDays;
    newCard.scheduledDays = card.scheduledDays;
    newCard.reps = card.reps;
    newCard.lapses = card.lapses;
    newCard.state = card.state;
    newCard.lastReview = card.lastReview;
    return newCard;
  }

  double? getRetrievability(DateTime now) {
    const decay = -0.5;
    final factor = pow(0.9, 1 / decay) - 1;

    if (state == State.Review) {
      final elapsedDays =
          (now.difference(lastReview).inDays).clamp(0, double.infinity).toInt();
      return pow(1 + factor * elapsedDays / stability, decay).toDouble();
    } else {
      return null;
    }
  }
}

class SchedulingInfo {
  late Card card;
  late ReviewLog reviewLog;

  SchedulingInfo(this.card, this.reviewLog);
}

class SchedulingCards {
  late Card again;
  late Card hard;
  late Card good;
  late Card easy;

  SchedulingCards(Card card) {
    again = Card.copyFrom(card);
    hard = Card.copyFrom(card);
    good = Card.copyFrom(card);
    easy = Card.copyFrom(card);
  }

  void updateState(State state) {
    if (state == State.New) {
      again.state = State.Learning;
      hard.state = State.Learning;
      good.state = State.Learning;
      easy.state = State.Review;
    } else if (state == State.Learning || state == State.Relearning) {
      again.state = state;
      hard.state = state;
      good.state = State.Review;
      easy.state = State.Review;
    } else if (state == State.Review) {
      again.state = State.Relearning;
      hard.state = State.Review;
      good.state = State.Review;
      easy.state = State.Review;
      again.lapses++;
    }
  }

  void schedule(DateTime now, double hardInterval, double goodInterval,
      double easyInterval) {
    again.scheduledDays = 0;
    hard.scheduledDays = hardInterval.toInt();
    good.scheduledDays = goodInterval.toInt();
    easy.scheduledDays = easyInterval.toInt();
    again.due = now.add(Duration(minutes: 5));
    hard.due = (hardInterval > 0)
        ? now.add(Duration(days: hardInterval.toInt()))
        : now.add(Duration(minutes: 10));
    good.due = now.add(Duration(days: goodInterval.toInt()));
    easy.due = now.add(Duration(days: easyInterval.toInt()));
  }

  Map<Rating, SchedulingInfo> recordLog(Card card, DateTime now) {
    return {
      Rating.Again: SchedulingInfo(
          again,
          ReviewLog(Rating.Again, again.scheduledDays, card.elapsedDays, now,
              card.state)),
      Rating.Hard: SchedulingInfo(
          hard,
          ReviewLog(Rating.Hard, hard.scheduledDays, card.elapsedDays, now,
              card.state)),
      Rating.Good: SchedulingInfo(
          good,
          ReviewLog(Rating.Good, good.scheduledDays, card.elapsedDays, now,
              card.state)),
      Rating.Easy: SchedulingInfo(
          easy,
          ReviewLog(Rating.Easy, easy.scheduledDays, card.elapsedDays, now,
              card.state)),
    };
  }
}

class Parameters {
  double requestRetention = 0.9;
  int maximumInterval = 36500;
  List<double> w = [
    0.4,
    0.6,
    2.4,
    5.8,
    4.93,
    0.94,
    0.86,
    0.01,
    1.49,
    0.14,
    0.94,
    2.18,
    0.05,
    0.34,
    1.26,
    0.29,
    2.61
  ];
}