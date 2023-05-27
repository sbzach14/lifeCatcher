from NinePointFive.HandEvaluator import HandEvaluator
from .utils import Init_deck

class Player:

    # Card format[(int suitNumber(0-3), int number(1-13))
    def __init__(self, playerIndex) -> None:
        self.playerID = playerIndex
        self.player_card = []
        self.evaluate_flag = 0

    def Insert_card(self, card):
        self.player_card.append(card)

    def evaluate_hand_cards(self):
        self.evaluate_flag = HandEvaluator.evaluate(self.player_card)

class NinePointFiveGame:

    @classmethod
    def calResult(self, cardArray, playerNum):
        deck = Init_deck(cardArray)
        winners = self.calWinners(deck, playerNum)

        return winners
    
    @classmethod
    def calWinners(self, deck, playerNum):
        allPlayers = [Player(i) for i in range(playerNum)]

        for i in range(playerNum * 2):
            allPlayers[i % playerNum].Insert_card(deck[i])       

        for player in allPlayers:
            player.evaluate_hand_cards()
        
        return [sorted(allPlayers, key=lambda x:x.evaluate_flag, reverse=True)[0].playerID]


class HandEvaluator:
    
    

    NULL = 1
    NINEPOINTFIVE = 3
    PAIR = 2
    KINGPAIR = 4


    @classmethod
    def evaluate(self, cards):
        for card in cards:
            if card.rank > 13:
                card.rank = 1
            else: card.rank = card.rank * 2
        functionList = [self.Is_kingpair, self.Is_NinePointFive, self.Is_pair]

        for func in functionList:
            flag, rank = func(cards)
            if flag == 0:
                continue
            else: 
                eval = 1<<(4 + flag - 1) | rank
                print(eval)
                return eval
        return
    @classmethod
    def Is_NULL(self, cards):
        return self.NULL, int((cards[0] + cards[1]) / 2) % 10


    @classmethod
    def Is_pair(self, cards):
        if cards[0].rank == cards[1].rank:
            return self.PAIR, 0
        return 0, 0
    

    @classmethod
    def Is_kingpair(self, cards):
        if cards[0].rank == cards[1].rank == 1:
            return self.KINGPAIR, 0
        return 0, 0

    @classmethod
    def Is_NinePointFive(self, cards):
        if cards[0].rank + cards[1].rank == 19:
            return self.NINEPOINTFIVE,0
        return 0,0
