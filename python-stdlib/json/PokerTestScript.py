from utils import random_card_array, show_card_array
# from .TinyNineGame import TinyNineGame
# from .ThreeCardPokerGame import ThreeCardPokerGame
# from .FiveCardStudGame import FiveCardStudGame
# from .ThreeToyGame import ThreeToyGame
# from .PokerBullGame import PokerBullGame
# from .BaccaratGame import BaccaratGame
from TexasPoker import TexasPokerGame



if __name__ == "__main__":
    testCardArray = random_card_array(52)
    testCardArray = [44, 49, 5, 15, 3, 12, 9, 6, 32, 20, 25, 19, 21, 0, 27, 37, 26, 33, 2, 4]
    #show_card_array(testCardArray)
    print("")
    print(TexasPokerGame.calResult(testCardArray, 3))
