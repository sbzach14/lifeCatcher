


def pack_card(card_index):
    return (card_index // 13, card_index % 13 + 1)

def Init_deck(initial_cards):
    deck_List = []
    for card_index in initial_cards:
        deck_List.append(pack_card(card_index))
    
    return deck_List


