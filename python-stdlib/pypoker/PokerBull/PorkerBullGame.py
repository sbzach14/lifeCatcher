from HandEvaluator import HandEvaluator

class Player:

    # Card format[(int suitNumber(0-3), int number(1-13))
    def __init__(self) -> None:
        self.player_card = []
        self.evaluate_flag = 0

    @classmethod
    def Insert_card(self, card):
        self.player_card.append(card)

    def evaluate_hand_cards(self):
        self.evaluate_flag = HandEvaluator.evaluate(self.player_card)
        


class PokerBullGame:

    @classmethod
    def __init__(self, initial_cards, player_num) -> None:
        round = 1
        self.cards = []
        self.players = []
        self.player_num = player_num
        self.cards = initial_cards
        self.players = [Player() for i in range(player_num)]

        for i in range(self.cards):
            card_index = self.cards[i]

            card = self.pack_card(card_index)
            self.players[i % player_num].Insert_card(card)
            if round > 5:
                return
            round += 1
    
    @classmethod
    def pack_card(self, card_index):
        return (card_index // 13, card_index % 13 + 1)
    
    @classmethod
    def return_winner(self):
        for player in self.players:
            player.evaluate_hand_cards()
        




        return
        