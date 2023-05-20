from utils import random_card_array, show_card_array
from TinyNine import TinyNine

if __name__ == "__main__":
    testCardArray = random_card_array(40)
    show_card_array(testCardArray)
    print("")
    print(TinyNine.calResult(testCardArray, 6, 0, 5))