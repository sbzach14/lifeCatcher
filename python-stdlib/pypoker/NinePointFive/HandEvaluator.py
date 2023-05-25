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
