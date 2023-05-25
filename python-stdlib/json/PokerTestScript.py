from utils import random_card_array, show_card_array
from TinyNine.TinyNineGame import TinyNineGame
from ThreeCardPoker.ThreeCardPokerGame import ThreeCardPokerGame
from FiveCardStud.FiveCardStudGame import FiveCardStudGame
from ThreeToy.ThreeToyGame import ThreeToyGame
from PokerBull.PorkerBullGame import PokerBullGame
from Baccarat.BaccaratGame import BaccaratGame



if __name__ == "__main__":
    #testCardArray = random_card_array(52)
    testCardArray = [34,28,8,46,42,29]
    show_card_array(testCardArray)
    print("")
    print(BaccaratGame.calResult(testCardArray, 2))
