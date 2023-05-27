from utils import random_card_array, show_card_array
from .TinyNineGame import TinyNineGame
from .ThreeCardPokerGame import ThreeCardPokerGame
from .FiveCardStudGame import FiveCardStudGame
from .ThreeToyGame import ThreeToyGame
from .PokerBullGame import PokerBullGame
from .BaccaratGame import BaccaratGame



if __name__ == "__main__":
    #testCardArray = random_card_array(52)
    testCardArray = [34,28,8,46,42,29]
    show_card_array(testCardArray)
    print("")
    print(BaccaratGame.calResult(testCardArray, 4))
