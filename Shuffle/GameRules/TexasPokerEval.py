from pypokerengine.engine.hand_evaluator import HandEvaluator

def TexasPokerEval(hole_cards, community_cards):
    # 比较每位玩家的牌力大小
    max_hand_rank = -1
    winning_players = []
    
    # 将数字转换为形如 "As", "Ks" 的字符串表示形式
    for i in range(len(hole_cards)):
        for j in range(len(hole_cards[i])):
            hole_cards[i][j] = int_to_str(hole_cards[i][j])
        
    # 将数字转换为形如 "As", "Ks" 的字符串表示形式
    for i in range(len(community_cards)):
        community_cards[i] = int_to_str(community_cards[i])

    for player_cards in hole_cards:
        # 将玩家的手牌和公共牌合并成一副牌
        all_cards = player_cards + community_cards

        # 计算牌型的排名
        hand_rank = HandEvaluator.eval_hand(all_cards)

        # 判断牌型是否更大
        if hand_rank > max_hand_rank:
            max_hand_rank = hand_rank
            winning_players = [player_cards]
        elif hand_rank == max_hand_rank:
            winning_players.append(player_cards)

    return winning_players


def int_to_str(card):
    suits = ['s', 'h', 'c', 'd']
    ranks = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K']
    suit = suits[card // 13]
    rank = ranks[card % 13]
    return rank + suit
