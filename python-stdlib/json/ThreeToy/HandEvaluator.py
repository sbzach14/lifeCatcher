from Card import Card

class HandEvaluator:

  HIGHCARD      = 0
  THREETOY      = 1 << 18
  THREECARD     = 1 << 19
  THREETHREE    = 1 << 20

  @classmethod
  def eval_hand(self, cards):
    sortedCards = self.__sort_cards(cards)
    score = self.__calc_hand_info_flg(sortedCards)
    return score

  @classmethod
  def __sort_cards(self, cards):
    sorted_cards = sorted(cards, key=lambda card: card.score, reverse=True)
    ace_cards = []
    sorted_cards = ace_cards + sorted_cards
    return sorted_cards
       

  # Return Format
  # [Bit flg of hand][rank1(4bit)][rank2(4bit)]
  # ex.)
  #       HighCard hole card 3,spade4,2 and sum 9    =>       1001 0100 0011 0010 11
  #       ThreeToy of spade K, Q, J                  =>     1 0000 1101 1100 1001 11
  #       ThreeCard of rank 9                        =>    10 0000 0000 0000 1001 00
  #       ThreeThree                                  =>  100 0000 0000 0000 0000 00
  
  @classmethod
  def __calc_hand_info_flg(self, cards):
    if self.__is_threethree(cards): return self.THREETHREE | self.__eval_threecard(cards)
    if self.__is_threecard(cards): return self.THREECARD | self.__eval_threecard(cards)
    if self.__is_threetoy(cards): return self.THREETOY | self.__eval_threetoy(cards)
    return self.__eval_holecard(cards)
  


  @classmethod
  def __is_threethree(self, cards):
    return self.__search_threethree(cards) != -1

  @classmethod
  def __eval_threecard(self, cards):
    return self.__search_threethree(cards)

  @classmethod
  def __search_threethree(self, cards):
    rank = -1
    if cards[0].rank == 3 and cards[1].rank == 3 and cards[2].rank == 3:
       rank = 0
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
    target_rank = cards[0].rank
    for i in range(3):
        if cards[i].rank == target_rank:
            cnt += 1
    if cnt == 3: 
        rank = target_rank
        rank = rank << 2
    return rank
  

  @classmethod
  def __is_threetoy(self, cards):
    return self.__search_threetoy(cards) != -1

  @classmethod
  def __eval_threetoy(self, cards):
    return self.__search_threetoy(cards)

  @classmethod
  def __search_threetoy(self, cards):
    rank = -1
    if cards[0].rank > 10 and cards[1].rank > 10 and cards[2].rank > 10:
       rank = cards[0].rank << 10 | cards[1].rank << 6 | cards[2].rank << 2 | cards[0].suit
    return rank


  @classmethod
  def __eval_holecard(self, cards):
    sum_rank = 0
    for i in range(3):
      sum_rank += min(10, cards[i].rank)
    sum_rank = sum_rank % 10
    rank =  sum_rank << 14 | cards[0].rank << 10 | cards[1].rank << 6 | cards[2].rank << 2 | cards[0].suit
    return rank

