from functools import reduce
import itertools
from itertools import groupby
from .utils import Init_deck
from .Card import Card

class Player:
    # Card format[(int suitNumber(0-3), int number(103))
    def __init__(self) -> None:
        self.player_card = []
        self.evaluate_flag = 0

    def Insert_card(self, card):
        self.player_card.append(card)


class TexasPokerGame:

    #args
    #0 playerNum
    #1 isCompareSuit 0/1
    #2 isAceStraight 0/1
    #3 minRank 2-9
    #4 handNum 1-5
    #5 communityNum 0/3/5
    #6 handUseType 0无限制/1必须/2至少
    #7 handUseNum 1-5

    @classmethod
    def calResult(self, cardArray, args, rankRules, suitRules):
        deck = Init_deck(cardArray, suitRules)
        winners = self.calWinners(deck, args, rankRules)
        return winners

    @classmethod
    def calWinners(self, deck, args, rankRules):
        
        playerNum = args[0]
        isCompareSuit = args[1] == 1
        isAceStraight = args[2] == 1
        minRank = args[3]
        handNum = args[4]
        communityNum = args[5]
        handUseType = args[6]
        handUseNum = args[7]

        maxRank = 0
        winners = []
        allPlayCards = []
        community = []
        for i in range(playerNum):
            allPlayCards.append(Player())
        
        #发牌
        for _ in range(handNum):
            for i in range(playerNum):
                allPlayCards[i].Insert_card(deck.pop(0))

        if communityNum == 3:
            deck.pop(0)
            for i in range(3):
                community.append(deck.pop(0))
        elif communityNum == 5:
            deck.pop(0)
            for i in range(3):
                community.append(deck.pop(0))
            for i in range(2):
                deck.pop(0)
                community.append(deck.pop(0))


        for i in range(playerNum):
            allPlayCards[i].evaluate_flag = HandEvaluator.eval_hand(allPlayCards[i].player_card, community, 
                                                                    isCompareSuit, isAceStraight, minRank, 
                                                                    handUseType, handUseNum, rankRules)

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
  def eval_hand(self, cards, community, 
                isCompareSuit, isAceStraight, minRank, 
                handUseType, handUseNum, rankRules):
    cards_length, all_sorted_cards = self.__sort_cards(cards, community, handUseType, handUseNum, isAceStraight, minRank)

    max_score = 0
    for sorted_cards in all_sorted_cards:
        score = self.__calc_hand_info_flg(sorted_cards, isCompareSuit, rankRules, cards_length)
        if score > max_score:
            max_score = score
    return max_score

  @classmethod
  def __sort_cards(self, cards, community, handUseType, handUseNum, isAceStraight, minRank):
    for card in cards:
        if card.rank == 1:
            card.rank = 14

    all_cards = []
    cards_length = 0
    if handUseType == 0:
        all_cards.append(cards + community)
        cards_length = len(cards) + len(community)
    elif handUseType == 1:
        cards_length = 5
        communityNum = 5 - handNum
        handCombinations = list(itertools.combinations(cards, handNum))
        communityCombinations = list(itertools.combinations(community, communityNum))
        for handCombination in handCombinations:
            if communityNum != 0:
                for communityCombination in communityCombinations:
                    all_cards.append(list(handCombination + communityCombination))
            else:
                all_cards.append(list(handCombination))
    elif handUseType == 2:
        cards_length = 5
        for handNum in range(1, handUseNum + 1):
            communityNum = 5 - handNum
            handCombinations = list(itertools.combinations(cards, handNum))
            communityCombinations = list(itertools.combinations(community, communityNum))
            for handCombination in handCombinations:
                if communityNum != 0:
                    for communityCombination in communityCombinations:
                        all_cards.append(list(handCombination + communityCombination))
                else:
                    all_cards.append(list(handCombination))
    
    for cards in all_cards: 
        if isAceStraight:
            ace_cards = []
            for card in cards:
                if card.rank == 14:
                    ace_cards.append(Card(card.suit, minRank - 1))
            cards += ace_cards
        cards.sort(key=lambda card: Card.cal_score(card), reverse=True)

    return cards_length, all_cards
       

  # Return Format
  # 
  # 0       HighCard hole card 9,5,4,3,2          =>  1001 0101 0100 0011 0010 00
  # 1       OnePair of rank3, 9,8,7               =>  0000 0011 1001 1000 0111 00
  # 2       TwoPair of rank3,2  9                 =>  0000 0000 0011 0010 1001 00
  # 3       ThreeFlush of rank9,8,6 3,2           =>  1001 1000 0110 0011 0010 00
  # 4       ThreeStraight of rank9 3,2            =>  0000 0000 1001 0011 0010 00
  # 5       ThreeStraightFlush of rank9 3,2       =>  0000 0000 1001 0011 0010 00
  # 6       ThreeCard of rank9 3,2                =>  0000 0000 1001 0011 0010 00
  # 7       Straight of rank spade10              =>  0000 0000 0000 0000 1010 00
  # 8       Flash of rank spade10,9,8,7,5         =>  1010 1001 1000 0111 0101 00
  # 9       Fullhouse of rank 8,9                 =>  0000 0000 0000 1000 1001 00
  # 10      FourCard of rank8 9                   =>  0000 0000 0000 1000 1001 00
  # 11      StraightFlash of rank 7              =>  0000 0000 0000 0000 0111 00


  @classmethod
  def __calc_hand_info_flg(self, cards, isCompareSuit, rankRules, cards_length):

    rule_dict = {
        0  : self.__eval_holecard,
        1  : self.__eval_onepair,
        2  : self.__eval_twopair,
        3  : self.__eval_threeflush,
        4  : self.__eval_threestraight,
        5  : self.__eval_threestraightflush,
        6  : self.__eval_threecard,
        7  : self.__eval_straight,
        8  : self.__eval_flush,
        9  : self.__eval_fullhouse,
        10 : self.__eval_fourcard,
        11 : self.__eval_straightflush,
    }

    rank_result = 0
    for index, ruleIndex in enumerate(rankRules):
        rank_flag = len(rankRules) - index + 22
        rank_result = rule_dict[ruleIndex](cards, cards_length)
        if isCompareSuit:
            rank_result = rank_result >> 2
        if rank_result != 0:
            rank_result = rank_result | rank_flag
            break

    return rank_result

  @classmethod
  def __eval_straightflush(self, cards, cards_length):
    rank = 0
    for suit in [3,2,1,0]:
        rank_list = []
        cnt = 1
        straight_head_rank = 0
        for i in range(len(cards)):
            if cards[i].suit == suit:
                rank_list.append(cards[i].rank)
        for i in range(len(rank_list) - 1):
            if rank_list[i] - rank_list[i+1] == 1:
                cnt += 1
                if straight_head_rank == 0:
                    straight_head_rank = i
                if cnt == 5: 
                    rank = straight_head_rank 
                    break
            else:
                cnt = 1
                straight_head_rank = 0
        if rank != 0:
            rank = rank << 2 | suit
            break
    return rank


  @classmethod
  def __eval_fourcard(self, cards, cards_length):
    rank = 0
    for i in range(cards_length - 3):
        is_fourcard = True
        for j in range(1, 4):
            if cards[i + j].rank != cards[i].rank:
                is_fourcard = False
                break
        if is_fourcard:
            rank = cards[i].rank << 4
            if i == 0:
                rank = rank | cards[4].rank
            else:
                rank = rank | cards[0].rank
            rank = rank << 2
            break
    
    return rank
  

  @classmethod
  def __eval_fullhouse(self, cards, cards_length):
    rank = 0
    threecard_rank = 0
    pair_rank = 0
    for i in range(cards_length - 2):
        if cards[i].rank == cards[i+1].rank == cards[i+2].rank:
            threecard_rank = cards[i].rank
            break
    if threecard_rank != 0:
        for i in range(cards_length - 1):
            if cards[i].rank == cards[i+1].rank and cards[i].rank != threecard_rank:
                pair_rank = cards[i].rank
                break
    
    if threecard_rank != 0 and pair_rank != 0:
        rank = threecard_rank << 4 | pair_rank
        rank = rank << 2
    return rank


  @classmethod
  def __eval_flush(self, cards, cards_length):
    rank = 0
    for suit in [3,2,1,0]:
        cnt = 0
        for i in range(cards_length):
            if cards[i].suit == suit and cnt < 5:
                cnt += 1
                rank = rank << 4 | cards[i].rank
        if cnt == 5:
            rank = rank << 2 | suit
            break
        else:
            rank = 0   
    return rank
  

  @classmethod
  def __eval_straight(self, cards, cards_length):
    rank = 0
    cnt = 1
    straight_head_rank = 0
    for i in range(len(cards) - 1):
        if cards[i].rank - cards[i+1].rank == 1:
            cnt += 1
            if straight_head_rank == 0:
                straight_head_rank = cards[i].rank
            if cnt == 5: 
                rank = straight_head_rank
                break
        elif cards[i].rank != cards[i+1].rank:
            cnt = 1
            straight_head_rank = 0
    if rank != 0:
        for card in cards:
            if card.rank == rank:
                rank = rank << 2 | card.suit
                break
    return rank
 

  @classmethod
  def __eval_threecard(self, cards, cards_length):
    rank = 0
    threecard_rank = 0
    highcard_rank1 = 0
    highcard_rank2 = 0
    threecard_suit = 0
    for i in range(cards_length - 2):
        if cards[i].rank == cards[i+1].rank == cards[i+2].rank:
            threecard_rank = cards[i].rank
            threecard_suit = cards[i].suit
            break
    if threecard_rank != 0:
        for i in range(cards_length):
            if cards[i].rank != threecard_rank:
                highcard_rank1 = cards[i].rank
                break
        for i in range(cards_length):
            if cards[i].rank != threecard_rank and cards[i].rank != highcard_rank1:
                highcard_rank2 = cards[i].rank
                break
        rank = threecard_rank << 8 | highcard_rank1 << 4 | highcard_rank2
        rank = rank << 2 | threecard_suit
    return rank
  
  

  @classmethod
  def __eval_threestraightflush(self, cards, cards_length):
    rank = 0
    for suit in [3,2,1,0]:
        card_list = []
        cnt = 1
        straight_head_rank = 0
        for i in range(len(cards)):
            if cards[i].suit == suit:
                card_list.append(cards[i])
        for i in range(len(card_list) - 1):
            if card_list[i].rank - card_list[i+1].rank == 1:
                cnt += 1
                if straight_head_rank == 0:
                    straight_head_rank = i
                if cnt == 3: 
                    rank = straight_head_rank 
                    card_list = card_list[i - 1, i + 2]
                    break
            else:
                cnt = 1
                straight_head_rank = 0
        if rank != 0:
            high_card_cnt = 0
            for card in cards:
                if card not in card_list:
                    rank = rank << 4 | card.rank
                    high_card_cnt += 1
                if high_card_cnt == 2:
                    break
            rank = rank << 2 | suit
            break
    return rank
  

  @classmethod
  def __eval_threestraight(self, cards, cards_length):
    rank = 0
    cnt = 1
    straight_head_rank = 0
    card_list = [cards[0]]
    for i in range(len(cards) - 1):
        if cards[i].rank - cards[i+1].rank == 1:
            cnt += 1
            card_list.append(cards[i + 1])
            if straight_head_rank == 0:
                straight_head_rank = cards[i].rank
            if cnt == 3: 
                rank = straight_head_rank 
                break
        elif cards[i].rank != cards[i+1].rank:
            cnt = 1
            card_list = [cards[i]]
            straight_head_rank = 0
    if rank != 0:
        high_card_cnt = 0
        for card in cards:
            if card not in card_list:
                rank = rank << 4 | card.rank
                high_card_cnt += 1
            if high_card_cnt == 2:
                break
        for card in cards:
            if card.rank == rank:
                rank = rank << 2 | card.suit
                break
    return rank
  

  @classmethod
  def __eval_threeflush(self, cards, cards_length):
    rank = 0
    card_list = []
    for suit in [3,2,1,0]:
        cnt = 0
        for i in range(cards_length):
            if cards[i].suit == suit and cnt < 3:
                cnt += 1
                card_list.append(cards[i])
                rank = rank << 4 | cards[i].rank
        if cnt == 3:
            high_card_cnt = 0
            for card in cards:
                if card not in card_list:
                    rank = rank << 4 | card.rank
                    high_card_cnt += 1
                if high_card_cnt == 2:
                    break
            rank = rank << 2 | suit
            break
        else:
            rank = 0   
            card_list = []
    return rank
    

  @classmethod
  def __eval_twopair(self, cards, cards_length):
    rank = 0
    first_pair_rank = 0
    second_pair_rank = 0
    highcard_rank = 0
    first_pair_suit = 0
    for i in range(cards_length - 1):
        if cards[i].rank == cards[i+1].rank:
            if first_pair_rank == 0:
                first_pair_rank = cards[i].rank
                first_pair_suit = cards[i].suit
            else:
                second_pair_rank = cards[i].rank
                break
    if first_pair_rank != 0 and second_pair_rank != 0: 
        for i in range(cards_length):
            if cards[i].rank != first_pair_rank and cards[i].rank != second_pair_rank:
                highcard_rank = cards[i].rank
                break
        rank = first_pair_rank << 8 | second_pair_rank << 4 | highcard_rank
        rank = rank << 2 | first_pair_suit
    return rank
  

  @classmethod
  def __eval_onepair(self, cards, cards_length):
    rank = 0
    pair_rank = 0
    pair_suit = 0
    rank_list = []
    for i in range(cards_length - 1):
        if cards[i].rank == cards[i+1].rank:
            pair_rank = cards[i].rank
            pair_suit = cards[i].suit
            rank_list.append(pair_rank)
            break
    if pair_rank != 0:
        for _ in range(3):
            for i in range(cards_length):
                if cards[i].rank != pair_rank:
                    rank_list.append(cards[i].rank)
                    break
        for rank_ in rank_list:
            rank = rank << 4 | rank_
        rank = rank << 2 | pair_suit
    return rank
  

  @classmethod
  def __eval_holecard(self, cards, cards_length):
    rank = 0
    for i in range(5):
        rank = rank << 4 | cards[i].rank
    return rank

