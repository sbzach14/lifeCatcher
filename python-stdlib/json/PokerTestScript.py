from .utils import random_card_array, show_card_array
# from .TinyNineGame import TinyNineGame
# from .ThreeCardPokerGame import ThreeCardPokerGame
# from .FiveCardStudGame import FiveCardStudGame
# from .ThreeToyGame import ThreeToyGame
# from .PokerBullGame import PokerBullGame
# from .BaccaratGame import BaccaratGame
from TexasPoker import TexasPokerGame



if __name__ == "__main__":
    testCardArray = random_card_array(52)
    testCardArray = [46, 10, 41, 0, 38, 42, 15, 26, 30, 8, 51, 49, 2, 24, 39, 14]
    #show_card_array(testCardArray)
    print(TexasPokerGame.calResult(testCardArray, [3, 0, 1, 2, 2, 5, 0, 0], [11, 10, 9, 8, 7, 6, 2, 1, 0], [3,2,1,0]))
