from utils import Init_deck

class Player:
    # Card format[(int suitNumber(0-3), int number(1-13))
    def __init__(self) -> None:
        self.player_card = []
        self.evaluate_flag = 0

    def Insert_card(self, card):
        self.player_card.append(card)

    def evaluate_hand_cards(self):
        self.evaluate_flag = HandEvaluator.eval_hand(self.player_card)
        

class TwoEightGangGame:

    @classmethod
    def calResult(self, cardArray, playerNum):
        deck = Init_deck(cardArray)
        winners = self.calWinners(deck, playerNum)
                
        return winners

    @classmethod
    def calWinners(self, deck, playerNum):
        maxRank = -1
        winners = []
        allPlayCards = []
        for i in range(playerNum):
            allPlayCards.append(Player())
        
        #发牌
        for i in range(playerNum):
            allPlayCards[i].Insert_card(deck.pop(0))
        for i in range(playerNum):
            allPlayCards[i].Insert_card(deck.pop(0))

        for i in range(playerNum):
            allPlayCards[i].evaluate_hand_cards()

        for i in range(playerNum):
            rank = allPlayCards[i].evaluate_flag
            if rank > maxRank:
                maxRank = rank
                winners.clear()
                winners.append(i)
            elif rank == maxRank:
                winners.append(i)

        return winners
    

class HandEvaluator:

  @classmethod
  def eval_hand(self, cards):
    score = 0
    num1 = cards[0].rank
    num2 = cards[1].rank
    if num1 == num2:
        score = num1 + 100
    elif num1 == 2 and num2 == 8:
        score = 100
    elif num1 == 8 and num2 == 2:
        score = 100
    else:
        score = (num1 + num2) % 10
    return score