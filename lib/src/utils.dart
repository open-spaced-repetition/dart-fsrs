import './models.dart';

void printSchedulingCards(Map<Rating, SchedulingInfo> schedulingCards) {
  print("again.card: ${schedulingCards[Rating.Again]?.card}");
  print("again.reviewLog: ${schedulingCards[Rating.Again]?.reviewLog}");
  print("hard.card: ${schedulingCards[Rating.Hard]?.card}");
  print("hard.reviewLog: ${schedulingCards[Rating.Hard]?.reviewLog}");
  print("good.card: ${schedulingCards[Rating.Good]?.card}");
  print("good.reviewLog: ${schedulingCards[Rating.Good]?.reviewLog}");
  print("easy.card: ${schedulingCards[Rating.Easy]?.card}");
  print("easy.reviewLog: ${schedulingCards[Rating.Easy]?.reviewLog}");
  print("");
}
