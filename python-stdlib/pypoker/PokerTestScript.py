from utils import random_card_array, show_card_array
from TinyNine.TinyNineGame import TinyNineGame
from ThreeCardPoker.ThreeCardPokerGame import ThreeCardPokerGame
from FiveCardStud.FiveCardStudGame import FiveCardStudGame
from ThreeToy.ThreeToyGame import ThreeToyGame

if __name__ == "__main__":
    #testCardArray = random_card_array(52)
    testCardArray = [12, 42, 18, 19, 16, 22, 26, 29, 14, 4]
    show_card_array(testCardArray)
    print("")
    print(ThreeToyGame.calResult(testCardArray, 3))