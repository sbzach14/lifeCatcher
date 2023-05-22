from functools import reduce
from itertools import groupby
from Card import Card

class HandEvaluator:

  HIGHCARD      = 0
  ONEPAIR       = 1 << 14
  STRAIGHT      = 1 << 15
  FLASH         = 1 << 16
  STRAIGHTFLASH = 1 << 17
  THREECARD     = 1 << 18

  @classmethod
  def eval_hand(self, cards):
    sortedCards = self.__sort_cards(cards)
    score = self.__calc_hand_info_flg(sortedCards)
    return score

  @classmethod
  def __sort_cards(self, cards):
    sorted_cards = sorted(cards, key=lambda card: card.score, reverse=True)
    ace_cards = []
    for card in sorted_cards:
       if card.rank == 1:
          ace_cards.append(Card(card.suit, 14))
    sorted_cards = ace_cards + sorted_cards
    return sorted_cards
       

  # Return Format
  # [Bit flg of hand][rank1(4bit)][rank2(4bit)]
  # ex.)
  #       HighCard hole card 3,spade4,2         =>        100 0011 0010 11
  #       OnePair of rank spade3 and 2          =>     1 0000 0011 0010 11
  #       Straight of rank spade10              =>    10 0000 0000 1010 11
  #       Flash of rank spade5,4,2              =>   100 0101 0100 0010 11
  #       straight flash of rank spide7,6,5     =>  1000 0000 0000 0111 11
  #       ThreeCard of rank 9                   => 10000 0000 0000 1001 00
  
  @classmethod
  def __calc_hand_info_flg(self, cards):
    #TODO: 235>豹子
    if self.__is_threecard(cards): return self.THREECARD | self.__eval_threecard(cards)
    if self.__is_straightflash(cards): return self.STRAIGHTFLASH | self.__eval_straightflash(cards)
    if self.__is_flash(cards): return self.FLASH | self.__eval_flash(cards)
    if self.__is_straight(cards): return self.STRAIGHT | self.__eval_straight(cards)
    if self.__is_onepair(cards): return self.ONEPAIR | (self.__eval_onepair(cards))
    return self.__eval_holecard(cards)
  

  @classmethod
  def __is_threecard(self, cards):
    return self.__search_threecard(cards) != -1

  @classmethod
  def __eval_threecard(self, cards):
    return self.__search_threecard(cards)

  @classmethod
  def __search_threecard(self, cards):
    rank = -1
    cnt = 0
    target_rank = cards[0].rank
    for i in range(3):
        if cards[i].rank == target_rank:
            cnt += 1
    if cnt == 3: 
        rank = target_rank
        rank = rank << 2
    return rank
  


  @classmethod
  def __is_straightflash(self, cards):
    return self.__search_straightflash(cards) != -1

  @classmethod
  def __eval_straightflash(self, cards):
    return self.__search_straightflash(cards)

  @classmethod
  def __search_straightflash(self, cards):
    rank = -1
    cnt = 0
    straight_head_index = -1
    for i in range(max(2, len(cards) - 1)):
        if cards[i].suit == cards[i+1].suit and cards[i].rank - cards[i+1].rank == 1:
            cnt += 1
            if straight_head_index == -1:
               straight_head_index = i
    if cnt == 2: 
        rank = straight_head_index.rank << 2 | straight_head_index.suit
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
    cnt = 0
    target_suit = cards[0].suit
    for i in range(3):
        if cards[i].suit == target_suit:
            cnt += 1
    if cnt == 3:
        rank = 0
        for i in range(3):
            rank = rank << 4 | cards[i].rank
        rank = rank << 2 | cards[0].suit
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
    cnt = 0
    straight_head_index = -1
    for i in range(max(2, len(cards) - 1)):
        if cards[i].rank - cards[i+1].rank == 1:
            cnt += 1
            if straight_head_index == -1:
               straight_head_index = i
    if cnt == 2: 
        rank = cards[straight_head_index].rank << 2 | cards[straight_head_index].suit
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
    if cards[0].rank == cards[1].rank:
        rank = cards[0].rank << 6 | cards[2].rank << 2 | cards[0].suit
    elif cards[0].rank == cards[2].rank:
        rank = cards[0].rank << 6 | cards[1].rank << 2 | cards[0].suit
    elif cards[1].rank == cards[2].rank:
        rank = cards[1].rank << 6 | cards[0].rank << 2 | cards[1].suit
    return rank
  


  @classmethod
  def __eval_holecard(self, cards):
    rank = cards[0].rank << 10 | cards[1].rank << 6 | cards[2].rank << 2 | cards[0].suit
    return rank

