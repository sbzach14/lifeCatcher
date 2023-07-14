class Card:
    def __init__(self, suit, rank):
        self.suit = suit
        self.rank = rank

    @classmethod
    def cal_score(self, card):
        if type(card.suit) == int:
            return card.rank *10 + card.suit
        else:
            return card.rank *10 + max(card.suit.max)
