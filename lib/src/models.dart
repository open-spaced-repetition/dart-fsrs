import 'dart:core';
import 'dart:math';
import 'dart:convert';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'models.freezed.dart';
part 'models.g.dart';

enum State {
  newState(0),
  learning(1),
  review(2),
  relearning(3);

  const State(this.val);

  final int val;
}

enum Rating {
  again(1),
  hard(2),
  good(3),
  easy(4);

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

/// Store card data
@unfreezed
class Card with _$Card {
  const Card._();

  factory Card.def(
    DateTime due,
    DateTime lastReview, [
    @Default(0) double stability,
    @Default(0) double difficulty,
    @Default(0) int elapsedDays,
    @Default(0) int scheduledDays,
    @Default(0) int reps,
    @Default(0) int lapses,
    @Default(State.newState) State state,
  ]) = _Card;

  factory Card.fromJson(Map<String, Object?> json) => _$CardFromJson(json);

  /// Construct current time for due and last review
  factory Card() {
    return _Card(DateTime.now().toUtc(), DateTime.now().toUtc());
  }

  double? getRetrievability(DateTime now) {
    const decay = -0.5;
    final factor = pow(0.9, 1 / decay) - 1;

    if (state == State.review) {
      final elapsedDays =
          (now.difference(lastReview).inDays).clamp(0, double.infinity).toInt();
      return pow(1 + factor * elapsedDays / stability, decay).toDouble();
    } else {
      return null;
    }
  }
}

/// Store card and review log info
class SchedulingInfo {
  late Card card;
  late ReviewLog reviewLog;

  SchedulingInfo(this.card, this.reviewLog);
}

/// Calculate next review
class SchedulingCards {
  late Card again;
  late Card hard;
  late Card good;
  late Card easy;

  SchedulingCards(Card card) {
    again = card.copyWith();
    hard = card.copyWith();
    good = card.copyWith();
    easy = card.copyWith();
  }

  void updateState(State state) {
    if (state == State.newState) {
      again.state = State.learning;
      hard.state = State.learning;
      good.state = State.learning;
      easy.state = State.review;
    } else if (state == State.learning || state == State.relearning) {
      again.state = state;
      hard.state = state;
      good.state = State.review;
      easy.state = State.review;
    } else if (state == State.review) {
      again.state = State.relearning;
      hard.state = State.review;
      good.state = State.review;
      easy.state = State.review;
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
      Rating.again: SchedulingInfo(
          again,
          ReviewLog(Rating.again, again.scheduledDays, card.elapsedDays, now,
              card.state)),
      Rating.hard: SchedulingInfo(
          hard,
          ReviewLog(Rating.hard, hard.scheduledDays, card.elapsedDays, now,
              card.state)),
      Rating.good: SchedulingInfo(
          good,
          ReviewLog(Rating.good, good.scheduledDays, card.elapsedDays, now,
              card.state)),
      Rating.easy: SchedulingInfo(
          easy,
          ReviewLog(Rating.easy, easy.scheduledDays, card.elapsedDays, now,
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
