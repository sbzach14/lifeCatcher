import itertools
from utils import sort_cards_from_high_to_low

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
            print("没牛")
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
                print("牛牛")
                return self.BULLBULL, self.rank_for_max_card(cards)
            if cards_rank > bull_rank:
                bull_rank = cards_rank
        print("牛" + str(bull_rank))

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
        print("银牛")
        return self.SILVERBULL, rank
    @classmethod
    def Is_goldbull(self,cards):
        count = 0
        for card in cards:
            if card.rank > 10:
                count += 1
        if count == 5:
            rank = self.rank_for_max_card(cards)
            print("金牛")
            return self.GOLDBULL, rank
        
        return 0, 0
    
    @classmethod
    def Is_Bomb(self, cards):
        counts = {}
        for card in cards:

            counts[card.rank] = counts.get(card.rank, 0) + 1
            if counts[card.rank] == 4:
                print("炸弹！")
                return self.BOMB, card.rank
        return 0, 0
    
    @classmethod
    def Is_FiveLittle(self, cards):
        if(sum(card.rank for card in cards) > 10): return 0, 0
        for card in cards:
            if(card.rank > 5):
                return 0, 0
            
        rank = self.rank_for_max_card(cards)
        print("五小!")
        return self.FIVELITTLE, rank
    
    def rank_for_max_card(cards):
        sorted_cards = sort_cards_from_high_to_low(cards)
        rank = sorted_cards[0].score
        return rank
    


