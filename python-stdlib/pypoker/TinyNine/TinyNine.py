from utils import Init_deck

def calResult(cardArray, playerNum, targetPlayerIndex, dealerPlayerIndex):
    deck = Init_deck(cardArray)
    target_cut = -1
    for i in range(len(deck)):
        deck_bot = deck[0:i]
        deck_top = deck[i:-1]
        new_deck = deck_top + deck_bot
        winners = evaluate(new_deck, playerNum)
        
        if targetPlayerIndex == dealerPlayerIndex:
            if targetPlayerIndex in winners:
                target_cut = i
                break
        else:
            if targetPlayerIndex in winners and len(winners) == 1:
                target_cut = i
                break
            
    return target_cut


def evaluate(deck, playerNum):
    maxRank = -1
    winners = []
    allPlayCards = []
    for i in range(playerNum):
        playerCards = []
        allPlayCards.append(playerCards)
    
    #发牌
    for i in range(playerNum):
        allPlayCards[i].append(deck.pop(0))
    for i in range(playerNum):
        allPlayCards[i].append(deck.pop(0))

    for i in range(playerNum):
        rank = calRank(allPlayCards[i])
        if rank > maxRank:
            maxRank = rank
            winners.clear()
            winners.append(i)
        elif rank == maxRank:
            winners.append(i)

    return winners
    

def calRank(playerCards):
    rank = 0
    num1 = playerCards[0][1]
    num2 = playerCards[1][1]
    if num1 == num2:
        rank = num1 + 100
    else:
        rank = (num1 + num2) % 10
    return rank

