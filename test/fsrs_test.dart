import 'package:fsrs/fsrs.dart';
import 'package:test/test.dart';

const testW = [
  0.4197,
  1.1869,
  3.0412,
  15.2441,
  7.1434,
  0.6477,
  1.0007,
  0.0674,
  1.6597,
  0.1712,
  1.1178,
  2.0225,
  0.0904,
  0.3025,
  2.1214,
  0.2498,
  2.9466,
  0.4891,
  0.6468,
];

void main() {
  test('Review Card', () {
    final f = FSRS(w: testW);
    var card = Card();
    var now = DateTime.utc(2022, 11, 29, 12, 30);

    const ratings = [
      Rating.good,
      Rating.good,
      Rating.good,
      Rating.good,
      Rating.good,
      Rating.good,
      Rating.again,
      Rating.again,
      Rating.good,
      Rating.good,
      Rating.good,
      Rating.good,
      Rating.good,
    ];

    List<int> ivlHistory = [];

    for (final rating in ratings) {
      final reviewCard = f.reviewCard(card, rating, now);
      card = reviewCard.card;
      final ivl = card.scheduledDays;
      ivlHistory.add(ivl);
      now = card.due;
    }

    expect(ivlHistory, [
      0,
      4,
      17,
      62,
      198,
      563,
      0,
      0,
      9,
      27,
      74,
      190,
      457,
    ]);
  });

  test('Memo State', () {
    final f = FSRS(w: testW);
    var card = Card();
    var now = DateTime.utc(2022, 11, 29, 12, 30);

    var schedulingCards = f.repeat(card, now);
    const reviews = [
      (Rating.again, 0),
      (Rating.good, 0),
      (Rating.good, 1),
      (Rating.good, 3),
      (Rating.good, 8),
      (Rating.good, 21),
    ];

    for (final (rating, ivl) in reviews) {
      card = schedulingCards[rating]!.card;
      now = now.add(Duration(days: ivl));
      schedulingCards = f.repeat(card, now);
    }

    expect(schedulingCards[Rating.good]!.card.stability, 71.4554);
    expect(schedulingCards[Rating.good]!.card.difficulty, 5.0976);
  });

  test('Default Arg', () {
    final f = FSRS();

    var card = Card();

    final schedulingCards = f.repeat(card);

    final cardRating = Rating.good;

    card = schedulingCards[cardRating]!.card;

    final due = card.due;

    final timeDelta = due.difference(DateTime.now().toUtc());

    expect(timeDelta.inSeconds, greaterThan(500));
  });

  group("Custom Scheduler Args:", () {
    const ratings = [
      Rating.good,
      Rating.good,
      Rating.good,
      Rating.good,
      Rating.good,
      Rating.good,
      Rating.again,
      Rating.again,
      Rating.good,
      Rating.good,
      Rating.good,
      Rating.good,
      Rating.good,
    ];

    test('IVL', () {
      final f = FSRS(
        requestRetention: 0.9,
        maximumInterval: 36500,
        w: [
          0.4197,
          1.1869,
          3.0412,
          15.2441,
          7.1434,
          0.6477,
          1.0007,
          0.0674,
          1.6597,
          0.1712,
          1.1178,
          2.0225,
          0.0904,
          0.3025,
          2.1214,
          0.2498,
          2.9466,
          0,
          0.6468,
        ],
      );

      var card = Card();
      var now = DateTime(2022, 11, 29, 12, 30);
      final List<int> ivlHistory = [];

      for (final rating in ratings) {
        final reviewCard = f.reviewCard(card, rating, now);
        card = reviewCard.card;
        final ivl = card.scheduledDays;
        ivlHistory.add(ivl);
        now = card.due;
      }

      expect(ivlHistory, [0, 3, 13, 50, 163, 473, 0, 0, 12, 34, 91, 229, 541]);
    });

    test('Verify parameters', () {
      const requestRetention = 0.85;
      const maximumInterval = 3650;
      const w = [
        0.1456,
        0.4186,
        1.1104,
        4.1315,
        5.2417,
        1.3098,
        0.8975,
        0.0000,
        1.5674,
        0.0567,
        0.9661,
        2.0275,
        0.1592,
        0.2446,
        1.5071,
        0.2272,
        2.8755,
        1.234,
        5.6789,
      ];

      final f = FSRS(
        requestRetention: requestRetention,
        maximumInterval: maximumInterval,
        w: w,
      );

      var card = Card();
      var now = DateTime.utc(2022, 11, 29, 12, 30);
      final List<int> ivlHistory = [];

      for (final rating in ratings) {
        final reviewCard = f.reviewCard(card, rating, now);
        card = reviewCard.card;
        final ivl = card.scheduledDays;
        ivlHistory.add(ivl);
        now = card.due;
      }

      expect(f.p.w, w);
      expect(f.p.requestRetention, requestRetention);
      expect(f.p.maximumInterval, maximumInterval);
    });
  });

  test('DateTime', () {
    final f = FSRS();
    var card = Card();

    expect(DateTime.now().compareTo(card.due), greaterThanOrEqualTo(0));

    final schedulingCards = f.repeat(card, DateTime.now().toUtc());
    card = schedulingCards[Rating.good]!.card;

    expect(card.due.compareTo(card.lastReview), greaterThanOrEqualTo(0));
  });

  test('Card Serialization', () {
    // TODO
  });

  test('ReviewLog Serialization', () {
    // TODO
  });
}
