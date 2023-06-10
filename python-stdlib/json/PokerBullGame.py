
from .utils import Init_deck, sort_cards_from_high_to_low
import itertools

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

        
class PokerBullGame:

    @classmethod
    def calResult(self, cardArray, playerNum):
        deck = Init_deck(cardArray)
        winners = self.calWinners(deck, playerNum)


        return winners
    
    @classmethod
    def calWinners(self, deck, playerNum):
        allPlayers = [Player(i) for i in range(playerNum)]

        for i in range(playerNum * 5):
            allPlayers[i % playerNum].Insert_card(deck[i])       

        for player in allPlayers:
            player.evaluate_hand_cards()
        
        return [sorted(allPlayers, key=lambda x:x.evaluate_flag, reverse=True)[0].playerID]

class HandEvaluator:
    # 

    NULLBULL = 1
    ONEBULL = 2
    BULLBULL = 3
    SILVERBULL = 4
    GOLDBULL = 5
    BOMB = 7
    FIVELITTLE = 6

    # result[flag, rank1,rank2...rank5]
    # rank-> 01 0010 club2

    # card = [(int,int), (int, int)...]
    # return flag 
    @classmethod
    def evaluate(self, cards):

        funcList = [self.Is_Bomb, self.Is_FiveLittle, self.Is_goldbull, self.Is_silverbull, self.Is_bull]

        for func in funcList:
            flag, rank = func(cards)
            if flag == 0:
                continue
            else:
                eval = 1<<(8 + flag - 1) | rank 
                print(eval)
                return eval


    @classmethod
    def Is_bull(self, cards):
        bulls = []
        bull_rank = 0

        # find out all bull
        for combination in itertools.combinations(cards, 3):
            sum_of_combinations = 0
            for item in combination:
                if item.rank > 10:
                    sum_of_combinations += 10
                else:
                    sum_of_combinations += item.rank
            if sum_of_combinations % 10 == 0:
                bulls.append(combination)
        # if no bull
        if len(bulls) == 0:
            return self.NULLBULL, self.rank_for_max_card(cards)
        
        for bull in bulls:
            other_cards = [card for card in cards if card not in bull]
            cards_rank = 0
            for item in other_cards:
                if(item.rank > 10):
                    cards_rank += 10
                else:
                    cards_rank += item.rank
            cards_rank = cards_rank % 10
            # if bull,bull
            if cards_rank == 0:
                return self.BULLBULL, self.rank_for_max_card(cards)
            if cards_rank > bull_rank:
                bull_rank = cards_rank

        return self.ONEBULL, bull_rank << 4 | self.rank_for_max_card(cards)
        
    @classmethod
    def Is_silverbull(self,cards):
        count = 0
        for card in cards:
            if card.rank < 10:
                return 0, 0
            if card.rank == 10:
                count += 1
            if count > 1:
                return 0, 0
        rank = self.rank_for_max_card(cards)
        return self.SILVERBULL, rank
    @classmethod
    def Is_goldbull(self,cards):
        count = 0
        for card in cards:
            if card.rank > 10:
                count += 1
        if count == 5:
            rank = self.rank_for_max_card(cards)
            return self.GOLDBULL, rank
        
        return 0, 0
    
    @classmethod
    def Is_Bomb(self, cards):
        counts = {}
        for card in cards:

            counts[card.rank] = counts.get(card.rank, 0) + 1
            if counts[card.rank] == 4:
                return self.BOMB, card.rank
        return 0, 0
    
    @classmethod
    def Is_FiveLittle(self, cards):
        if(sum(card.rank for card in cards) > 10): return 0, 0
        for card in cards:
            if(card.rank > 5):
                return 0, 0
            
        rank = self.rank_for_max_card(cards)
        return self.FIVELITTLE, rank
    
    def rank_for_max_card(cards):
        sorted_cards = sort_cards_from_high_to_low(cards)
        rank = sorted_cards[0].score
        return rank
