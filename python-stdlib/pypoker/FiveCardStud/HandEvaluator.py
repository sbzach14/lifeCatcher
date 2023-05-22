from Card import Card

class HandEvaluator:

  HIGHCARD      = 0
  ONEPAIR       = 1 << 22
  TWOPAIR       = 1 << 23
  THREECARD     = 1 << 24
  STRAIGHT      = 1 << 25
  FLASH         = 1 << 26
  FULLHOUSE     = 1 << 27
  FOURCARD      = 1 << 28
  STRAIGHTFLASH = 1 << 29

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
  #       HighCard hole card spade9             =>                               1001 11
  #       OnePair of rank spade3                =>         1 0000 0000 0000 0000 0011 11
  #       TwoPair of rank spade3, 2             =>        10 0000 0000 0000 0011 0010 11
  #       ThreeCard of rank 9                   =>       100 0000 0000 0000 0000 1001 00
  #       Straight of rank spade10              =>      1000 0000 0000 0000 0000 1010 11
  #       Flash of rank spade10,9,8,7,5         =>     10000 1010 1001 1000 0111 0101 11
  #       Fullhouse of rank 8,9                 =>    100000 0000 0000 0000 1000 1001 00
  #       FourCard of rank 9                    =>   1000000 0000 0000 0000 0000 1001 00
  #       straight flash of rank spide7         =>  10000000 0000 0000 0000 0000 0111 11

  
  @classmethod
  def __calc_hand_info_flg(self, cards):
    if self.__is_straightflash(cards): return self.STRAIGHTFLASH | self.__eval_straightflash(cards)
    if self.__is_fourcard(cards): return self.FOURCARD | self.__eval_fourcard(cards)
    if self.__is_fullhouse(cards): return self.FULLHOUSE | self.__eval_fullhouse(cards)
    if self.__is_flash(cards): return self.FLASH | self.__eval_flash(cards)
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
    cnt = 1
    straight_head_index = -1
    for i in range(max(4, len(cards) - 1)):
        if cards[i].suit == cards[i+1].suit and cards[i].rank - cards[i+1].rank == 1:
            cnt += 1
            if straight_head_index == -1:
               straight_head_index = i
    if cnt == 5: 
        rank = straight_head_index.rank << 2 | straight_head_index.suit
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
    cnt = 0
    maxCnt = 0
    target_rank = cards[0].rank
    maxCnt_rank = -1
    for i in range(5):
        if cards[i].rank == target_rank:
            cnt += 1
        else:
           target_rank = cards[i].rank
           cnt = 1
        if cnt > maxCnt:
           maxCnt = cnt
           maxCnt_rank = target_rank
    if maxCnt == 4: 
        rank = maxCnt_rank
        rank = rank << 2
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
    if cards[0].rank == cards[1].rank == cards[2].rank \
        and cards[3].rank == cards[4].rank:
       rank = cards[0].rank << 6 | cards[3].rank << 2

    elif cards[2].rank == cards[3].rank == cards[4].rank \
        and cards[0].rank == cards[1].rank:
       rank = cards[2].rank << 6 | cards[0].rank << 2
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
    for i in range(5):
        if cards[i].suit == target_suit:
            cnt += 1
    if cnt == 5:
        rank = 0
        for i in range(5):
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
    cnt = 1
    straight_head_index = -1
    for i in range(max(4, len(cards) - 1)):
        if cards[i].rank - cards[i+1].rank == 1:
            cnt += 1
            if straight_head_index == -1:
               straight_head_index = i
    if cnt == 5: 
        rank = cards[straight_head_index].rank << 2 | cards[straight_head_index].suit
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
    cnt = 0
    maxCnt = 0
    target_rank = cards[0].rank
    maxCnt_rank = -1
    for i in range(5):
        if cards[i].rank == target_rank:
            cnt += 1
        else:
           target_rank = cards[i].rank
           cnt = 1
        if cnt > maxCnt:
           maxCnt = cnt
           maxCnt_rank = target_rank
    if maxCnt == 3: 
        rank = maxCnt_rank
        rank = rank << 2
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
    first_pair_suit = -1
    for i in range(4):
        if cards[i].rank == cards[i+1].rank:
            if first_pair_rank == -1:
                first_pair_rank = cards[i].rank
                first_pair_suit = cards[i].suit
            else:
                second_pair_rank = cards[i].rank
    if first_pair_rank != -1 and second_pair_rank != -1: 
        rank = first_pair_rank << 6 | second_pair_rank << 2 | first_pair_suit
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
    target_card_index = -1
    for i in range(4):
        if cards[i].rank == cards[i+1].rank:
           target_card_index = i
           break
    if target_card_index != -1: 
        rank = cards[target_card_index].rank << 2 | cards[target_card_index].suit
    return rank
  


  @classmethod
  def __eval_holecard(self, cards):
    rank = cards[0].rank << 2 | cards[0].suit
    return rank

