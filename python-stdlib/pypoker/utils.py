import random
from Card import Card

def Init_deck(initial_cards):
    deck_List = []
    for card_index in initial_cards:
        deck_List.append(Card(3 - card_index // 13, card_index % 13 + 1))
    
    return deck_List

def random_card_array(cardNum):
    cardArray = []
    if cardNum == 52:
        for suit in range(4):
            for rank in range(13):
                cardArray.append(suit * 13 + rank)
    elif cardNum == 40:
        for suit in range(4):
            for rank in range(10):
                cardArray.append(suit * 13 + rank)
    random.shuffle(cardArray)

    return cardArray

def show_card_array(cardArray):
    suit_dic = ["S", "H", "C", "D"]
    for card in cardArray:
        print(str(card%13+1) + str(suit_dic[card//13]) + " ", end="")


def sort_cards_from_high_to_low(cards, isAMax = False):
    return sorted(cards, key=lambda x: (x[1], x[0]), reverse=True)

def sort_cards_from_low_to_high(cards, isAMax = False):
    return sorted(cards, key=lambda x: (x[1], x[0]))
        

