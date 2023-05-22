


class GameBase:
    CardDic = {
    0: 'A',
    1: '2',
    2: '3',
    3: '4',
    4: '5',
    5: '6',
    6: '7',
    7: '8',
    8: '9',
    9: '10',
    10: 'J',
    11: 'Q',
    12: 'K'
    }
    players = []
    player_num = 0
    cards = []
    # initial_cards: [card_index->int], player_num: number of player->int
    def __init__(self, initial_cards, player_num) -> None:
        self.player_num = player_num
        self.cards = initial_cards
        self.players = [Player() for i in range(player_num)]
        for i in range(len(self.cards)):
            self.players[i % player_num].insertCards(self.CardDic[self.cards % 14])  
        return

    # return the deck info we want
    def return_winner(self):

        return


class Player:
    cardsDic = {
        'A': 0,
        'K': 0,
        'Q': 0,
        'J': 0,
        '10': 0,
        '9': 0,
        '8': 0,
        '7': 0,
        '6': 0,
        '5': 0,
        '4': 0,
        '3': 0,
        '2': 0
    }
    
    def insertCards(self, card_name):
        # 实现插入卡牌的逻辑
        self.cardsDic[card_name] += 1
        

                  
             
             



                