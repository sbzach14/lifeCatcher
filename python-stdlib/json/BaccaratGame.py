from .utils import Init_deck


class BaccaratGame:

    @classmethod
    def calResult(self, cards, playerNum):

        deck = Init_deck(cards)
        winners = self.calWinners(deck)

        return winners
    # 0,Banker  1,Player  2,Draw
    @classmethod
    def calWinners(self, deck):

        for card in deck:
            if card.rank >= 10:
                card.rank = 0
        

        Banker_cards = [deck[1], deck[3]]
        Player_cards = [deck[0], deck[2]]

        Banker_points = sum(card.rank for card in Banker_cards) % 10
        Player_points = sum(card.rank for card in Player_cards) % 10
        # Natural
        if Banker_points >= 8 and Player_points >= 8:
            if(Banker_points > Player_points):
                return[0]
            elif(Banker_points < Player_points):
                return[1]
            else:
                return[2]

        # Player Hit
        if Player_points < 6:
            player_hit_card = deck[4]
            Player_cards.append(player_hit_card)

            if Banker_points <= 2:
                banker_hit_card = deck[5]
                Banker_cards.append(banker_hit_card)
            elif Banker_points == 3 and player_hit_card.rank != 8:
                banker_hit_card = deck[5]
                Banker_cards.append(banker_hit_card)
            elif Banker_points == 4 and player_hit_card.rank > 1 and player_hit_card.rank < 8:
                banker_hit_card = deck[5]
                Banker_cards.append(banker_hit_card)
            elif Banker_points == 5 and player_hit_card.rank > 3 and player_hit_card.rank < 8:
                banker_hit_card = deck[5]
                Banker_cards.append(banker_hit_card)
            elif Banker_points == 6 and player_hit_card.rank > 5 and player_hit_card.rank < 8: 
                banker_hit_card = deck[5]
                Banker_cards.append(banker_hit_card)
        else:
            if Banker_points < 6:
                banker_hit_card = deck[5]
                Banker_cards.append(banker_hit_card)

        Banker_points = sum(card.rank for card in Banker_cards) % 10
        Player_points = sum(card.rank for card in Player_cards) % 10
        


        if(Banker_points > Player_points):
            return[0]
        elif(Banker_points < Player_points):
            return[1]
        else:
            return[2]


               



        


            



        
