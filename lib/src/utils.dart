import './models.dart';

void printSchedulingCards(Map<Rating, SchedulingInfo> schedulingCards) {
  print("again.card: ${schedulingCards[Rating.again]?.card}");
  print("again.reviewLog: ${schedulingCards[Rating.again]?.reviewLog}");
  print("hard.card: ${schedulingCards[Rating.hard]?.card}");
  print("hard.reviewLog: ${schedulingCards[Rating.hard]?.reviewLog}");
  print("good.card: ${schedulingCards[Rating.good]?.card}");
  print("good.reviewLog: ${schedulingCards[Rating.good]?.reviewLog}");
  print("easy.card: ${schedulingCards[Rating.easy]?.card}");
  print("easy.reviewLog: ${schedulingCards[Rating.easy]?.reviewLog}");
  print("");
}
