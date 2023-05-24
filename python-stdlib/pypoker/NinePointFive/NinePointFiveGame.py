from NinePointFive.HandEvaluator import HandEvaluator
from utils import Init_deck

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