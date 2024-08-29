import 'dart:core';
import 'dart:math';
import './models.dart';

class FSRS {
  late Parameters p;
  late final double decay;
  late final double factor;

  FSRS({
    double? requestRetention,
    int? maximumInterval,
    double? w,
  }) {
    p = Parameters(
      requestRetention: requestRetention,
    );
    decay = -0.5;
    factor = pow(0.9, 1 / decay) - 1;
  }

  (Card card, ReviewLog reviewLog) reviewCard(
    Card card,
    Rating rating,
    DateTime? now,
  ) {
    final date = now ?? DateTime.now();
    final schedulingCards = repeat(card, date);

    final reviewCard = schedulingCards[rating]!.card;
    final reviewLog = schedulingCards[rating]!.reviewLog;

    return (reviewCard, reviewLog);
  }

  Map<Rating, SchedulingInfo> repeat(
    Card card,
    DateTime? now,
  ) {
    final date = now ?? DateTime.now();

    card = card.copyWith();
    if (card.state == State.newState) {
      card.elapsedDays = 0;
    } else {
      card.elapsedDays = date.difference(card.lastReview).inDays;
    }
    card.lastReview = date;
    card.reps++;

    final s = SchedulingCards(card);
    s.updateState(card.state);

    switch (card.state) {
      case State.newState:
        _initDS(s);

        s.again.due = date.add(Duration(minutes: 1));
        s.hard.due = date.add(Duration(minutes: 5));
        s.good.due = date.add(Duration(minutes: 10));
        final easyInterval = _nextInterval(s.easy.stability);
        s.easy.scheduledDays = easyInterval;
        s.easy.due = date.add(Duration(days: easyInterval));
      case State.learning:
      case State.relearning:
        final interval = card.elapsedDays;
        final lastD = card.difficulty;
        final lastS = card.stability;
        final retrievability = _forgettingCurve(interval, lastS);
        _nextDS(s, lastD, lastS, retrievability, card.state);

        final hardInterval = 0;
        final goodInterval = _nextInterval(s.good.stability);
        final easyInterval =
            max(_nextInterval(s.easy.stability), goodInterval + 1);

        s.schedule(date, hardInterval, goodInterval, easyInterval);
      case State.review:
        final interval = card.elapsedDays;
        final lastD = card.difficulty;
        final lastS = card.stability;
        final retrievability = _forgettingCurve(interval, lastS);
        _nextDS(s, lastD, lastS, retrievability, card.state);

        var hardInterval = _nextInterval(s.hard.stability);
        var goodInterval = _nextInterval(s.good.stability);
        hardInterval = min(hardInterval, goodInterval);
        goodInterval = max(goodInterval, hardInterval + 1);
        final easyInterval =
            max(_nextInterval(s.easy.stability), goodInterval + 1);
        s.schedule(date, hardInterval, goodInterval, easyInterval);
    }

    return s.recordLog(card, date);
  }

  void _initDS(SchedulingCards s) {
    s.again.difficulty = _initDifficulty(Rating.again);
    s.again.stability = _initStability(Rating.again.val);
    s.hard.difficulty = _initDifficulty(Rating.hard);
    s.hard.stability = _initStability(Rating.hard.val);
    s.good.difficulty = _initDifficulty(Rating.good);
    s.good.stability = _initStability(Rating.good.val);
    s.easy.difficulty = _initDifficulty(Rating.easy);
    s.easy.stability = _initStability(Rating.easy.val);
  }

  double _initStability(int r) => max(p.w[r - 1], 0.1);

  double _initDifficulty(Rating r) =>
      min(max(p.w[4] - exp(p.w[5] * (r.val - 1) + 1), 1), 10);

  double _forgettingCurve(int elapsedDays, double stability) =>
      pow(1 + factor * elapsedDays / stability, decay).toDouble();

  int _nextInterval(double s) {
    final newInterval = s / factor * (pow(p.requestRetention, 1 / decay) - 1);
    return min(max(newInterval.round(), 1), p.maximumInterval);
  }

  double _nextDifficulty(double d, Rating r) {
    final nextD = d - p.w[6] * (r.val - 3);
    return min(max(_meanReversion(_initDifficulty(Rating.easy), nextD), 1), 10);
  }

  double _shortTermStability(double stability, Rating rating) =>
      stability * exp(p.w[17] * (rating.val - 3 + p.w[18]));

  double _meanReversion(double init, double current) =>
      p.w[7] * init + (1 - p.w[7]) * current;

  double _nextRecallStability(double d, double s, double r, Rating rating) {
    final hardPenalty = rating == Rating.hard ? p.w[15] : 1;
    final easyBonus = rating == Rating.easy ? p.w[16] : 1;
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
    SchedulingCards s,
    double lastD,
    double lastS,
    double retrievability,
    State state,
  ) {
    switch (state) {
      case State.learning:
      case State.relearning:
        s.again.stability = _shortTermStability(lastS, Rating.again);
        s.hard.stability = _shortTermStability(lastS, Rating.hard);
        s.good.stability = _shortTermStability(lastS, Rating.good);
        s.easy.stability = _shortTermStability(lastS, Rating.easy);
      case State.review:
        s.again.stability = _nextForgetStability(
          lastD,
          lastS,
          retrievability,
        );
        s.hard.stability = _nextRecallStability(
          lastD,
          lastS,
          retrievability,
          Rating.hard,
        );
        s.good.stability = _nextRecallStability(
          lastD,
          lastS,
          retrievability,
          Rating.good,
        );
        s.easy.stability = _nextRecallStability(
          lastD,
          lastS,
          retrievability,
          Rating.easy,
        );
      case State.newState:
        return;
    }
  }
}
