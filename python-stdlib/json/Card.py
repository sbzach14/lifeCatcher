class Card:
    def __init__(self, suit, rank):
        self.suit = suit
        self.rank = rank
        self.score = self.rank << 2 | self.suit