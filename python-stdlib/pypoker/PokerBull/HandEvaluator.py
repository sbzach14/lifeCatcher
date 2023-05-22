import itertools
from utils import sort_cards_from_low_to_high

class HandEvaluator:
    # 

    NULLBULL = 0
    ONEBULL = 1
    BULLBULL = 2
    SILVERBULL = 3
    GOLDBULL = 4
    BOMB = 6
    FIVELITTLE = 5

    # result[flag, rank1,rank2...rank5]
    # rank-> 01 0010 club2

    # card = [(int,int), (int, int)...]
    # return flag 
    @classmethod
    def evaluate(self, cards):
        

        return eval



    @classmethod
    def Is_bull(self, cards):
        bulls = []
        bull_rank = 0

        # find out all bull
        for combination in itertools.combinations(cards, 3):
            sum_of_cards = sum(item[1] for item in combination)
            if sum_of_cards % 10 == 0:
                bulls.append(combination)
        # no bull
        if len(bulls) == 0:
            return self.NULLBULL, self.rank_for_suit_number(cards)
        
        for bull in bulls:
            other_cards = [card for card in cards if card not in bull]
            cards_rank = sum(item[1] for item in other_cards) % 10
            # bull,bull
            if cards_rank == 0:
                return self.BULLBULL, self.rank_for_suit_number(cards)
            if cards_rank > bull_rank:
                bull_rank = cards_rank

        return self.ONEBULL, bull_rank
        
    @classmethod
    def Is_silverbull(self,cards):
        count = 0
        for _, num in cards:
            if num < 10:
                return 0, 0
            if num == 10:
                count += 1
            if count > 1:
                return 0, 0
        rank = self.rank_for_suit_number(cards)
        return self.SILVERBULL, rank
    @classmethod
    def Is_goldbull(self,cards):
        count = 0
        for card in cards:
            _, num = card
            if num > 10:
                count += 1
        if count == 5:
            rank = self.rank_for_suit_number(cards)
            return self.GOLDBULL, rank
        
        return 0, 0
    
    @classmethod
    def Is_Bomb(self, cards):
        counts = {}
        for card in cards:
            _, num = card
            counts[num] = counts.get(num, 0) + 1
            if counts[num] == 4:

                return self.BOMB, num
        return 0, 0
    
    def is_FiveLittle(self, cards):
        if(sum(card[1] for card in cards) > 10): return False
        for card in cards:
            if(card[1] > 5):
                return 0, 0
            
        rank = self.rank_for_suit_number(cards)
        
        return self.FIVELITTLE, rank
    
    def rank_for_suit_number(cards):
        sorted_cards = sort_cards_from_low_to_high(cards)
        rank = 0
        for index in range(sorted_cards):
            card = sorted_cards[index]
            suit = card[0]
            number = card[1]
            current_card_rank = suit<<2 | number
            rank = rank | current_card_rank << (index << 2)
        
        return rank

    


