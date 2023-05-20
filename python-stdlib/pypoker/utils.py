import random


def pack_card(card_index):
    return (card_index // 13, card_index % 13 + 1)

def Init_deck(initial_cards):
    deck_List = []
    for card_index in initial_cards:
        deck_List.append(pack_card(card_index))
    
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
    for card in cardArray:
        print(str(card%13+1) + " ", end="")

        

