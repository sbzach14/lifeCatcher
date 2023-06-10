class Card:
    def __init__(self, suit, rank):
        self.suit = suit
        self.rank = rank

    @classmethod
    def cal_score(self, card):
        return card.rank << 2 | card.suit
