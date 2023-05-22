from utils import random_card_array, show_card_array
from TinyNine.TinyNineGame import TinyNineGame
from ThreeCardPoker.ThreeCardPokerGame import ThreeCardPokerGame
from PokerBull.PorkerBullGame import PokerBullGame

if __name__ == "__main__":
    #testCardArray = random_card_array(52)
    testCardArray = [34,3,10,25,35,19,5,41,11,32,46,18,33,0,45,17,12,31,21,38,22,27,43,28]
    show_card_array(testCardArray)
    print("")
    # print(ThreeCardPokerGame.calResult(testCardArray, 5))
    print("")
    print(PokerBullGame.calResult(testCardArray,4))