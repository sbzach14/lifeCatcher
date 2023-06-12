
from .utils import Init_deck, sort_cards_from_high_to_low
import itertools

# UI STRUCTURE TO ARGUMENT VALUE
# number of cards -> int value: 
# 0: 20, 1: 32, 2: 36, 3: 40, 4: 42, 5: 52, 6: 54

# way to deal cards -> int value:
# 0, normal dealing, 5 cards each
# 1, one card each for the first round and begin from the largest card
# 2, normal dealing, 3 cards each
# 3, normal dealing, 4 cards each
# 4, normal dealing, 10 cards each

# if card number change -> int Array:
# 0, 10 -> 0, 1, 1/0
# 1, J -> 0, 1, 11
# 2, Q -> 0, 1, 2, 12
# 3, K -> 0, 1, 6, 13
# 4, BLACKJoker ->0, 1, 3, any
# 5, REDJOKER ->0, 1, 6, any
# 6, 3 -> 3, 3/6
# 7, 6 -> 6, 3/6
# 8, Spade A -> 1, 0



# Bull Rule for dealing 0, 1 -> int Array 0->no 1->yes:
# 0, any three cards equal to 10 * n
# 1, total five cards equal to 10 * n
# 2, Threecard
# 3, thress card straight 
# 4, only contains J,K,Q,A,JOKER is BULLBULL
# 5, Three cards equal to 1
# 6, Five cards sum <= 10 (sum is the Bull number, exp. 1,2,2,2,1 牛8)
# 7, five cards sum <= 9
# 8, any three cards equal to 10 * n and at least > 20

# Rank Rule for dealing 0, 1, 4-> int Array
# 0, five cards sum >= 40
# 1, Fourcard
# 2, five cards sum <= 10
# 3, five cards sum == 20 and have bull
# 4, five cards sum == 30 and have bull
# 5, Threecard and other two sum == 10
# 6, five cards sum == 20 or 30
# 7, Fullhouse
# 8, straight
# 9, Bullbull
# 10, Bull
# 11, GoldBull (JQK)
# 12, SilverBull (JQK10)
# 13, Twopair
# 14, BullNine
# 15, Onepair
# 16, Flash
# 17, all cards < 5
# 18, DiamandBull(JQKJOKER)
# 19, Bull+9pair max
# 20, Bull + JQ
# 21, Bull + 10J
# 22, Bull + A10
# 23, 235+pair
# 24, Bull + 10pair max
# 25, five cards sum = 40
# 26,  IRONBULL threecard + other two sums 10 * n
# 27, same color, all red or all black
# 28, straight Bull
# 29, hard bull three 2,3,5 -> bull
# 30，StraightFlush
# 31, FiveOne
# 32, five cards sum == 10
# 33, five cards sum == 20
# 34, five cards sum == 30
# 35, five cards sum == 40
# 36, five cards sum == 5
# 37, spade A with JQK
# 38, BUll + Apairmax
# 39, BUll with spade A
# 40, GoldBull with Spade A

# Rank Rule for dealing 2-> int Array
# 0，threecard
# 1, KQJ
# 2, QJ10
# 3, sum = 10 bull
# 4, StraightFlush
# 5, Straight


# Second rank rule ->int Array
# 0, 0 同牛同点比最大牌，无牛比最大牌, 1 同牛同点比牛架后的两张, 无牛比最大 2 同牛同点一样大，无牛一样大
# 3, 五小一样大
# 4, 五小谁小谁大
# 5, 五小谁大谁大
# 6, 顺子五小一样大
# 7, 不分花色
# 8, 无牛只比最大两张牌
# 9，Joker最小0


# example5041: [6,   54张牌
#               0,   每家五张牌
#               0, 0, 0, 0, 0, 0, 3, 6, 1    大小王JQK算0点，10 算0点， A-9算1-9点
#               1, 0, 0, 0, 0, 0, 0, 0, 0    有三张牌点数相加为0算牛
#               1, 0, 0, 0, 0, 0, 0, 0, 0, 0   同牛不比牛架，单张比最大
#               1，7，9，10] 四条 》 葫芦 》牛牛 》牛
# example2: []

class Player:

    # Card format[(int suitNumber(0-3), int number(1-13))
    def __init__(self, playerIndex) -> None:
        self.playerID = playerIndex
        self.player_card = []
        self.evaluate_flag = 0

    def Insert_card(self, card):
        self.player_card.append(card)

    def evaluate_hand_cards(self):
        self.evaluate_flag = HandEvaluator.evaluate(self.player_card)




class PokerBullGame:

    @classmethod
    def calResult(self, cardArray, playerNum):
        deck = Init_deck(cardArray)
        winners = self.calWinners(deck, playerNum)

        return winners
    
    @classmethod
    def calWinners(self, deck, playerNum):
        allPlayers = [Player(i) for i in range(playerNum)]

        for i in range(playerNum * 5):
            allPlayers[i % playerNum].Insert_card(deck[i])       

        for player in allPlayers:
            player.evaluate_hand_cards()
        
        return [sorted(allPlayers, key=lambda x:x.evaluate_flag, reverse=True)[0].playerID]

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
                return self.BULLBULL, self.rank_for_max_card(cards)
            if cards_rank > bull_rank:
                bull_rank = cards_rank

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
        return self.SILVERBULL, rank
    @classmethod
    def Is_goldbull(self,cards):
        count = 0
        for card in cards:
            if card.rank > 10:
                count += 1
        if count == 5:
            rank = self.rank_for_max_card(cards)
            return self.GOLDBULL, rank
        
        return 0, 0
    
    @classmethod
    def Is_Bomb(self, cards):
        counts = {}
        for card in cards:

            counts[card.rank] = counts.get(card.rank, 0) + 1
            if counts[card.rank] == 4:
                return self.BOMB, card.rank
        return 0, 0
    
    @classmethod
    def Is_FiveLittle(self, cards):
        if(sum(card.rank for card in cards) > 10): return 0, 0
        for card in cards:
            if(card.rank > 5):
                return 0, 0
            
        rank = self.rank_for_max_card(cards)
        return self.FIVELITTLE, rank
    
    def rank_for_max_card(cards):
        sorted_cards = sort_cards_from_high_to_low(cards)
        rank = sorted_cards[0].score
        return rank
