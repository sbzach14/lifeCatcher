class HandEvaluator:

  @classmethod
  def eval_hand(self, cards):
    score = 0
    num1 = cards[0].rank
    num2 = cards[1].rank
    if num1 == num2:
        score = num1 + 100
    else:
        score = (num1 + num2) % 10
    return score