from ThreeToy.HandEvaluator import HandEvaluator
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
        


class ThreeToyGame:

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
        for card_cnt in range(3):
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
        