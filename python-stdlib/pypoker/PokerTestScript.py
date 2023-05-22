from utils import random_card_array, show_card_array
from TinyNine.TinyNineGame import TinyNineGame
from ThreeCardPoker.ThreeCardPokerGame import ThreeCardPokerGame

if __name__ == "__main__":
    #testCardArray = random_card_array(52)
    testCardArray = [23, 41, 46, 13, 37, 27, 40, 19, 11, 2, 42, 43, 48, 47, 30, 36, 35, 10]
    show_card_array(testCardArray)
    print("")
    print(ThreeCardPokerGame.calResult(testCardArray, 5))