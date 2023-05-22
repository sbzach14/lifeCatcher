from utils import Init_deck
from TinyNine.HandEvaluator import HandEvaluator

class Player:
    # Card format[(int suitNumber(0-3), int number(1-13))
    def __init__(self) -> None:
        self.player_card = []
        self.evaluate_flag = 0

    def Insert_card(self, card):
        self.player_card.append(card)

    def evaluate_hand_cards(self):
        self.evaluate_flag = HandEvaluator.eval_hand(self.player_card)
        

class TinyNineGame:

    @classmethod
    def calResult(self, cardArray, playerNum, targetPlayerIndex, dealerPlayerIndex):
        deck = Init_deck(cardArray)
        target_cut = -1
        for i in range(len(deck)):
            deck_bot = deck[0:i]
            deck_top = deck[i:-1]
            new_deck = deck_top + deck_bot
            winners = self.calWinners(new_deck, playerNum)
            
            if targetPlayerIndex == dealerPlayerIndex:
                if targetPlayerIndex in winners:
                    target_cut = i
                    break
            else:
                if targetPlayerIndex in winners and len(winners) == 1:
                    target_cut = i
                    break
                
        return target_cut

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

