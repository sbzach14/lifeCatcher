
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

# numberchangearray
# if card number change -> int Array:
# 0, 10 -> 0, 1, 1/0(计算点数时还是10)*, 1/0(计算点数时候时0/1)*
# 1, J -> 0, 1, 11
# 2, Q -> 0, 1, 2, 12
# 3, K -> 0, 1, 6, 13
# 4, BLACKJoker ->0, 1, 3, any*
# 5, REDJOKER ->0, 1, 6, any*
# 6, 3 -> 3, 3/6*
# 7, 6 -> 6, 3/6*
# 8, Spade A -> 1, 0(公牌)

# Bull Rule for dealing 0, 1 -> int Array 0->no 1->yes:
# 0, any three cards equal to 10 * n
# 1, total five cards equal to 10 * n
# 2, Threecard
# 3, thress card straight 
# 4, only contains J,K,Q,A,JOKER is BULLBULL(不看点数)
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
# 26, IRONBULL threecard + other two sums 10 * n
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
# 6, 顺子五小一样大*
# 7, 不分花色
# 8, 无牛只比最大两张牌
# 9，Joker是最小的0*

class Player:

    # Card format[(int suitNumber(0-3), int number(1-13))
    def __init__(self, playerIndex) -> None:
        self.playerID = playerIndex
        self.player_card = []
        self.evaluate_flag = 0

    def Insert_card(self, card):
        self.player_card.append(card)

    def evaluate_hand_cards(self, bull_rules,same_bull_point_comparision,five_little_comparision,five_little_equal_to_straight, rankRules):
        self.evaluate_flag = HandEvaluator.evaluate(self.player_card, bull_rules,same_bull_point_comparision,five_little_comparision, five_little_equal_to_straight, rankRules)



# example5041: [6,   54张牌
#               0,   每家五张牌
#               0, 0, 0, 0, 0, 0, 3, 6, 1    大小王JQK算0点，10 算0点， A-9算1-9点
#               1, 0, 0, 0, 0, 0, 0, 0, 0    有三张牌点数相加为0算牛
#               1, 0, 0, 0, 0, 0, 0, 0, 0, 0   同牛不比牛架，单张比最大
#               rankRules [1，7，9，10] 四条 》 葫芦 》牛牛 》牛
# example2: []


class PokerBullGame:

    class PokerBullCard:
        def __init__(self, card, numberChangeArray, is_no_suit, joker_min_zero):
            self.tenValue = numberChangeArray[0]
            self.JValue = numberChangeArray[1]
            self.QValue = numberChangeArray[2]
            self.KValue = numberChangeArray[3]
            self.BJokerValue = numberChangeArray[4]
            self.RJokerValue = numberChangeArray[5]
            self.ThreeValue  = numberChangeArray[6]
            self.SixValue = numberChangeArray[7]
            self.SpadeA = numberChangeArray[8]

            # 牛牛牌的三个属性
            self.suit = -1
            # 算牛时的点数,例如公牌算0
            self.rank1_value = -1
            # 计算大小是的点数
            self.rank2_value = -1
            self.true_rank = card.rank

            if is_no_suit == 1:
                self.suit = 0
            else:
                self.suit = card.suit
            
            # rank1_value是用来组牛时候的点数，rank2_value是用来比大小时候的点数
            # 10 -10 10是0，1
            if card.rank == 10:
                if self.tenValue == 0:
                    self.rank1_value = 0
                    self.rank2_value = card.rank
                if self.tenValue == 1:
                    self.rank1_value = 1
                    self.rank2_value = 1
                if self.tenValue == 2:
                    self.rank1_value = -10
                    self.rank2_value = -10
            elif card.rank == 11:
                if self.JValue == 0:
                    self.rank1_value = 0
                    self.rank2_value =  card.rank
                if self.JValue == 1:
                    self.rank1_value = 1
                    self.rank2_value = 1
                if self.JValue == 2:
                    self.rank1_value = 11
                    self.rank2_value = 11
            elif card.rank == 12:
                if self.QValue == 0:
                    self.rank1_value = 0
                    self.rank2_value = 12
                if self.QValue == 1:
                    self.rank1_value = 1
                    self.rank2_value = 1
                if self.QValue == 2:
                    self.rank1_value = 2
                    self.rank2_value = 2
                if self.QValue == 3:
                    self.rank1_value = 12
                    self.rank2_value = 12
            elif card.rank == 13:
                if self.KValue == 0:
                    self.rank1_value = 0
                    self.rank2_value = 13
                if self.KValue == 1:
                    self.rank1_value = 1
                    self.rank2_value = 1
                if self.KValue == 2:
                    self.rank1_value = 6
                    self.rank2_value = 6
                if self.KValue == 3:
                    self.rank1_value = 13
                    self.rank2_value = 13
            # -1, Any
            elif card.rank == 14:
                if self.BJokerValue == 0:
                    self.rank1_value = 0
                    self.rank2_value = 14
                if self.BJokerValue == 1:
                    self.rank1_value = 1
                    self.rank2_value = 1
                if self.BJokerValue == 2:
                    self.rank1_value = 3
                    self.rank2_value = 3
                if self.BJokerValue == 3:
                    self.rank1_value = -1
                    self.rank2_value = -1
            elif card.rank == 15:
                if self.RJokerValue == 0:
                    self.rank1_value = 0
                    self.rank2_value = 15
                if self.RJokerValue == 1:
                    self.rank1_value = 1
                    self.rank2_value = 1
                if self.RJokerValue == 2:
                    self.rank1_value = 6
                    self.rank2_value = 6
                if self.RJokerValue == 3:
                    self.rank1_value = -1
                    self.rank2_value = -1
            elif card.rank == 3:
                if self.ThreeValue == 0:
                    self.rank1_value = 3
                    self.rank2_value = 3
                if self.ThreeValue == 1:
                    self.rank1_value = -3
                    self.rank2_value = -3
            elif card.rank == 6:
                if self.SixValue == 0:
                    self.rank1_value = 6
                    self.rank2_value = 6
                if self.SixValue == 1:
                    self.rank1_value = -6
                    self.rank2_value = -6
            elif card.rank == 1 and card.suit == 3:
                if self.SpadeA == 0:
                    self.rank1_value = 1
                    self.rank2_value = 1
                if self.SpadeA == 1:
                    self.rank1_value = 0
                    self.rank2_value = 0
            else:
                self.rank1_value = card.rank
                self.rank2_value = card.rank
                self.suit = card.suit       
            self.score = self.cal_self_score()
        @classmethod
        def cal_score(self, poker_bull_card):
            return poker_bull_card.rank2_value << 2 | poker_bull_card.suit
        @classmethod
        def cal_self_score(self):
            return self.rank2_value<<2 | self.suit



    @classmethod
    def calResult(self, cardArray, args, rankRules):
        deck = Init_deck(cardArray)
        winners = self.calWinners(deck, args, rankRules)
        return winners
    
    @classmethod
    def calWinners(self, deck, args, rankRules):
        # 解析 args
        self.playerNum = args[0]
        self.way_to_deal_cards = args[1]
        self.number_change_array = args[2: 11]
        self.bull_rule = args[11 : 20]
        self.same_bull_point_comparision = args[20]
        self.five_little_comparision = args[21]
        self.five_little_equal_to_straight = args[22]
        self.No_Suit = args[23]
        self.Joker_min_zero = args[24]

        # 组建bull deck
        self.bull_deck = [self.PokerBullCard(card) for card in deck]
        allPlayers = [Player(i) for i in range(self.playerNum)]
        # 发牌
        if(self.way_to_deal_cards == 0):
            for i in range(self.playerNum * 5):
                allPlayers[i % self.playerNum].Insert_card(self.bull_deck[i])
        if(self.way_to_deal_cards == 1):
            for i in range(5):
                allPlayers[i % self.playerNum].Insert_card(self.bull_deck[i])
            sorted(allPlayers, key = lambda x:x.player_card[0].rank2_value, reverse=True)

            for i in range((self.playerNum - 1)*5):
                allPlayers[i % self.playerNum].Insert_card(self.bull_deck[i + 5])
            pass
        if(self.way_to_deal_cards == 2):
            for i in range(self.playerNum * 3):
                allPlayers[i % self.playerNum].Insert_card(self.bull_deck[i])
            
        if(self.way_to_deal_cards == 3):
            for i in range(self.playerNum * 5):
                allPlayers[i % self.playerNum].Insert_card(self.bull_deck[i])
        if(self.way_to_deal_cards == 4):
            for i in range(self.playerNum * 10):
                allPlayers[i % self.playerNum].Insert_card(self.bull_deck[i])
     
        # 计算牌额大小
        for player in allPlayers:
            player.evaluate_hand_cards(self.bull_rule,self.same_bull_point_comparision, self.five_little_comparision, self.five_little_equal_to_straight, rankRules)
        
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

    # 0, 0 同牛同点比最大牌，无牛比最大牌, 
    # 1 同牛同点比牛架后的两张, 无牛比最大 
    # 2 同牛同点一样大，无牛一样大
    BULLSECONDRANK = -1
    # 0, 五小一样大
    # 1, 五小谁小谁大
    # 2, 五小谁大谁大
    FIVELITTLESECONDRANK = -1
    # 6, 顺子五小一样大
    STRAITEQUALFIVELITTLE = False
    # 7, 不分花色
    NOSUIT = False
    # 8, 无牛只比最大两张牌
    NOBULLRANKTOPTWO = False
    # 9，Joker是最小的0
    JOKERISSMALLESTZERO = False



    


    # cards, bull cards 数组
    # bull_rules，判断什么是牛的规则数组
    # same_bull_point_comparision, 同牛情况下如何比较的规则
    # 五小牛比较的规则
    # 五小牛是否和顺子一样大
    # 牌型大小的排序数组
    # 
    # 所有的比较都是默认比较highcard

    
    # 计算并返回手牌的分数
    @classmethod
    def evaluate(self, cards,bull_rules, same_bull_point_comparision, five_little_comparision,five_little_equal_to_straight, rankRules):

        RANK_RULE_Dic = {
        0 : self.Is_cards_sum_largerOrequal_forty,
        1 : self.Is_Fourcard, 
        2 : self.Is_five_cards_sum_lessOrEqual_ten,
        }

        self.IS_BULL_DIC = {
        0: self.Any_three_card_sum_Nten,
        1: self.Threecard,
        2: self.Total_equal_to_N10,
        3: self.Three_card_straight,
        4: self.Only_JKQAJOKER,
        5: self.Three_RankOne_card,
        6: self.Five_cards_sum_less_than_ten,
        7: self.Five_cards_sum_less_than_nine,
        8: self.Any_three_card_sum_Nten_overTwenty

        }




        self.bull_rules = bull_rules
        self.same_bull_point_comparision = same_bull_point_comparision
        self.five_little_comparision = five_little_comparision
        self.five_little_equal_to_straight = five_little_equal_to_straight

        funcList = [self.Is_Fourcard, self.Is_FiveLittle, self.Is_goldbull, self.Is_silverbull, self.Is_bull]
        i = len(funcList) + 1
        for func in funcList:
            i = i - 1
            flag, rank = func(cards)
            if flag:
                continue
            else:
                eval = 1<<(8 + i) | rank 
                print(eval)
                return eval
            
###################################################
    # 判断是否有牛
    # 不同判断牛的函数
    # TODO 组牛时候的多个值的变化
###################################################
    def Any_three_card_sum_Nten(self, cards):
        bulls = []
        for combination in itertools.combinations(cards, 3):
            sum_of_combinations = 0
            for item in combination:
                sum_of_combinations += item.rank1_value
            if sum_of_combinations % 10 == 0:
                bulls.append(combination)
        return bulls
    def Threecard(self, cards):
        counts = {}
        bulls = []
        for card in cards:
            counts[card.rank2_value] = counts.get(card.rank2_value, []).append(card)
            if len(counts[card.rank2_value]) == 3:
                bulls.append(counts[card.rank2_value])
        return bulls
    def Total_equal_to_N10(self, cards):
        if sum(card.rank1_value for card in cards) % 10 == 0:
            return [cards]
        return []
    def Three_card_straight(self, cards):
        bulls = []
        for combination in itertools.combinations(cards, 3):
            sorted(combination, key=lambda x:x.rank2_value)
            if combination[0].rank2_value + 2 == combination[1].rank2.value + 1 == combination[2].rank2_value:
                bulls.append(combination)
        return bulls
    def Only_JKQAJOKER(self, cards):
        bulls = []

        combination = []
        for card in cards:
            if card.true_rank == 1 or card.true_rank > 10:
                combination.append(card)
        if(len(combination) == 5):
            bulls.append(combination)
        return bulls
    def Three_RankOne_card(self, cards):
        bulls = []
        for combination in itertools.combinations(cards, 3):
            sum_of_combinations = 0
            for item in combination:
                if item.rank2_value == 1:
                    sum_of_combinations += 1
            if sum_of_combinations == 3:
                bulls.append(combination)
        return bulls
    def Five_cards_sum_less_than_ten(self, cards):
        bulls = []

        if sum(card.rank2_value for card in cards) <= 10:
            bulls.append(cards)

        return bulls
    def Five_cards_sum_less_than_nine(self, cards):
        bulls = []

        if sum(card.rank2_value for card in cards) < 10:
            bulls.append(cards)

        return bulls 
    def Any_three_card_sum_Nten_overTwenty(self, cards):
        bulls = []
        for combination in itertools.combinations(cards, 3):
            sum_of_combinations = 0
            for item in combination:
                sum_of_combinations += item.rank1_value
            if sum_of_combinations % 10 == 0 and sum_of_combinations > 20:
                bulls.append(combination)
        return bulls 

# #########################################################

# 所有的牌型判断
###########################################################


    # 0, five cards sum >= 40
    @classmethod
    def Is_cards_sum_largerOrequal_forty(self, cards):
        if(sum(card.rank for card in cards) < 40): return False, 0
        else: 
            rank = self.rank_for_max_card(cards)
            return True, rank
    # 1, Fourcard
    @classmethod
    def Is_Fourcard(self, cards):
        counts = {}
        for card in cards:

            counts[card.rank] = counts.get(card.rank, 0) + 1
            if counts[card.rank] == 4:
                return True, card.rank
        return False, 0
    # 2, five cards sum <= 10

    @classmethod
    def Is_five_cards_sum_lessOrEqual_ten(self,cards):
        if(sum(card.rank for card in cards) > 10): return False, 0
        else:
            if self.FIVELITTLESECONDRANK == 0:
                return True, 0
            if self.FIVELITTLESECONDRANK == 1:
                return True, sum(card.rank for card in cards)
            if self.FIVELITTLESECONDRANK == 2:
                return True, ~sum(card.rank for card in cards)
    # 3, five cards sum == 20 and have bull
    def Is_five_cards_sum_equalsTo_twenty_and_haveBulls(self, cards):
        if sum(card.rank for card in cards) == 20 and self.Is_bull(cards):
            rank = self.rank_for_max_card(cards)
            return True, rank             
        else:
            return False, 0
    # 4, five cards sum == 30 and have bull
    def Is_five_cards_sum_equalsTo_thirty_and_haveBulls(self, cards):
        if sum(card.rank for card in cards) == 30 and self.Is_bull(cards):
            rank = self.rank_for_max_card(cards)
            return True, rank
        else:
            return False, rank
    # 5, Threecard and other two sum == 10
    def Threecard_and_otherTen(self, cards):
        counts = {}
        for card in cards:
            counts[card.rank1_value] = counts.get(card.rank1_value, 0) + 1
        for key, value in counts.items():
            if value == 3:
                rank = key
                other_values_sum = sum(v for k, v in counts.items() if k != key)
                if other_values_sum % 10 == 0:
                    return True, rank
        return False, 0
    
    # 6, five cards sum == 20 or 30
    def sum_equal_twentyORthirty(self, cards):
        if(sum(card.rank1.value for card in cards) == 20 or sum(card.rank1_value for card in cards) == 30):
            return True, self.rank_for_max_card(cards)
        return False, 0
    # 7, Fullhouse
    def Is_Fullhouse(self, cards):
        counts = {}
        true_value_dic = {}
        for card in cards:
            counts[card.true_value] = counts.get(card.true_value, 0) + 1
            true_value_dic[card.true_value] = card.rank2_value
        for key, value in counts.items():
            if value == 3:
                rank = true_value_dic[key]
                other_values_num = [v for k, v in counts.items() if k != key][0]
                if other_values_num == 2:
                    return True, rank
        return False, 0
    # 8, straight
    def Is_stratght(self, cards):
        sorted(cards, key=lambda x:x.rank2_value)
        for card_index in range(len(cards) - 1):
            if cards[card_index].rank2_value + 1 == cards[card_index + 1].rank2_value:
                continue
            else:
                return False, 0
        return True, cards[0].cal_self_score()
    
    @classmethod
    def Is_BullBull(self, cards):
        allbulls = []
        bull_rank = 0

            
        # find out all bull
        for index in self.bull_rules:
            func = self.IS_BULL_DIC[index]
            bulls = func(cards)
            if len(bulls) != 0:
                allbulls.append(bulls)
        rank = 0
        # if no bull
        if len(allbulls) == 0:
            return False, 0
        # 有牛，判断是否有牛牛
        for bulls in allbulls:
            # 挑出最大的牛牛
            for bull in bulls:
                if len(bull) == 5: 
                    bull_rank = sum(card.rank2_value for card in bull)
                    # 如果牛牛
                    if bull_rank == 0 or len(self.Only_JKQAJOKER(cards)) != 0:
                        if self.same_bull_point_comparision == 0:
                            rank = self.rank_for_max_card(cards)
                        elif self.same_bull_point_comparision == 1:
                            print("同牛同点比牛架，不能加入这个牛型")
                        elif self.same_bull_point_comparision == 2:
                            rank = 0               
                if len(bull) == 3:
                    other_cards = [card for card in cards if card not in bull]
                    cards_rank = 0
                    for item in other_cards:
                        cards_rank += item.rank2_value
                    cards_rank = cards_rank % 10
                    # if bull,bull
                    if cards_rank == 0:
                        if self.same_bull_point_comparision == 0:
                            rank = self.rank_for_max_card(cards)
                        elif self.same_bull_point_comparision == 1:
                            rank = self.rank_for_max_card(other_cards)
                        elif self.same_bull_point_comparision == 2:
                            rank = 0 

            return True, rank

    @classmethod
    def Is_bull(self, cards):
        allbulls = []
        bull_rank = 0
        rank = 0

        # find out all bull
        for index in self.bull_rules:
            func = self.IS_BULL_DIC[index]
            bulls = func(cards)
            if len(bulls) != 0:
                allbulls.append(bulls)
        
        if len(allbulls) == 0:
            return False, 0
        
        for bulls in allbulls:
            # 挑出最大的bull
            for bull in bulls:
                if len(bull) == 5:
                    bull_rank = sum(card.rank2_value for card in bull) % 10
                if len(bull) == 3:
                    other_cards = [card for card in cards if card not in bull]
                    cards_rank = 0
                    for item in other_cards:
                        cards_rank += item.rank2_value
                    cards_rank = cards_rank % 10
                    if cards_rank > bull_rank:
                        bull_rank = cards_rank
                        if self.same_bull_point_comparision == 0:
                            rank = self.rank_for_max_card(cards)
                        if self.same_bull_point_comparision == 1:
                            rank = self.rank_for_max_card(other_cards)
                        if self.same_bull_point_comparision(cards):
                            rank = 0


        return True, bull_rank << 4 | rank

    @classmethod
    def Is_goldbull(self,cards):
        count = 0
        for card in cards:
            if card.rank2_value > 10:
                count += 1
        if count == 5:
            rank = self.rank_for_max_card(cards)
            return True, rank
        
        return False, 0
            
    @classmethod
    def Is_silverbull(self,cards):
        count = 0
        for card in cards:
            if card.rank2_value < 10:
                return False, 0
            if card.rank2_value == 10:
                count += 1
            if count > 1:
                return False, 0
        rank = self.rank_for_max_card(cards)
        return True, rank
    
    @classmethod
    def Is_TwoPair(self, cards):
        counts = {}
        for card in cards:
            counts[cards.true_rank] = counts.get(card.true_rank, 0) + 1
        pair = []
        highcard = []
        for key, value in counts:
            if value == 2:
                pair.append(key)
            else:
                highcard.append(key)
        
        if len(pair) == 2:
            sorted(pair, reverse= True)
            sorted(highcard, reverse=True)
            return True, pair[0] << 8| pair[1] << 4 | highcard
        

        return False, 0
            
        

    def Is_BullNine(self, cards):
        allbulls = []
        bull_rank = 0
        rank = 0

        # find out all bull
        for index in self.bull_rules:
            func = self.IS_BULL_DIC[index]
            bulls = func(cards)
            if len(bulls) != 0:
                allbulls.append(bulls)
        
        if len(allbulls) == 0:
            return False, 0
        
        for bulls in allbulls:
            # 挑出最大的bull
            for bull in bulls:
                if len(bull) == 5:
                    bull_rank = sum(card.rank1_value for card in bull) % 10
                if len(bull) == 3:
                    other_cards = [card for card in cards if card not in bull]
                    cards_rank = 0
                    for item in other_cards:
                        cards_rank += item.rank1_value
                    cards_rank = cards_rank % 10
                    if cards_rank > bull_rank:
                        bull_rank = cards_rank
                        if self.same_bull_point_comparision == 0:
                            rank = self.rank_for_max_card(cards)
                        if self.same_bull_point_comparision == 1:
                            rank = self.rank_for_max_card(other_cards)
                        if self.same_bull_point_comparision(cards):
                            rank = 0
        if bull_rank == 9:
            return True, rank
        
        return False, 0
    @classmethod
    def Is_One_Pair(self, cards):
        counts = {}
        for card in cards:
            counts[cards.true_rank] = counts.get(card.true_rank, 0) + 1
        pair = []
        highcard = []
        for key, value in counts:
            if value == 1:
                pair.append(key)
            else:
                highcard.append(key)
        
        if len(pair) == 2:
            sorted(pair, reverse= True)
            sorted(highcard, reverse=True)
            return True, pair[0] << 8 | highcard
        return False, 0

    @classmethod
    def Is_Flash(self, cards):
        suit = cards[0].suit
        for card in cards:
            if card.suit != suit:
                return False, 0

        return True, self.rank_for_max_card(cards)

    @classmethod
    def Is_All_Cards_Less_Than_Five(self, cards):
        for card in cards:
            if card.rank2 > 5:
                return False, 0
        return True, self.rank_for_max_card(cards) 

    @classmethod
    def Is_Diamand_Bull(self, cards):
        diamand = 0
        for card in cards:
            if card.true_rank < 11:
                return False, 0
            if card.true_rank > 13:
                diamand += 1
        if diamand != 0:
            return True, self.rank_for_max_card(cards)
        return False, 0
    @classmethod
    def Is_Bull_Plus_Pair_Nine(self, cards):
        allbulls = []
        bull_rank = 0
        rank = 0

        # find out all bull
        for index in self.bull_rules:
            func = self.IS_BULL_DIC[index]
            bulls = func(cards)
            if len(bulls) != 0:
                allbulls.append(bulls)
        
        if len(allbulls) == 0:
            return False, 0
        
        for bulls in allbulls:
            for bull in bulls:
                if len(bull) == 5:
                    continue
                if len(bull) == 3:
                    other_cards = [card for card in cards if card not in bull]
                    rank = 0
                    if other_cards[0].true_rank == other_cards[1].true_rank == 9:
                        if self.same_bull_point_comparision == 0:
                            rank = self.rank_for_max_card(cards)
                        if self.same_bull_point_comparision == 1:
                            rank = self.rank_for_max_card(other_cards)
                        if self.same_bull_point_comparision(cards):
                            rank = 0                        
                        return True, rank
        return False, 0
    @classmethod
    def Is_Bull_Plus_JQ(self, cards):
        allbulls = []
        bull_rank = 0
        rank = 0

        # find out all bull
        for index in self.bull_rules:
            func = self.IS_BULL_DIC[index]
            bulls = func(cards)
            if len(bulls) != 0:
                allbulls.append(bulls)
        
        if len(allbulls) == 0:
            return False, 0
        
        for bulls in allbulls:
            for bull in bulls:
                if len(bull) == 5:
                    continue
                if len(bull) == 3:
                    other_cards = [card for card in cards if card not in bull]
                    sorted(other_cards, key=lambda x:x.true_rank, reverse= True)
                    rank = 0
                    if other_cards[0].true_rank == 12 and other_cards[1].true_rank == 11:
                        if self.same_bull_point_comparision == 0:
                            rank = self.rank_for_max_card(cards)
                        if self.same_bull_point_comparision == 1:
                            rank = self.rank_for_max_card(other_cards)
                        if self.same_bull_point_comparision(cards):
                            rank = 0                        
                        return True, rank
        return False, 0
    
    @classmethod
    def Is_Bull_Plus_JQ(self, cards):
        allbulls = []
        bull_rank = 0
        rank = 0

        # find out all bull
        for index in self.bull_rules:
            func = self.IS_BULL_DIC[index]
            bulls = func(cards)
            if len(bulls) != 0:
                allbulls.append(bulls)
        
        if len(allbulls) == 0:
            return False, 0
        
        for bulls in allbulls:
            for bull in bulls:
                if len(bull) == 5:
                    continue
                if len(bull) == 3:
                    other_cards = [card for card in cards if card not in bull]
                    sorted(other_cards, key=lambda x:x.true_rank, reverse= True)
                    rank = 0
                    if other_cards[0].true_rank == 12 and other_cards[1].true_rank == 11:
                        if self.same_bull_point_comparision == 0:
                            rank = self.rank_for_max_card(cards)
                        if self.same_bull_point_comparision == 1:
                            rank = self.rank_for_max_card(other_cards)
                        if self.same_bull_point_comparision(cards):
                            rank = 0                        
                        return True, rank
        return False, 0



    
    @classmethod
    def Is_FiveLittle(self, cards):
        if(sum(card.rank for card in cards) > 10): return 0, 0
        for card in cards:
            if(card.rank > 5):
                return 0, 0
            
        rank = self.rank_for_max_card(cards)
        return self.FIVELITTLE, rank
    
    def rank_for_max_card(self,cards):
        sorted_cards = self.Sort_Bull_Cards_From_High_to_Low(cards)
        rank = sorted_cards[0].score
        return rank
    @classmethod
    def Sort_Bull_Cards_From_High_to_Low(self, cards):
        return sorted(cards, key = lambda x:x.score, reverse=True)

