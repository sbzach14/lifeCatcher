import Foundation


class Tester{
    var playerNum : Int
    var players : [Int]
    var permutation : [Int]
    var holeCards : [[Int]]
    var commonCards : [Int]

    init(playerNum: Int){
        self.playerNum = playerNum // at most 22 players
        self.permutation = Array(0...51)
        self.players = Array(0..<playerNum)
        self.holeCards = []
        self.commonCards = []

    }

    func permuting(){
        // randomly generate permutation by swaping
        for i in 0...51{
            let j = Int.random(in : i...51)
            let temp = self.permutation[i]
            self.permutation[i] = self.permutation[j]
            self.permutation[j] = temp
        }
        //print(self.permutation)
    }

    func dealing(){
        // distributing hole cards in two rounds, burning one card before flop,turn,river
        for i in 0..<self.playerNum{
            self.holeCards.append( [ self.permutation[i] , self.permutation[i+self.playerNum] ] )
        }
        let preFlop = 2*self.playerNum
        self.commonCards = [ permutation[preFlop+1],permutation[preFlop+2],permutation[preFlop+3],permutation[preFlop+5],permutation[preFlop+7] ]
    }


    func test() -> String{
        var result : String = ""
        result += "Test begins!\n"
        result += "The common cards are:\n"
        for card in self.commonCards{
            result += (TexasPoker.intToStr(card:card)+"  ")
        }

        
        result += "\nThe holeCards are:\n"
        for i in 0..<self.playerNum{
            result += ("Player "+String(i)+":   ")
            result += TexasPoker.intToStr(card:self.holeCards[i][0])
            result += "   "
            result += TexasPoker.intToStr(card:self.holeCards[i][1])
            result += "\n"
        }
        
        result += "The winners are:\n"
        if let winners = TexasPoker.findWinningPlayer(inputCards: self.permutation, playerNum: self.playerNum) {
            for winner in winners{
                result += String(winner)
                result += "\n"
            }
            
        }
        return result
        }
    
    func display() -> String{
        var result : String = ""
        result += "Each player has the following cards:\n"
        for k in 0..<self.playerNum {
            let kthHandNum = self.holeCards[k]+self.commonCards
            let kthHand = kthHandNum.map{TexasPoker.intToStr(card : $0)}
            let score = TexasPoker.handScore(hand : kthHand)
            
            result += "["
            for card in kthHand{
                result += card
                result += ", "
            }
            result += "]   Score="
            result += String(score)
            result += "\n"
        }
        return result
    }


}






var poker = TexasPoker()
var tester = Tester(playerNum : 4) // input number of players
tester.permuting()
tester.dealing()
let result = tester.test()
let info = tester.display()
print(result)
print(info)






/*
var myHand = ["2h", "2d", "2s", "2c", "3d", "4d", "7d"]
var myHandSorted = myHand.sorted(by : TexasPoker.compareCards)
myHandSorted.reverse()
print(myHandSorted)
print("straightflush: ",TexasPoker.checkStraightflush(handSorted : myHandSorted))
print("fourcards: ",TexasPoker.checkFourcards(handSorted : myHandSorted))
print("fullhouse: ",TexasPoker.checkFullhouse(handSorted : myHandSorted))
print("flush: ",TexasPoker.checkFlush(handSorted : myHandSorted))
print("straight: ",TexasPoker.checkStraight(handSorted : myHandSorted))
print("threecards: ",TexasPoker.checkThreecards(handSorted : myHandSorted))
print("twopairs: ",TexasPoker.checkTwopairs(handSorted : myHandSorted))
print("onepair: ",TexasPoker.checkOnepair(handSorted : myHandSorted))
print("highcard: ",TexasPoker.checkHighcard(handSorted : myHandSorted))
*/







