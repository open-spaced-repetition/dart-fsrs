import 'dart:core';
import 'dart:math';
import 'dart:convert';

import 'package:fsrs/fsrs.dart';

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

class FSRS {
  late Parameters p;
  late double decay;
  late double factor;

  FSRS() {
    p = Parameters();
    decay = -0.5;
    factor = pow(0.9, 1 / decay) - 1;
  }

  Map<Rating, SchedulingInfo> repeat(Card card, DateTime now) {
    card = Card.copyFrom(card);
    if (card.state == State.New) {
      card.elapsedDays = 0;
    } else {
      card.elapsedDays = now.difference(card.lastReview).inDays;
    }
    card.lastReview = now;
    card.reps++;

    final s = SchedulingCards(card);
    s.updateState(card.state);

    if (card.state == State.New) {
      _initDS(s);

      s.again.due = now.add(Duration(minutes: 1));
      s.hard.due = now.add(Duration(minutes: 5));
      s.good.due = now.add(Duration(minutes: 10));
      final easyInterval = _nextInterval(s.easy.stability);
      s.easy.scheduledDays = easyInterval;
      s.easy.due = now.add(Duration(days: easyInterval));
    } else if (card.state == State.Learning || card.state == State.Relearning) {
      final hardInterval = 0;
      final goodInterval = _nextInterval(s.good.stability);
      final easyInterval =
          max(_nextInterval(s.easy.stability), goodInterval + 1);

      s.schedule(now, hardInterval.toDouble(), goodInterval.toDouble(),
          easyInterval.toDouble());
    } else if (card.state == State.Review) {
      final interval = card.elapsedDays;
      final lastD = card.difficulty;
      final lastS = card.stability;
      final retrievability = _forgettingCurve(interval, lastS);
      _nextDS(s, lastD, lastS, retrievability);

      var hardInterval = _nextInterval(s.hard.stability);
      var goodInterval = _nextInterval(s.good.stability);
      hardInterval = min(hardInterval, goodInterval);
      goodInterval = max(goodInterval, hardInterval + 1);
      final easyInterval =
          max(_nextInterval(s.easy.stability), goodInterval + 1);
      s.schedule(now, hardInterval.toDouble(), goodInterval.toDouble(),
          easyInterval.toDouble());
    }
    return s.recordLog(card, now);
  }

  void _initDS(SchedulingCards s) {
    s.again.difficulty = _initDifficulty(Rating.Again.val);
    s.again.stability = _initStability(Rating.Again.val);
    s.hard.difficulty = _initDifficulty(Rating.Hard.val);
    s.hard.stability = _initStability(Rating.Hard.val);
    s.good.difficulty = _initDifficulty(Rating.Good.val);
    s.good.stability = _initStability(Rating.Good.val);
    s.easy.difficulty = _initDifficulty(Rating.Easy.val);
    s.easy.stability = _initStability(Rating.Easy.val);
  }

  double _initStability(int r) {
    return max(p.w[r - 1], 0.1);
  }

  double _initDifficulty(int r) {
    return min(max(p.w[4] - p.w[5] * (r - 3), 1), 10);
  }

  double _forgettingCurve(int elapsedDays, double stability) {
    return pow(1 + factor * elapsedDays / stability, decay).toDouble();
  }

  int _nextInterval(double s) {
    final newInterval = s / factor * (pow(p.requestRetention, 1 / decay) - 1);
    return min(max(newInterval.round(), 1), p.maximumInterval);
  }

  double _nextDifficulty(double d, int r) {
    final nextD = d - p.w[6] * (r - 3);
    return min(max(_meanReversion(p.w[4], nextD), 1), 10);
  }

  double _meanReversion(double init, double current) {
    return p.w[7] * init + (1 - p.w[7]) * current;
  }

  double _nextRecallStability(double d, double s, double r, Rating rating) {
    final hardPenalty = (rating == Rating.Hard) ? p.w[15] : 1;
    final easyBonus = (rating == Rating.Easy) ? p.w[16] : 1;
    return s *
        (1 +
            exp(p.w[8]) *
                (11 - d) *
                pow(s, -p.w[9]) *
                (exp((1 - r) * p.w[10]) - 1) *
                hardPenalty *
                easyBonus);
  }

  double _nextForgetStability(double d, double s, double r) {
    return p.w[11] *
        pow(d, -p.w[12]) *
        (pow(s + 1, p.w[13]) - 1) *
        exp((1 - r) * p.w[14]);
  }

  void _nextDS(
      SchedulingCards s, double lastD, double lastS, double retrievability) {
    s.again.difficulty = _nextDifficulty(lastD, Rating.Again.val);
    s.again.stability = _nextForgetStability(lastD, lastS, retrievability);
    s.hard.difficulty = _nextDifficulty(lastD, Rating.Hard.val);
    s.hard.stability =
        _nextRecallStability(lastD, lastS, retrievability, Rating.Hard);
    s.good.difficulty = _nextDifficulty(lastD, Rating.Good.val);
    s.good.stability =
        _nextRecallStability(lastD, lastS, retrievability, Rating.Good);
    s.easy.difficulty = _nextDifficulty(lastD, Rating.Easy.val);
    s.easy.stability =
        _nextRecallStability(lastD, lastS, retrievability, Rating.Easy);
  }
}
