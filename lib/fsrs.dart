/// This module defines each of the classes used in the fsrs package.
///
/// Classes:
///   State: Enum representing the learning state of a Card object.
///   Rating: Enum representing the four possible ratings when reviewing a card.
///   Card: Represents a flashcard in the FSRS system.
///   ReviewLog: Represents the log entry of a Card that has been reviewed.
///   Scheduler: The FSRS spaced-repetition scheduler.
library;

import 'dart:math' as math;

import 'package:meta/meta.dart';

const defaultParameters = [
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
];

const stabilityMin = 0.001;
const lowerBoundsParameters = [
  stabilityMin,
  stabilityMin,
  stabilityMin,
  stabilityMin,
  1.0,
  0.001,
  0.001,
  0.001,
  0.0,
  0.0,
  0.001,
  0.001,
  0.001,
  0.001,
  0.0,
  0.0,
  1.0,
  0.0,
  0.0,
  0.0,
  0.1,
];

const initialStabilityMax = 100.0;
const upperBoundsParameters = [
  initialStabilityMax,
  initialStabilityMax,
  initialStabilityMax,
  initialStabilityMax,
  10.0,
  4.0,
  4.0,
  0.75,
  4.5,
  0.8,
  3.5,
  5.0,
  0.25,
  0.9,
  4.0,
  1.0,
  6.0,
  2.0,
  2.0,
  0.8,
  0.8,
];

const minDifficulty = 1.0;
const maxDifficulty = 10.0;

const fuzzRanges = [
  {
    'start': 2.5,
    'end': 7.0,
    'factor': 0.15,
  },
  {
    'start': 7.0,
    'end': 20.0,
    'factor': 0.1,
  },
  {
    'start': 20.0,
    'end': double.infinity,
    'factor': 0.05,
  },
];

/// {@template fsrs.state}
/// Enum representing the learning state of a Card object.
/// {@endtemplate}
enum State {
  learning(1),
  review(2),
  relearning(3);

  /// {@macro fsrs.state}
  const State(this.value);

  /// {@macro fsrs.state}
  static State fromValue(int value) {
    switch (value) {
      case 1:
        return State.learning;
      case 2:
        return State.review;
      case 3:
        return State.relearning;
      default:
        throw ArgumentError('Invalid state value: $value');
    }
  }

  final int value;
}

/// {@template fsrs.rating}
/// Enum representing the four possible ratings when reviewing a card.
/// {@endtemplate}
enum Rating {
  again(1),
  hard(2),
  good(3),
  easy(4);

  /// {@macro fsrs.rating}
  const Rating(this.value);

  /// {@macro fsrs.rating}
  static Rating fromValue(int value) {
    switch (value) {
      case 1:
        return Rating.again;
      case 2:
        return Rating.hard;
      case 3:
        return Rating.good;
      case 4:
        return Rating.easy;
      default:
        throw ArgumentError('Invalid rating value: $value');
    }
  }

  final int value;
}

/// {@template fsrs.card}
/// Represents a flashcard in the FSRS system.
/// {@endtemplate}
class Card {
  /// The id of the card. Defaults to the epoch milliseconds of when the card was created.
  final int cardId;

  /// The card's current learning state.
  State state;

  /// The card's current learning or relearning step or null if the card is in the Review state.
  int? step;

  /// Core mathematical parameter used for future scheduling.
  double? stability;

  /// Core mathematical parameter used for future scheduling.
  double? difficulty;

  /// The date and time when the card is due next.
  DateTime due;

  /// The date and time of the card's last review.
  DateTime? lastReview;

  /// {@macro fsrs.card}
  Card({
    required this.cardId,
    this.state = State.learning,
    this.step,
    this.stability,
    this.difficulty,
    DateTime? due,
    this.lastReview,
  }) : due = due ?? DateTime.now().toUtc() {
    if (state == State.learning && step == null) {
      step = 0;
    }
  }

  // The Python original constructor uses time.sleep which can't be used in
  // Dart's constructor.
  // This method is used to create a Card object matching the behavior of the
  // Python original constructor.
  /// {@macro fsrs.card}
  static Future<Card> create({
    State state = State.learning,
    int? step,
    double? stability,
    double? difficulty,
    DateTime? due,
    DateTime? lastReview,
  }) async {
    // epoch milliseconds of when the card was created
    final cardId = DateTime.now().millisecondsSinceEpoch;

    // wait 1ms to prevent potential cardId collision on next Card creation
    await Future.delayed(const Duration(milliseconds: 1));

    return Card(
      cardId: cardId,
      state: state,
      step: step,
      stability: stability,
      difficulty: difficulty,
      due: due,
      lastReview: lastReview,
    );
  }

  @override
  String toString() {
    return 'Card('
        'cardId: $cardId, '
        'state: $state, '
        'step: $step, '
        'stability: $stability, '
        'difficulty: $difficulty, '
        'due: $due, '
        'lastReview: $lastReview)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Card &&
        other.cardId == cardId &&
        other.state == state &&
        other.step == step &&
        other.stability == stability &&
        other.difficulty == difficulty &&
        other.due == due &&
        other.lastReview == lastReview;
  }

  @override
  int get hashCode {
    return Object.hash(
        cardId, state, step, stability, difficulty, due, lastReview);
  }

  /// Returns a JSON-serializable Map representation of the Card object.
  ///
  /// This method is specifically useful for storing Card objects in a database.
  Map<String, dynamic> toMap() {
    return {
      'cardId': cardId,
      'state': state.value,
      'step': step,
      'stability': stability,
      'difficulty': difficulty,
      'due': due.toIso8601String(),
      'lastReview': lastReview?.toIso8601String(),
    };
  }

  /// {@macro fsrs.card}
  ///
  /// Creates a Card object from an existing Map.
  static Card fromMap(Map<String, dynamic> sourceMap) {
    return Card(
      cardId: sourceMap['cardId'] as int,
      state: State.fromValue(sourceMap['state'] as int),
      step: sourceMap['step'] as int?,
      stability: sourceMap['stability'] as double?,
      difficulty: sourceMap['difficulty'] as double?,
      due: DateTime.parse(sourceMap['due'] as String),
      lastReview: sourceMap['lastReview'] != null
          ? DateTime.parse(sourceMap['lastReview'] as String)
          : null,
    );
  }

  /// {@macro fsrs.card}
  ///
  /// Creates a copy of this Card with the given fields replaced with new values.
  Card copyWith({
    int? cardId,
    State? state,
    int? step,
    double? stability,
    double? difficulty,
    DateTime? due,
    DateTime? lastReview,
  }) {
    return Card(
      cardId: cardId ?? this.cardId,
      state: state ?? this.state,
      step: step ?? this.step,
      stability: stability ?? this.stability,
      difficulty: difficulty ?? this.difficulty,
      due: due ?? this.due,
      lastReview: lastReview ?? this.lastReview,
    );
  }
}

/// {@template fsrs.review_log}
/// Represents the log entry of a Card object that has been reviewed.
/// {@endtemplate}
class ReviewLog {
  /// The id of the card being reviewed.
  final int cardId;

  /// The rating given to the card during the review.
  final Rating rating;

  /// The date and time of the review.
  final DateTime reviewDateTime;

  /// The number of milliseconds it took to review the card or null if unspecified.
  final int? reviewDuration;

  /// {@macro fsrs.review_log}
  const ReviewLog({
    required this.cardId,
    required this.rating,
    required this.reviewDateTime,
    this.reviewDuration,
  });

  @override
  String toString() {
    return 'ReviewLog('
        'cardId: $cardId, '
        'rating: $rating, '
        'reviewDateTime: $reviewDateTime, '
        'reviewDuration: $reviewDuration)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReviewLog &&
        other.cardId == cardId &&
        other.rating == rating &&
        other.reviewDateTime == reviewDateTime &&
        other.reviewDuration == reviewDuration;
  }

  @override
  int get hashCode {
    return Object.hash(cardId, rating, reviewDateTime, reviewDuration);
  }

  /// Returns a JSON-serializable Map representation of the ReviewLog object.
  ///
  /// This method is specifically useful for storing ReviewLog objects in a database.
  Map<String, dynamic> toMap() {
    return {
      'cardId': cardId,
      'rating': rating.value,
      'reviewDateTime': reviewDateTime.toIso8601String(),
      'reviewDuration': reviewDuration,
    };
  }

  /// {@macro fsrs.review_log}
  ///
  /// Creates a ReviewLog object from an existing Map.
  static ReviewLog fromMap(Map<String, dynamic> sourceMap) {
    return ReviewLog(
      cardId: sourceMap['cardId'] as int,
      rating: Rating.fromValue(sourceMap['rating'] as int),
      reviewDateTime: DateTime.parse(sourceMap['reviewDateTime'] as String),
      reviewDuration: sourceMap['reviewDuration'] as int?,
    );
  }
}

/// {@template fsrs.scheduler}
/// The FSRS scheduler.
///
/// Enables the reviewing and future scheduling of cards according to the FSRS algorithm.
/// {@endtemplate}
class Scheduler {
  /// The model weights of the FSRS scheduler.
  final List<double> parameters;

  /// The desired retention rate of cards scheduled with the scheduler.
  final double desiredRetention;

  /// Small time intervals that schedule cards in the Learning state.
  final List<Duration> learningSteps;

  /// Small time intervals that schedule cards in the Relearning state.
  final List<Duration> relearningSteps;

  /// The maximum number of days a Review-state card can be scheduled into the future.
  final int maximumInterval;

  /// Whether to apply a small amount of random 'fuzz' to calculated intervals.
  final bool enableFuzzing;

  late final double _decay;
  late final double _factor;

  late math.Random _fuzzRandom;

  /// {@macro fsrs.scheduler}
  Scheduler({
    List<double> parameters = defaultParameters,
    this.desiredRetention = 0.9,
    this.learningSteps = const [
      Duration(minutes: 1),
      Duration(minutes: 10),
    ],
    this.relearningSteps = const [
      Duration(minutes: 10),
    ],
    this.maximumInterval = 36500,
    this.enableFuzzing = true,
  }) : parameters = List<double>.from(parameters) {
    _validateParameters(this.parameters);

    _decay = -this.parameters[20];
    _factor = math.pow(0.9, 1 / _decay) - 1;

    _fuzzRandom = math.Random();
  }

  /// {@macro fsrs.scheduler}
  ///
  /// Creates a Scheduler with custom random number generator.
  ///
  /// This is useful for testing purposes, where you want to control the randomness of the scheduler.
  @visibleForTesting
  factory Scheduler.customRandom(
    math.Random random, {
    List<double> parameters = defaultParameters,
    double desiredRetention = 0.9,
    List<Duration> learningSteps = const [
      Duration(minutes: 1),
      Duration(minutes: 10),
    ],
    List<Duration> relearningSteps = const [
      Duration(minutes: 10),
    ],
    int maximumInterval = 36500,
    bool enableFuzzing = true,
  }) {
    final scheduler = Scheduler(
      parameters: parameters,
      desiredRetention: desiredRetention,
      learningSteps: learningSteps,
      relearningSteps: relearningSteps,
      maximumInterval: maximumInterval,
      enableFuzzing: enableFuzzing,
    );

    scheduler._fuzzRandom = random;

    return scheduler;
  }

  void _validateParameters(List<double> parameters) {
    if (parameters.length != lowerBoundsParameters.length) {
      throw ArgumentError(
          'Expected ${lowerBoundsParameters.length} parameters, got ${parameters.length}.');
    }

    final errorMessages = <String>[];
    for (int i = 0; i < parameters.length; i++) {
      final parameter = parameters[i];
      final lowerBound = lowerBoundsParameters[i];
      final upperBound = upperBoundsParameters[i];

      if (!(lowerBound <= parameter && parameter <= upperBound)) {
        final errorMessage =
            'parameters[$i] = $parameter is out of bounds: ($lowerBound, $upperBound)';
        errorMessages.add(errorMessage);
      }
    }

    if (errorMessages.isNotEmpty) {
      throw ArgumentError('One or more parameters are out of bounds:\n'
          '${errorMessages.join('\n')}');
    }
  }

  @override
  String toString() {
    return 'Scheduler('
        'parameters: $parameters, '
        'desiredRetention: $desiredRetention, '
        'learningSteps: $learningSteps, '
        'relearningSteps: $relearningSteps, '
        'maximumInterval: $maximumInterval, '
        'enableFuzzing: $enableFuzzing)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Scheduler &&
        _listEquals(other.parameters, parameters) &&
        other.desiredRetention == desiredRetention &&
        _listEquals(other.learningSteps, learningSteps) &&
        _listEquals(other.relearningSteps, relearningSteps) &&
        other.maximumInterval == maximumInterval &&
        other.enableFuzzing == enableFuzzing;
  }

  @override
  int get hashCode {
    return Object.hash(
      Object.hashAll(parameters),
      desiredRetention,
      Object.hashAll(learningSteps),
      Object.hashAll(relearningSteps),
      maximumInterval,
      enableFuzzing,
    );
  }

  /// Calculates a Card object's current retrievability for a given date and time.
  ///
  /// The retrievability of a card is the predicted probability that the card is correctly recalled at the provided datetime.
  ///
  /// Args:
  ///   - card: The card whose retrievability is to be calculated
  ///   - currentDateTime: The current date and time
  ///
  /// Returns:
  ///   - The retrievability of the Card object.
  double getCardRetrievability(Card card, {DateTime? currentDateTime}) {
    if (card.lastReview == null) {
      return 0;
    }

    currentDateTime ??= DateTime.now().toUtc();
    final elapsedDays =
        math.max(0, currentDateTime.difference(card.lastReview!).inDays);

    return math
        .pow(1 + _factor * elapsedDays / card.stability!, _decay)
        .toDouble();
  }

  /// Reviews a card with a given rating at a given time for a specified duration.
  ///
  /// Args:
  ///   - [card]: The card being reviewed.
  ///   - [rating]: The chosen rating for the card being reviewed.
  ///   - [reviewDateTime]: The date and time of the review.
  ///   - [reviewDuration]: The number of milliseconds it took to review the card or null if unspecified.
  ///
  /// Returns:
  ///   - A tuple containing the updated, reviewed card and its corresponding review log.
  ///
  /// Throws:
  ///   - ArgumentError: If the [reviewDateTime] argument is not in UTC.
  ({Card card, ReviewLog reviewLog}) reviewCard(
    Card card,
    Rating rating, {
    DateTime? reviewDateTime,
    int? reviewDuration,
  }) {
    if (reviewDateTime != null && !reviewDateTime.isUtc) {
      throw ArgumentError('datetime must be in UTC');
    }

    card = card.copyWith();

    reviewDateTime ??= DateTime.now().toUtc();

    final daysSinceLastReview = card.lastReview != null
        ? reviewDateTime.difference(card.lastReview!).inDays
        : null;

    Duration nextInterval;

    switch (card.state) {
      case State.learning:
        // update the card's stability and difficulty
        if (card.stability == null && card.difficulty == null) {
          card.stability = _initialStability(rating);
          card.difficulty = _initialDifficulty(rating);
        } else if (daysSinceLastReview != null && daysSinceLastReview < 1) {
          card.stability = _shortTermStability(
            stability: card.stability!,
            rating: rating,
          );
          card.difficulty = _nextDifficulty(
            difficulty: card.difficulty!,
            rating: rating,
          );
        } else {
          card.stability = _nextStability(
            difficulty: card.difficulty!,
            stability: card.stability!,
            retrievability:
                getCardRetrievability(card, currentDateTime: reviewDateTime),
            rating: rating,
          );
          card.difficulty = _nextDifficulty(
            difficulty: card.difficulty!,
            rating: rating,
          );
        }

        // calculate the card's next interval
        // first if-clause handles edge case where the Card in the Learning state was previously
        // scheduled with a Scheduler with more learningSteps than the current Scheduler
        if (learningSteps.isEmpty ||
            (card.step! >= learningSteps.length &&
                [Rating.hard, Rating.good, Rating.easy].contains(rating))) {
          card.state = State.review;
          card.step = null;

          final nextIntervalDays = _nextInterval(stability: card.stability!);
          nextInterval = Duration(days: nextIntervalDays);
        } else {
          switch (rating) {
            case Rating.again:
              card.step = 0;
              nextInterval = learningSteps[card.step!];

            case Rating.hard:
              // card step stays the same

              if (card.step == 0 && learningSteps.length == 1) {
                nextInterval = learningSteps[0] * 1.5;
              } else if (card.step == 0 && learningSteps.length >= 2) {
                nextInterval = (learningSteps[0] + learningSteps[1]) ~/ 2;
              } else {
                nextInterval = learningSteps[card.step!];
              }

            case Rating.good:
              if (card.step! + 1 == learningSteps.length) {
                // the last step
                card.state = State.review;
                card.step = null;

                final nextIntervalDays =
                    _nextInterval(stability: card.stability!);
                nextInterval = Duration(days: nextIntervalDays);
              } else {
                card.step = card.step! + 1;
                nextInterval = learningSteps[card.step!];
              }
              break;

            case Rating.easy:
              card.state = State.review;
              card.step = null;

              final nextIntervalDays =
                  _nextInterval(stability: card.stability!);
              nextInterval = Duration(days: nextIntervalDays);
              break;
          }
        }
        break;

      case State.review:
        // update the card's stability and difficulty
        if (daysSinceLastReview != null && daysSinceLastReview < 1) {
          card.stability = _shortTermStability(
            stability: card.stability!,
            rating: rating,
          );
        } else {
          card.stability = _nextStability(
            difficulty: card.difficulty!,
            stability: card.stability!,
            retrievability:
                getCardRetrievability(card, currentDateTime: reviewDateTime),
            rating: rating,
          );
        }

        card.difficulty = _nextDifficulty(
          difficulty: card.difficulty!,
          rating: rating,
        );

        // calculate the card's next interval
        switch (rating) {
          case Rating.again:
            // if there are no relearning steps (they were left blank)
            if (relearningSteps.isEmpty) {
              final nextIntervalDays =
                  _nextInterval(stability: card.stability!);
              nextInterval = Duration(days: nextIntervalDays);
            } else {
              card.state = State.relearning;
              card.step = 0;
              nextInterval = relearningSteps[card.step!];
            }

          case Rating.hard || Rating.good || Rating.easy:
            final nextIntervalDays = _nextInterval(stability: card.stability!);
            nextInterval = Duration(days: nextIntervalDays);
        }

      case State.relearning:
        // update the card's stability and difficulty
        if (daysSinceLastReview != null && daysSinceLastReview < 1) {
          card.stability = _shortTermStability(
            stability: card.stability!,
            rating: rating,
          );
          card.difficulty = _nextDifficulty(
            difficulty: card.difficulty!,
            rating: rating,
          );
        } else {
          card.stability = _nextStability(
            difficulty: card.difficulty!,
            stability: card.stability!,
            retrievability:
                getCardRetrievability(card, currentDateTime: reviewDateTime),
            rating: rating,
          );
          card.difficulty = _nextDifficulty(
            difficulty: card.difficulty!,
            rating: rating,
          );
        }

        // calculate the card's next interval
        // first if-clause handles edge case where the Card in the Relearning state was previously
        // scheduled with a Scheduler with more relearningSteps than the current Scheduler
        if (relearningSteps.isEmpty ||
            (card.step! >= relearningSteps.length &&
                [Rating.hard, Rating.good, Rating.easy].contains(rating))) {
          card.state = State.review;
          card.step = null;

          final nextIntervalDays = _nextInterval(stability: card.stability!);
          nextInterval = Duration(days: nextIntervalDays);
        } else {
          switch (rating) {
            case Rating.again:
              card.step = 0;
              nextInterval = relearningSteps[card.step!];

            case Rating.hard:
              // card step stays the same

              if (card.step == 0 && relearningSteps.length == 1) {
                nextInterval = relearningSteps[0] * 1.5;
              } else if (card.step == 0 && relearningSteps.length >= 2) {
                nextInterval = (relearningSteps[0] + relearningSteps[1]) ~/ 2;
              } else {
                nextInterval = relearningSteps[card.step!];
              }

            case Rating.good:
              if (card.step! + 1 == relearningSteps.length) {
                // the last step
                card.state = State.review;
                card.step = null;

                final nextIntervalDays =
                    _nextInterval(stability: card.stability!);
                nextInterval = Duration(days: nextIntervalDays);
              } else {
                card.step = card.step! + 1;
                nextInterval = relearningSteps[card.step!];
              }

            case Rating.easy:
              card.state = State.review;
              card.step = null;

              final nextIntervalDays =
                  _nextInterval(stability: card.stability!);
              nextInterval = Duration(days: nextIntervalDays);
          }
        }
    }

    if (enableFuzzing && card.state == State.review) {
      nextInterval = _getFuzzedInterval(nextInterval);
    }

    card.due = reviewDateTime.add(nextInterval);
    card.lastReview = reviewDateTime;

    final reviewLog = ReviewLog(
      cardId: card.cardId,
      rating: rating,
      reviewDateTime: reviewDateTime,
      reviewDuration: reviewDuration,
    );

    return (card: card, reviewLog: reviewLog);
  }

  /// Returns a JSON-serializable Map representation of the Scheduler object.
  ///
  /// This method is specifically useful for storing Scheduler objects in a database.
  Map<String, dynamic> toMap() {
    return {
      'parameters': parameters,
      'desiredRetention': desiredRetention,
      'learningSteps': learningSteps.map((step) => step.inSeconds).toList(),
      'relearningSteps': relearningSteps.map((step) => step.inSeconds).toList(),
      'maximumInterval': maximumInterval,
      'enableFuzzing': enableFuzzing,
    };
  }

  /// {@macro fsrs.scheduler}
  ///
  /// Creates a Scheduler object from an existing Map.
  static Scheduler fromMap(Map<String, dynamic> sourceMap) {
    return Scheduler(
      parameters: List<double>.from(sourceMap['parameters']),
      desiredRetention: sourceMap['desiredRetention'] as double,
      learningSteps: (sourceMap['learningSteps'] as List)
          .map((step) => Duration(seconds: step as int))
          .toList(),
      relearningSteps: (sourceMap['relearningSteps'] as List)
          .map((step) => Duration(seconds: step as int))
          .toList(),
      maximumInterval: sourceMap['maximumInterval'] as int,
      enableFuzzing: sourceMap['enableFuzzing'] as bool,
    );
  }

  double _clampDifficulty(double difficulty) {
    return difficulty.clamp(minDifficulty, maxDifficulty);
  }

  double _clampStability(double stability) {
    return math.max(stability, stabilityMin);
  }

  double _initialStability(Rating rating) {
    var initialStability = parameters[rating.value - 1];

    initialStability = _clampStability(initialStability);

    return initialStability;
  }

  double _initialDifficulty(Rating rating) {
    var initialDifficulty =
        parameters[4] - (math.exp(parameters[5] * (rating.value - 1))) + 1;

    initialDifficulty = _clampDifficulty(initialDifficulty);

    return initialDifficulty;
  }

  int _nextInterval({required double stability}) {
    num nextInterval =
        (stability / _factor) * (math.pow(desiredRetention, 1 / _decay) - 1);

    nextInterval = nextInterval.round(); // intervals are full days

    // must be at least 1 day long
    nextInterval = math.max(nextInterval, 1);

    // can not be longer than the maximum interval
    nextInterval = math.min(nextInterval, maximumInterval);

    return nextInterval.toInt();
  }

  double _shortTermStability(
      {required double stability, required Rating rating}) {
    var shortTermStabilityIncrease =
        math.exp(parameters[17] * (rating.value - 3 + parameters[18])) *
            math.pow(stability, -parameters[19]);

    if ([Rating.good, Rating.easy].contains(rating)) {
      shortTermStabilityIncrease = math.max(shortTermStabilityIncrease, 1.0);
    }

    var shortTermStability = stability * shortTermStabilityIncrease;

    shortTermStability = _clampStability(shortTermStability);

    return shortTermStability;
  }

  double _nextDifficulty({required double difficulty, required Rating rating}) {
    double _linearDamping(
        {required double deltaDifficulty, required double difficulty}) {
      return (10.0 - difficulty) * deltaDifficulty / 9.0;
    }

    double _meanReversion({required double arg1, required double arg2}) {
      return parameters[7] * arg1 + (1 - parameters[7]) * arg2;
    }

    final arg1 = _initialDifficulty(Rating.easy);

    final deltaDifficulty = -(parameters[6] * (rating.value - 3));
    final arg2 = difficulty +
        _linearDamping(
            deltaDifficulty: deltaDifficulty, difficulty: difficulty);

    var nextDifficulty = _meanReversion(arg1: arg1, arg2: arg2);

    nextDifficulty = _clampDifficulty(nextDifficulty);

    return nextDifficulty;
  }

  double _nextStability({
    required double difficulty,
    required double stability,
    required double retrievability,
    required Rating rating,
  }) {
    double nextStability;

    if (rating == Rating.again) {
      nextStability = _nextForgetStability(
        difficulty: difficulty,
        stability: stability,
        retrievability: retrievability,
      );
    } else {
      nextStability = _nextRecallStability(
        difficulty: difficulty,
        stability: stability,
        retrievability: retrievability,
        rating: rating,
      );
    }

    nextStability = _clampStability(nextStability);

    return nextStability;
  }

  double _nextForgetStability({
    required double difficulty,
    required double stability,
    required double retrievability,
  }) {
    final nextForgetStabilityLongTermParams = parameters[11] *
        math.pow(difficulty, -parameters[12]) *
        (math.pow((stability + 1), (parameters[13])) - 1) *
        math.exp((1 - retrievability) * parameters[14]);

    final nextForgetStabilityShortTermParams =
        stability / math.exp(parameters[17] * parameters[18]);

    return math.min(
      nextForgetStabilityLongTermParams,
      nextForgetStabilityShortTermParams,
    );
  }

  double _nextRecallStability({
    required double difficulty,
    required double stability,
    required double retrievability,
    required Rating rating,
  }) {
    final hardPenalty = rating == Rating.hard ? parameters[15] : 1.0;
    final easyBonus = rating == Rating.easy ? parameters[16] : 1.0;

    return stability *
        (1 +
            math.exp(parameters[8]) *
                (11 - difficulty) *
                math.pow(stability, -parameters[9]) *
                (math.exp((1 - retrievability) * parameters[10]) - 1) *
                hardPenalty *
                easyBonus);
  }

  /// Takes the current calculated interval and adds a small amount of random fuzz to it.
  /// For example, a card that would've been due in 50 days, after fuzzing, might be due in 49, or 51 days.
  ///
  /// Args:
  ///   - interval: The calculated next interval, before fuzzing.
  ///
  /// Returns:
  ///   - The new interval, after fuzzing.
  Duration _getFuzzedInterval(Duration interval) {
    final intervalDays = interval.inDays;

    // fuzz is not applied to intervals less than 2.5
    if (intervalDays < 2.5) {
      return interval;
    }

    /// Helper function that computes the possible upper and lower bounds of the interval after fuzzing.
    (int minIvL, int maxIvL) getFuzzRange(int intervalDays) {
      var delta = 1.0;
      for (final fuzzRange in fuzzRanges) {
        delta += fuzzRange['factor']! *
            math.max(
              math.min(intervalDays, fuzzRange['end']!) - fuzzRange['start']!,
              0.0,
            );
      }

      var minIvL = (intervalDays - delta).round().toInt();
      var maxIvL = (intervalDays + delta).round().toInt();

      // make sure the minIvL and maxIvL fall into a valid range
      minIvL = math.max(2, minIvL);
      maxIvL = math.min(maxIvL, maximumInterval);
      minIvL = math.min(minIvL, maxIvL);

      return (minIvL, maxIvL);
    }

    final (minIvL, maxIvL) = getFuzzRange(intervalDays);

    num fuzzedIntervalDays = (_fuzzRandom.nextDouble() *
            (maxIvL - minIvL + 1)) +
        minIvL; // the next interval is a random value between minIvL and maxIvL

    fuzzedIntervalDays = math.min(fuzzedIntervalDays.round(), maximumInterval);

    final fuzzedInterval = Duration(days: fuzzedIntervalDays.toInt());

    return fuzzedInterval;
  }
}

// Dart's Utils section
// This section contains utility functions that are not part of the main
// repository

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
