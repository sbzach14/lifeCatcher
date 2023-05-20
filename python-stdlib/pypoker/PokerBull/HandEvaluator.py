import itertools

class HandEvaluator:
    # 

    NULLBULL = 0
    ONEBULL = 1
    BULLBULL = 2
    SILVERBULL = 3
    GOLDBULL = 4
    BOMB = 5
    FIVELITTLE = 6

    rank = 1

    # card = [(int,int), (int, int)...]
    @classmethod
    def evaluate(self, cards):
        if self.Is_bull(cards): return self.ONEBULL, self.rank
        if self.Is_silverbull(cards): return self.SILVERBULL, self.rank
        if self.Is_goldbull(cards): return self.GOLDBULL, self.rank
        if self.Is_Bomb(cards): return self.BOMB, self.rank
        if self.is_FiveLittle(cards): return self.FIVELITTLE, self.rank

    @classmethod
    def Is_bull(self, cards):
        bulls = []

        # find out all bull
        for combination in itertools.combinations(cards, 3):
            sum_of_cards = sum(item[1] for item in combination)
            if sum_of_cards % 10 == 0:
                bulls.append(combination)
        
        if len(bulls) == 0:
            return False
        
        for bull in bulls:
            other_cards = [card for card in cards if card not in bull]
            cards_rank = sum(item[1] for item in other_cards) % 10
            if cards_rank > self.rank:
                self.rank = cards_rank
        return True
        
    @classmethod
    def Is_silverbull(self,cards):
        count = 0
        for _, num in cards:
            if num < 10:
                return False
            if num == 10:
                count += 1
            if count > 1:
                return False
        return True
    @classmethod
    def Is_goldbull(self,cards):
        count = 0
        for card in cards:
            _, num = card
            if num > 10:
                count += 1
        if count == 5:
            return True
        return False
    @classmethod
    def Is_Bomb(self, cards):
        counts = {}
        for card in cards:
            _, num = card
            counts[num] = counts.get(num, 0) + 1
            if counts[num] == 4:
                self.rank = num
                return True
        return False
    def is_FiveLittle(self, cards):
        if(sum(card[1] for card in cards) > 10): return False
        for card in cards:
            if(card[1] > 5):
                return False
    
        return True


