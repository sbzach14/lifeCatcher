from functools import reduce
from itertools import groupby
from .utils import Init_deck
from .Card import Card

class Player:
    # Card format[(int suitNumber(0-3), int number(1-13))
    def __init__(self, mode = 0) -> None:
        self.player_card = []
        self.evaluate_flag = 0
        self.mode = mode

    def Insert_card(self, card):
        self.player_card.append(card)

    def evaluate_hand_cards(self, community):
        self.evaluate_flag = HandEvaluator.eval_hand(self.player_card + community, self.mode)
        


class TexasPokerGame:

    @classmethod
    def calResult(self, cardArray, playerNum, args):
        deck = Init_deck(cardArray)
        mode = args[0]
        winners = self.calWinners(deck, playerNum, mode)
        return winners

    @classmethod
    def calWinners(self, deck, playerNum, mode):
        maxRank = -1
        winners = []
        allPlayCards = []
        community = []
        for i in range(playerNum):
            allPlayCards.append(Player(mode))
        
        #发牌
        for card_cnt in range(2):
            for i in range(playerNum):
                allPlayCards[i].Insert_card(deck.pop(0))

        deck.pop(0)
        for i in range(3):
            community.append(deck.pop(0))
        for i in range(2):
            deck.pop(0)
            community.append(deck.pop(0))

        for i in range(playerNum):
            allPlayCards[i].evaluate_hand_cards(community)

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

  HIGHCARD      = 0
  ONEPAIR       = 1 << 20
  TWOPAIR       = 1 << 21
  THREECARD     = 1 << 22
  STRAIGHT      = 1 << 23
  FLASH         = 1 << 24
  FULLHOUSE     = 1 << 25
  FOURCARD      = 1 << 26
  STRAIGHTFLASH = 1 << 27


  #mode 0normal 1short

  @classmethod
  def eval_hand(self, cards, mode):
    sortedCards = self.__sort_cards(cards, mode)
    score = self.__calc_hand_info_flg(sortedCards, mode)
    return score

  @classmethod
  def __sort_cards(self, cards, mode):
    
    if mode == 0:
        ace_cards = []
        for card in cards:
            if card.rank == 1:
                ace_cards.append(Card(card.suit, 14))
        card = ace_cards + card
    elif mode == 1:
        for card in cards:
            if card.rank == 1:
                card.rank = 14
        
    sorted_cards = sorted(cards, key=lambda card: card.rank, reverse=True)

    return sorted_cards
       

  # Return Format
  # [Bit flg of hand][rank1(4bit)][rank2(4bit)]
  # ex.)
  #       HighCard hole card 9,5,4,3,2          =>           1001 0101 0100 0011 0010
  #       OnePair of rank3, 9,8,7               =>         1 0000 0011 1001 1000 0111
  #       TwoPair of rank3,2  9                 =>        10 0000 0000 0011 0010 1001
  #       ThreeCard of rank9 3,2                =>       100 0000 0000 1001 0011 0010
  #       Straight of rank spade10              =>      1000 0000 0000 0000 0000 1010
  #       Flash of rank spade10,9,8,7,5         =>     10000 1010 1001 1000 0111 0101
  #       Fullhouse of rank 8,9                 =>    100000 0000 0000 0000 1000 1001
  #       FourCard of rank8 9                   =>   1000000 0000 0000 0000 1000 1001
  #       straight flash of rank 7              =>  10000000 0000 0000 0000 0000 0111

  
  @classmethod
  def __calc_hand_info_flg(self, cards, mode):
    if self.__is_straightflash(cards): return self.STRAIGHTFLASH | self.__eval_straightflash(cards)
    if self.__is_fourcard(cards): return self.FOURCARD | self.__eval_fourcard(cards)
    
    if mode == 0:
        if self.__is_fullhouse(cards): return self.FULLHOUSE | self.__eval_fullhouse(cards)
        if self.__is_flash(cards): return self.FLASH | self.__eval_flash(cards)
    elif mode == 1:
        if self.__is_flash(cards): return self.FLASH | self.__eval_flash(cards)
        if self.__is_fullhouse(cards): return self.FULLHOUSE | self.__eval_fullhouse(cards)
       
    if self.__is_straight(cards): return self.STRAIGHT | self.__eval_straight(cards)
    if self.__is_threecard(cards): return self.THREECARD | self.__eval_threecard(cards)
    if self.__is_twopair(cards): return self.TWOPAIR | (self.__eval_twopair(cards))
    if self.__is_onepair(cards): return self.ONEPAIR | (self.__eval_onepair(cards))
    return self.__eval_holecard(cards)
  

  
  @classmethod
  def __is_straightflash(self, cards):
    return self.__search_straightflash(cards) != -1

  @classmethod
  def __eval_straightflash(self, cards):
    return self.__search_straightflash(cards)

  @classmethod
  def __search_straightflash(self, cards):
    rank = -1
    for suit in range(4):
        rank_list = []
        cnt = 1
        straight_head_rank = -1
        for i in range(len(cards)):
            if cards[i].suit == suit:
                rank_list.append(cards[i].rank)
        for i in range(len(rank_list) - 1):
            if rank_list[i] - rank_list[i+1] == 1:
                cnt += 1
                if straight_head_rank == -1:
                    straight_head_rank = i
                if cnt >= 5: 
                    rank = straight_head_rank 
            else:
                cnt = 1
                straight_head_rank = -1
    return rank



  @classmethod
  def __is_fourcard(self, cards):
    return self.__search_fourcard(cards) != -1

  @classmethod
  def __eval_fourcard(self, cards):
    return self.__search_fourcard(cards)

  @classmethod
  def __search_fourcard(self, cards):
    rank = -1
    for i in range(4):
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
            break
    return rank
  


  @classmethod
  def __is_fullhouse(self, cards):
    return self.__search_fullhouse(cards) != -1

  @classmethod
  def __eval_fullhouse(self, cards):
    return self.__search_fullhouse(cards)

  @classmethod
  def __search_fullhouse(self, cards):
    rank = -1
    threecard_rank = -1
    pair_rank = -1
    for i in range(5):
        if cards[i].rank == cards[i+1].rank == cards[i+2].rank:
            threecard_rank = cards[i].rank
            break
    
    if threecard_rank != -1:
        for i in range(6):
            if cards[i].rank == cards[i+1].rank and cards[i].rank != threecard_rank:
                pair_rank = cards[i].rank
                break
    
    if threecard_rank != -1 and pair_rank != -1:
        rank = threecard_rank << 4 | pair_rank

    return rank


  @classmethod
  def __is_flash(self, cards):
    return self.__search_flash(cards) != -1

  @classmethod
  def __eval_flash(self, cards):
    return self.__search_flash(cards)

  @classmethod
  def __search_flash(self, cards):
    rank = -1
    for suit in range(4):
        cnt = 0
        for i in range(7):
            if cards[i].suit == suit:
                cnt += 1
                if rank == -1:
                    rank = 0
                if cnt <= 5:
                    rank = rank << 4 | cards[i].rank
        if cnt >= 5:
            break
        else:
            rank = -1    
    return rank
  
  
  @classmethod
  def __is_straight(self, cards):
    return self.__search_straight(cards) != -1

  @classmethod
  def __eval_straight(self, cards):
    return self.__search_straight(cards)

  @classmethod
  def __search_straight(self, cards):
    rank = -1
    cnt = 1
    straight_head_rank = -1
    for i in range(len(cards) - 1):
        if cards[i].rank - cards[i+1].rank == 1:
            cnt += 1
            if straight_head_rank == -1:
                straight_head_rank = cards[i].rank
            if cnt >= 5: 
                rank = straight_head_rank 
        elif cards[i].rank != cards[i+1].rank:
            cnt = 1
            straight_head_rank = -1
    return rank
 
  

  @classmethod
  def __is_threecard(self, cards):
    return self.__search_threecard(cards) != -1

  @classmethod
  def __eval_threecard(self, cards):
    return self.__search_threecard(cards)

  @classmethod
  def __search_threecard(self, cards):
    rank = -1
    threecard_rank = -1
    highcard_rank1 = -1
    highcard_rank2 = -1
    for i in range(5):
        if cards[i].rank == cards[i+1].rank == cards[i+2].rank:
            threecard_rank = cards[i].rank
            break
    if threecard_rank != -1:
        for i in range(7):
            if cards[i].rank != threecard_rank:
                highcard_rank1 = cards[i].rank
                break
        for i in range(7):
            if cards[i].rank != threecard_rank and cards[i].rank != highcard_rank1:
                highcard_rank2 = cards[i].rank
                break
        rank = threecard_rank << 8 | highcard_rank1 << 4 | highcard_rank2
    return rank
    
  


  @classmethod
  def __is_twopair(self, cards):
    return self.__eval_twopair(cards) != -1
  
  @classmethod
  def __eval_twopair(self, cards):
    return self.__search_twopair(cards)

  @classmethod
  def __search_twopair(self, cards):
    rank = -1
    first_pair_rank = -1
    second_pair_rank = -1
    highcard_rank = -1
    for i in range(6):
        if cards[i].rank == cards[i+1].rank:
            if first_pair_rank == -1:
                first_pair_rank = cards[i].rank
            else:
                second_pair_rank = cards[i].rank
                break
    if first_pair_rank != -1 and second_pair_rank != -1: 
        for i in range(7):
            if cards[i].rank != first_pair_rank and cards[i].rank != second_pair_rank:
                highcard_rank = cards[i].rank
                break
        rank = first_pair_rank << 8 | second_pair_rank << 4 | highcard_rank
    return rank
  

  @classmethod
  def __is_onepair(self, cards):
    return self.__eval_onepair(cards) != -1
  
  @classmethod
  def __eval_onepair(self, cards):
    return self.__search_onepair(cards)

  @classmethod
  def __search_onepair(self, cards):
    rank = -1
    pair_rank = -1
    rank_list = []
    for i in range(6):
        if cards[i].rank == cards[i+1].rank:
            pair_rank = cards[i].rank
            rank_list.append(pair_rank)
            break
    if pair_rank != -1:
        for num in range(3):
            for i in range(7):
                if cards[i].rank not in rank_list:
                    rank_list.append(cards[i].rank)
                    break
        rank = 0
        for rank_ in rank_list:
            rank = rank << 4 | rank_
    return rank
  


  @classmethod
  def __eval_holecard(self, cards):
    rank = 0
    for i in range(5):
        rank = rank << 4 | cards[i].rank
    return rank

