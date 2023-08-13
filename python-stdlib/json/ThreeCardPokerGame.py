from .utils import Init_deck
from .Card import Card
import itertools
import math

class Player:
    # Card format[(int suitNumber(0-3), int number(1-13))
    def __init__(self) -> None:
        self.player_card = []
        self.evaluate_flag = 0

    def Insert_card(self, card):
        self.player_card.append(card)

    def evaluate_hand_cards(self):
        self.evaluate_flag = HandEvaluator.eval_hand(self.player_card)
        
#todo 
#     mixedsuit
#     zhandan

class ThreeCardPokerGame:

    #args
    #0 playerNum
    #1 handNum 3-
    #2 isCompareSuit 0/1
    #3 minRank 2-9
    #4 isAce 0/1/2
    #5 isAceStraight 0/1
    #6 isHeadCard 0/1
    #7 isRedJoker 0/1
    #8 redJokerSuit 0/1
    #9 redJokerRank 0-14
    #10 isBlackJoker 0/1
    #11 blackJokerSuit 0/1
    #12 blackJokerRank 0/1
    #13 isReverseHighCard 0/1

    @classmethod
    def calResult(self, cardArray, args, rankRules, suitRules):
        deck = Init_deck(cardArray, suitRules)
        winners = self.calWinners(deck, args, rankRules, suitRules)
        return winners

    @classmethod
    def calWinners(self, deck, args, rankRules, suitRules):
        
        playerNum = args[0]
        handNum = args[1]
        isCompareSuit = args[2]
        minRank = args[3]
        isAce = args[4]
        isAceStraight = args[5]
        isHeadCard = args[6]
        isRedJoker = args[7]
        redJokerSuit = args[8]
        redJokerRank = args[9]
        isBlackJoker = args[10]
        blackJokerSuit = args[11]
        blackJokerRank = args[12]
        isReverseHighCard = args[13]

        maxRank = 0
        winners = []
        allPlayCards = []
        
        for i in range(playerNum):
            allPlayCards.append(Player())
        
        #发牌
        for _ in range(handNum):
            for i in range(playerNum):
                allPlayCards[i].Insert_card(deck.pop(0))


        for i in range(playerNum):
            allPlayCards[i].evaluate_flag = HandEvaluator.eval_hand(allPlayCards[i].player_card, 
                                                                    isCompareSuit, minRank, isAce, isAceStraight, isHeadCard, 
                                                                    isRedJoker, redJokerSuit, redJokerRank, 
                                                                    isBlackJoker, blackJokerSuit, blackJokerRank,
                                                                    isReverseHighCard, rankRules, suitRules)

        for i in range(playerNum):
            rank = allPlayCards[i].evaluate_flag
            if rank > maxRank:
                maxRank = rank
                winners.clear()
                winners.append(i)
            elif rank == maxRank:
                winners.append(i)

        #sort list
        # winners = []
        # for i in range(playerNum):
        #     winners.append(i)
        # winners = sorted(winners, key=lambda x:allPlayCards[x].evaluate_flag, reverse=True)
            

        return winners
        


class HandEvaluator:

    @classmethod
    def eval_hand(self, cards, 
                    isCompareSuit, minRank, isAce, isAceStraight, isHeadCard, 
                    isRedJoker, redJokerSuit, redJokerRank, 
                    isBlackJoker, blackJokerSuit, blackJokerRank,
                    isReverseHighCard, rankRules, suitRules):
        
        self.isCompareSuit = isCompareSuit
        self.minRank = minRank
        self.isAce = isAce
        self.isAceStraight = isAceStraight
        self.isHeadCard = isHeadCard
        self.isRedJoker = isRedJoker
        self.redJokerSuit = redJokerSuit
        self.redJokerRank = redJokerRank
        self.isBlackJoker = isBlackJoker
        self.blackJokerSuit = blackJokerSuit
        self.blackJokerRank = blackJokerRank
        self.isReverseHighCard = isReverseHighCard

        if isHeadCard == 1:
            if isAce == 2:
                self.maxRank = 14
            else:
                self.maxRank = 13
        else:
            if isAce == 2:
                self.maxRank = 11
            else:
                self.maxRank = 10

        sortedCards = self.__sort_cards(cards, suitRules)
        max_score = 0
        for sorted_cards in sortedCards:
            score = self.__calc_hand_info_flg(sorted_cards, rankRules)
            if score > max_score:
                max_score = score
        return max_score

    @classmethod
    def __sort_cards(self, cards, suitRules):
        for card in cards:
            if card.rank == 14 and self.isBlackJoker == 1:#小王
                if self.blackJokerRank == 14:#任意牌
                    card.rank = -1
                else:
                    card.rank = self.blackJokerRank
                if self.blackJokerSuit == 0:#不计点数
                    card.suit = [3,2,1,0]
                elif self.blackJokerSuit == 1:
                    card.suit = sorted([suitRules[0], suitRules[2]])
            elif card.rank == 15 and self.isRedJoker:#大王
                if self.redJokerRank == 14:
                    card.rank = -1
                else:
                    card.rank = self.redJokerRank
                if self.redJokerSuit == 0:
                    card.suit = [3,2,1,0]
                elif self.redJokerSuit == 1:
                    card.suit = sorted([suitRules[1], suitRules[3]])
            elif card.rank == 1:
                if self.isAce == 1:
                    card.rank = self.minRank - 1
                elif self.isAce == 2:
                    card.rank = self.maxRank


        all_cards = []
        
        handCombinations = list(itertools.combinations(cards, 3))
        for handCombination in handCombinations:
            all_cards.append(list(handCombination))
            aceList = list(handCombination)
            if self.isAceStraight != 0 and self.isAce == 2:
                isAdd = False
                for card in aceList:
                    if card.suit == self.maxRank:
                        card.suit = self.minRank - 1
                        isAdd = True
                if isAdd:
                    all_cards.append(aceList)
        
        for cards in all_cards:
            cards.sort(key=lambda card: Card.cal_score(card), reverse=True)

        return all_cards
        

    # Return Format
    # [Bit flg of hand][rank1(4bit)][rank2(4bit)]
    # ex.)
    # card spade3,spade4, heart2     =>    0100 0011 0010 11 11 10

    
    @classmethod
    def __calc_hand_info_flg(self, sorted_cards, rankRules):

        rule_dict = {
            0  : self.__eval_holecard,
            1  : self.__eval_onepair,
            2  : self.__eval_truepair,
            3  : self.__eval_straight,
            4  : self.__eval_flush,
            5  : self.__eval_pairflush,
            6 : self.__eval_straightflush,
            7 : self.__eval_threehead,
            8 : self.__eval_akj,
            9 : self.__eval_akjflush,
            10 : self.__eval_235,
            11 : self.__eval_235flush,
            12 : self.__eval_threecard,
            13 : self.__eval_doubleJoker
        }

        rank_result = 0

        if self.minRank != 2:
            if 10 in rankRules:
                rankRules.remove(10)
            if 11 in rankRules:
                rankRules.remove(11)

        if self.isAce == 0:
            if 8 in rankRules:
                rankRules.remove(8)
            if 9 in rankRules:
                rankRules.remove(9)
        
        if self.isHeadCard == 0:
            if 7 in rankRules:
                rankRules.remove(7)
        
        for index, ruleIndex in enumerate(rankRules):
            rank_flag = 1 << (len(rankRules) - index + 18)
            rank_result = rule_dict[ruleIndex](sorted_cards)
            if not self.isCompareSuit:
                rank_result = rank_result >> 6
            if rank_result != 0:
                rank_result = rank_result | rank_flag
                break

        return rank_result
    
    @classmethod
    def __eval_doubleJoker(self, cards):
        rank = 0
        cnt = 0

        for i in range(3):
            if cards[i].rank == -1:
                cnt += 1
        if cnt == 2:
            for i in range(2):
                rank = rank << 4 | self.maxRank
            rank = rank << 4 | cards[0].rank
            for i in range(2):
                rank = rank << 2 | cards[i].suit[0]
            rank = rank << 4 | cards[0].suit
        elif cnt == 3:
            for i in range(3):
                rank = rank << 4 | self.maxRank
            for i in range(3):
                rank = rank << 4 | cards[i].suit[0]
        return rank
    

    @classmethod
    def __eval_threecard(self, cards):
        rank = 0
        cnt = 0

        target_rank = cards[0].rank
        if target_rank == -1:
            target_rank = self.maxRank

        for i in range(3):
            if cards[i].rank == target_rank or cards[i].rank == -1:
                cnt += 1
        if cnt == 3 and target_rank != 0:
            for i in range(3):
                rank = rank << 4 | target_rank
            for i in range(3):
                if type(cards[i].suit) == int:
                    rank = rank << 2 | cards[i].suit
                else:
                    rank = rank << 2 | cards[i].suit[0]
        return rank

    @classmethod
    def __eval_235flush(self, cards):
        rank = 0    
        cnt_5 = 0
        cnt_3 = 0
        cnt_2 = 0
        cnt_c = 0

        for i in range(3):
            if cards[i].rank == 5:
                cnt_5 = 1
            elif cards[i].rank == 3:
                cnt_3 = 1
            elif cards[i].rank == 2:
                cnt_2 = 1
            elif cards[i].rank == -1:
                cnt_c += 1

        target_suit = -1
        cnt_suit = [0, 0, 0, 0]
        for i in range(3):
            if type(cards[i].suit) == int:
                cnt_suit[cards[i].suit] += 1
            else:
                for suit in cards[i].suit:
                    cnt_suit[suit] += 1
        for i in cnt_suit:
            if i == 3:
                target_suit = i
        
        if cnt_5 + cnt_3 + cnt_2 + cnt_c == 3 and target_suit != -1: 
            rank = rank << 4 | 5
            rank = rank << 4 | 3
            rank = rank << 4 | 2
            for i in range(3):
                rank = rank << 2 | target_suit
        return rank
    
    @classmethod
    def __eval_235(self, cards):
        rank = 0    
        cnt_5 = 0
        cnt_3 = 0
        cnt_2 = 0
        cnt_c = 0

        for i in range(3):
            if cards[i].rank == 5:
                cnt_5 = 1
            elif cards[i].rank == 3:
                cnt_3 = 1
            elif cards[i].rank == 2:
                cnt_2 = 1
            elif cards[i].rank == -1:
                cnt_c += 1
        
        if cnt_5 + cnt_3 + cnt_2 + cnt_c == 3: 
            rank = rank << 4 | 5
            rank = rank << 4 | 3
            rank = rank << 4 | 2
            for i in range(3):
                if type(cards[i].suit) == int:
                    rank = rank << 2 | cards[i].suit
                else:
                    rank = rank << 2 | cards[i].suit[0]
        return rank

    @classmethod
    def __eval_akjflush(self, cards):
        rank = 0    
        cnt_a = 0
        cnt_k = 0
        cnt_j = 0
        cnt_c = 0

        for i in range(3):
            if cards[i].rank == self.maxRank or cards[i].rank == self.minRank - 1:
                cnt_a = 1
            elif cards[i].rank == 13:
                cnt_k = 1
            elif cards[i].rank == 11:
                cnt_j = 1
            elif cards[i].rank == -1:
                cnt_c += 1

        target_suit = -1
        cnt_suit = [0, 0, 0, 0]
        for i in range(3):
            if type(cards[i].suit) == int:
                cnt_suit[cards[i].suit] += 1
            else:
                for suit in cards[i].suit:
                    cnt_suit[suit] += 1
        for i in cnt_suit:
            if i == 3:
                target_suit = i
        
        if cnt_a + cnt_k + cnt_j + cnt_c == 3 and target_suit != -1: 
            rank = rank << 4 | 14
            rank = rank << 4 | 13
            rank = rank << 4 | 11
            for i in range(3):
                rank = rank << 2 | target_suit
        return rank
    
    @classmethod
    def __eval_akj(self, cards):
        rank = 0    
        cnt_a = 0
        cnt_k = 0
        cnt_j = 0
        cnt_c = 0

        for i in range(3):
            if cards[i].rank == self.maxRank or cards[i].rank == self.minRank - 1:
                cnt_a = 1
            elif cards[i].rank == 13:
                cnt_k = 1
            elif cards[i].rank == 11:
                cnt_j = 1
            elif cards[i].rank == -1:
                cnt_c += 1
        
        if cnt_a + cnt_k + cnt_j + cnt_c == 3: 
            rank = rank << 4 | 14
            rank = rank << 4 | 13
            rank = rank << 4 | 11
            for i in range(3):
                if type(cards[i].suit) == int:
                    rank = rank << 2 | cards[i].suit
                else:
                    rank = rank << 2 | cards[i].suit[0]
        return rank
    
    @classmethod
    def __eval_threehead(self, cards):
        rank = 0    
        cnt = 0

        for i in range(3):
            if cards[i].rank == 13 or \
                cards[i].rank == 12 or \
                cards[i].rank == 11 or \
                cards[i].rank == -1:
                cnt += 1
        
        if cnt == 3: 
            for i in range(3):
                if cards[i].rank == -1:
                    rank = rank << 4 | 13
                else:
                    rank = rank << 4 | cards[i].rank
            for i in range(3):
                if type(cards[i].suit) == int:
                    rank = rank << 2 | cards[i].suit
                else:
                    rank = rank << 2 | cards[i].suit[0]
        return rank
        
    @classmethod
    def __eval_straightflush(self, cards):
        rank = 0
        cnt_c = 0
        straight_head = -1
        
        ranklist = []
        for i in range(3):
            if cards[i].rank == -1:
                cnt_c += 1
            else:
                ranklist.append(cards[i].rank)
        
        if cnt_c == 3:
            straight_head = 15
        elif cnt_c == 2:
            straight_head = math.min(self.maxRank, ranklist[0] + 2)
        elif cnt_c == 1:
            if ranklist[0] - ranklist[1] == 1:
                straight_head = math.min(self.maxRank, ranklist[0] + 1)
            elif ranklist[0] - ranklist[1] == 2:
                straight_head = ranklist[0]
        else:
            if ranklist[0] - ranklist[1] == 1 and \
            ranklist[0] - ranklist[2] == 2 and \
            ranklist[2] != 0:
                straight_head = ranklist[0]

        target_suit = -1
        cnt_suit = [0, 0, 0, 0]
        for i in range(3):
            if type(cards[i].suit) == int:
                cnt_suit[cards[i].suit] += 1
            else:
                for suit in cards[i].suit:
                    cnt_suit[suit] += 1
        for i in cnt_suit:
            if i == 3:
                target_suit = i

        if target_suit != -1:
        
            if straight_head == self.minRank + 1:
                if self.isAceStraight == 2:
                    rank = rank << 4 | self.maxRank + 1
                    for i in range(1, 3):
                        rank = rank << 4 | (straight_head - i)
                    for i in range(3):
                        rank = rank << 2 | target_suit
                elif self.isAceStraight == 3:
                    rank = rank << 4 | self.maxRank
                    for i in range(1, 3):
                        rank = rank << 4 | (straight_head - i)
                    for i in range(3):
                        rank = rank << 2 | target_suit

            if straight_head != -1: 
                for i in range(3):
                    rank = rank << 4 | (straight_head - i)
                for i in range(3):
                    rank = rank << 2 | target_suit
        return rank
    

    @classmethod
    def __eval_pairflush(self, cards):
        rank = 0

        pairRank = -1
        singleRank = -1
        cnt_c = 0
        ranklist = []
        for i in range(3):
            if cards[i].rank == -1:
                cnt_c += 1
            else:
                ranklist.append(cards[i].rank)

        if cnt_c == 3:
            pairRank = self.maxRank
            singleRank = self.maxRank
        elif cnt_c == 2:
            pairRank = self.maxRank
            singleRank = ranklist[0]
        elif cnt_c == 1:
            pairRank = ranklist[0]
            pairRank = ranklist[1]
        else:
            if ranklist[0] == ranklist[1]:
                pairRank = ranklist[0]
                singleRank = ranklist[2]
            elif ranklist[1] == ranklist[2]:
                pairRank = ranklist[1]
                singleRank = ranklist[0]
        

        target_suit = -1
        cnt_suit = [0, 0, 0, 0]

        for i in range(3):
            if type(cards[i].suit) == int:
                cnt_suit[cards[i].suit] += 1
            else:
                for suit in cards[i].suit:
                    cnt_suit[suit] += 1
        for i in cnt_suit:
            if i == 3:
                target_suit = i
        
        if target_suit != -1 and pairRank != -1: 
            rank = rank << 4 | pairRank
            rank = rank << 4 | pairRank
            rank = rank << 4 | singleRank
            for i in range(3):
                rank = rank << 2 | target_suit
        return rank


    @classmethod
    def __eval_flush(self, cards):
        rank = 0
        target_suit = -1
        cnt_suit = [0, 0, 0, 0]
        for i in range(3):
            if type(cards[i].suit) == int:
                cnt_suit[cards[i].suit] += 1
            else:
                for suit in cards[i].suit:
                    cnt_suit[suit] += 1
        for i in cnt_suit:
            if i == 3:
                target_suit = i
        
        if target_suit != -1: 
            jokerlist = []
            normallist = []
            for i in range(3):
                if cards[i].rank == -1:
                    jokerlist.append(self.maxRank)
                else:
                    normallist.append(cards[i].rank)
            for c in jokerlist:
                rank = rank << 4 | c[0]
            for c in normallist:
                rank = rank << 4 | c[0]
            for i in range(3):
                rank = rank << 2 | target_suit
        return rank


    @classmethod
    def __eval_straight(self, cards):
        rank = 0
        cnt_c = 0
        straight_head = -1
        
        ranklist = []
        suitlist = []
        for i in range(3):
            if cards[i].rank == -1:
                cnt_c += 1
            else:
                ranklist.append(cards[i].rank)
        
        if cnt_c == 3:
            straight_head = 15
            for i in range(3):
                suitlist.append(cards[i].suit[0])
        elif cnt_c == 2:
            straight_head = math.min(self.maxRank, ranklist[0] + 2)
            suitlist.append(cards[0])
            suitlist.append(cards[1].suit[0])
            suitlist.append(cards[2].suit[0])
        elif cnt_c == 1:
            if ranklist[0] - ranklist[1] == 1:
                straight_head = math.min(self.maxRank, ranklist[0] + 1)
                suitlist.append(cards[2].suit[0])
                suitlist.append(cards[0])
                suitlist.append(cards[1])
            elif ranklist[0] - ranklist[1] == 2:
                straight_head = ranklist[0]
                suitlist.append(cards[0])
                suitlist.append(cards[2].suit[0])
                suitlist.append(cards[1])
        else:
            if ranklist[0] - ranklist[1] == 1 and \
            ranklist[0] - ranklist[2] == 2 and \
            ranklist[2] != 0:
                straight_head = ranklist[0]
                for i in range(3):
                    suitlist.append(cards[i].suit)

        if straight_head == self.minRank + 1:
            if self.isAceStraight == 2:
                rank = rank << 4 | self.maxRank + 1
                for i in range(1, 3):
                    rank = rank << 4 | (straight_head - i)
                for i in range(3):
                    rank = rank << 2 | suitlist[i]
            elif self.isAceStraight == 3:
                rank = rank << 4 | self.maxRank
                for i in range(1, 3):
                    rank = rank << 4 | (straight_head - i)
                for i in range(3):
                    rank = rank << 2 | suitlist[i]

        elif straight_head != -1: 
            for i in range(3):
                rank = rank << 4 | (straight_head - i)
            for i in range(3):
                rank = rank << 2 | suitlist[i]

        return rank
    
    @classmethod
    def __eval_truepair(self, cards):
        rank = 0

        pairRank = -1
        singleRank = -1
        cnt_c = 0
        suitlist = []

        for i in range(3):
            if cards[i].rank == -1:
                cnt_c += 1

        if cnt_c == 3:
            pairRank = self.maxRank
            singleRank = self.maxRank
            if cards[0].suit[0] == cards[1].suit[0]:
                suitlist.append(cards[0].suit[0])
                suitlist.append(cards[1].suit[0])
                suitlist.append(cards[2].suit[0])
            else:
                suitlist.append(cards[1].suit[0])
                suitlist.append(cards[2].suit[0])
                suitlist.append(cards[0].suit[0])
                
        elif cnt_c == 2:
            if cards[1].suit[0] == cards[2].suit[0]:
                pairRank = self.maxRank
                singleRank = cards[0].rank
                suitlist.append(cards[1].suit[0])
                suitlist.append(cards[2].suit[0])
                suitlist.append(cards[0].suit)
            elif cards[0].suit in cards[1].suit:
                pairRank = cards[0].rank
                singleRank = self.maxRank
                suitlist.append(cards[0].suit)
                suitlist.append(cards[0].suit)
                suitlist.append(cards[2].suit)
            elif cards[0].suit in cards[2].suit:
                pairRank = cards[0].rank
                singleRank = self.maxRank
                suitlist.append(cards[0].suit)
                suitlist.append(cards[0].suit)
                suitlist.append(cards[1].suit)
                
        elif cnt_c == 1:
            if cards[0].suit in cards[2].suit:
                pairRank = cards[0].rank
                singleRank = cards[1].rank
                suitlist.append(cards[0].suit)
                suitlist.append(cards[0].suit)
                suitlist.append(cards[1].suit)
            elif cards[1].suit in cards[2].suit:
                pairRank = cards[1].rank
                singleRank = cards[0].rank
                suitlist.append(cards[1].suit)
                suitlist.append(cards[1].suit)
                suitlist.append(cards[0].suit)
            
        else:
            if cards[0].rank == cards[1].rank and cards[0].suit == cards[1].suit:
                pairRank = cards[0].rank
                singleRank = cards[2].rank
                suitlist.append(cards[0].suit)
                suitlist.append(cards[0].suit)
                suitlist.append(cards[2].suit)

            if cards[1].rank == cards[2].rank and cards[1].suit == cards[2].suit:
                pairRank = cards[1].rank
                singleRank = cards[0].rank
                suitlist.append(cards[1].suit)
                suitlist.append(cards[1].suit)
                suitlist.append(cards[0].suit)
        
        if pairRank != -1: 
            rank = rank << 4 | pairRank
            rank = rank << 4 | pairRank
            rank = rank << 4 | singleRank
            for i in range(3):
                rank = rank << 2 | suitlist[i]
        return rank

    @classmethod
    def __eval_onepair(self, cards):
        rank = 0

        pairRank = -1
        singleRank = -1
        cnt_c = 0
        suitlist = []

        for i in range(3):
            if cards[i].rank == -1:
                cnt_c += 1

        if cnt_c == 3:
            pairRank = self.maxRank
            singleRank = self.maxRank
            for i in range(3):
                suitlist.append(cards[i].suit[0])
                
        elif cnt_c == 2:
            pairRank = self.maxRank
            singleRank = cards[0].rank
            suitlist.append(cards[1].suit[0])
            suitlist.append(cards[2].suit[0])
            suitlist.append(cards[0].suit)
                
        elif cnt_c == 1:
            pairRank = cards[0].rank
            singleRank = cards[1].rank
            suitlist.append(cards[0].suit)
            suitlist.append(cards[2].suit[0])
            suitlist.append(cards[1].suit)
            
        else:
            if cards[0].rank == cards[1].rank:
                pairRank = cards[0].rank 
                singleRank = cards[2].rank 
                suitlist.append(cards[0].suit)
                suitlist.append(cards[1].suit)
                suitlist.append(cards[2].suit)

            elif cards[1].rank == cards[2].rank:
                pairRank = cards[1].rank
                singleRank = cards[0].rank
                suitlist.append(cards[1].suit)
                suitlist.append(cards[2].suit)
                suitlist.append(cards[0].suit)
        
        if pairRank != -1: 
            rank = rank << 4 | pairRank
            rank = rank << 4 | pairRank
            rank = rank << 4 | singleRank
            for i in range(3):
                rank = rank << 2 | suitlist[i]
        return rank
    

    @classmethod
    def __eval_holecard(self, cards):
        jokerlist = []
        normallist = []
        rank = 0
        if self.isReverseHighCard:
            minRank = self.minRank
            if self.isAce == 1:
                minRank = self.minRank - 1
            for i in range(3):
                if cards[i].rank == -1:
                    jokerlist.append([minRank, cards[i].rank])
                else:
                    normallist.append([cards[i].rank, cards[i].suit])
            for c in jokerlist:
                rank = rank << 4 | self.maxRank - c[0]
            for c in normallist:
                rank = rank << 4 | self.maxRank - c[0]
            for c in jokerlist:
                rank = rank << 2 | c[1]
            for c in normallist:
                rank = rank << 2 | c[1]
        
        else:
            for i in range(3):
                if cards[i].rank == -1:
                    jokerlist.append([self.maxRank, cards[i].rank])
                else:
                    normallist.append([cards[i].rank, cards[i].suit])
            for c in jokerlist:
                rank = rank << 4 | c[0]
            for c in normallist:
                rank = rank << 4 | c[0]
            for c in jokerlist:
                rank = rank << 2 | c[1]
            for c in normallist:
                rank = rank << 2 | c[1]
        return rank
