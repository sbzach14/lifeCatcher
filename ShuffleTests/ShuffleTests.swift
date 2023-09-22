//
//  ShuffleTests.swift
//  ShuffleTests
//
//  Created by Ariel on 2023/8/25.
//  Copyright © 2023 Apple. All rights reserved.
//

import XCTest
@testable import Shuffle

final class ShuffleTests: XCTestCase {
    
    let cardLabelDic : [Int:String] = [
        0: "♠️A ", 1: "♠️2", 2: "♠️3", 3: "♠️4", 4: "♠️5 ", 5: "♠️6 ", 6: "♠️7 ", 7: "♠️8 ", 8: "♠️9 ", 9: "♠️10 ",
        10: "♠️J ", 11: "♠️Q ", 12: "♠️K ", 13: "♥️A ", 14: "♥️2 ", 15: "♥️3 ", 16: "♥️4 ", 17: "♥️5 ", 18: "♥️6 ",
        19: "♥️7 ", 20: "♥️8 ", 21: "♥️9 ", 22: "♥️10 ", 23: "♥️J ", 24: "♥️Q ", 25: "♥️K ", 26: "♣️A ", 27: "♣️2 ",
        28: "♣️3 ", 29: "♣️4 ", 30: "♣️5 ", 31: "♣️6 ", 32: "♣️7 ", 33: "♣️8 ", 34: "♣️9 ", 35: "♣️10 ", 36: "♣️J ",
        37: "♣️Q ", 38: "♣️K ", 39: "♦️A ", 40: "♦️2 ", 41: "♦️3 ", 42: "♦️4 ", 43: "♦️5 ", 44: "♦️6", 45: "♦️7",
        46: "♦️8 ", 47: "♦️9 ", 48: "♦️10 ", 49: "♦️J ", 50: "♦️Q ", 51: "♦️K ", 52: "none", 53: "小王", 54: "大王"
    ]
    

//    override func setUpWithError() throws {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDownWithError() throws {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        for i in 0...9{
            print("Test Case ", i)
            var randomSet = Set<Int>()
            while randomSet.count < 7{
                let randomIndex = Int.random(in: 0...51)
                randomSet.insert(randomIndex)
            }
            
            var testCardIndexArray = Array(randomSet)
//            testCardIndexArray = [0,13,26,39,1]
            testPipeLine(testGameName:"Texas",testCardIndexArray: testCardIndexArray)
            print("Test End")
        }
    }
    //modify to whatever you want
    func testPipeLine(testGameName: String, testCardIndexArray: [Int]){
        showCardInfo(inputArray: testCardIndexArray)
        let cards = generateHandCards(inputArray: testCardIndexArray)
        //Texas
        if testGameName == "Texas"{
            let handCards = Array(cards.prefix(2))
            let community = Array(cards.suffix(5))
            let isCompareSuit:Bool = false
            let isAceStraight:Bool = false
            let minRank:Int = 2
            let handUseType:Int = 0
            let handUseNum:Int = 1
            let rankRules:[RankRulesSate] = [
                RankRulesSate(index: 11, isChecked: true),
                RankRulesSate(index: 10, isChecked: true),
                RankRulesSate(index: 9, isChecked: true),
                RankRulesSate(index: 8, isChecked: true),
                RankRulesSate(index: 7, isChecked: true),
                RankRulesSate(index: 6, isChecked: true),
                RankRulesSate(index: 5, isChecked: false),
                RankRulesSate(index: 4, isChecked: false),
                RankRulesSate(index: 3, isChecked: false),
                RankRulesSate(index: 2, isChecked: true),
                RankRulesSate(index: 1, isChecked: true),
                RankRulesSate(index: 0, isChecked: true)
            ]
            let rankIntRules:[Int] =  GameManager.getCheckedIndexes(rankRules: rankRules)
            
            HandEvaluator.evalHand(cards: handCards, community: community, isCompareSuit: isCompareSuit, isAceStraight: isAceStraight, minRank: minRank, handUseType: handUseType, handUseNum: handUseNum, rankRules: rankIntRules)
            
            
            
        }
        //PokerBull
        if testGameName == "PokerBull"{
            let bullcards = generateHandBullCards(inputCards: cards, numberChangeArray: [0,0,0,0,0,0,0,0,0], isNoSuit: 0, jokerMinZero: 0)
            print(BullHandEvaluator.isFiveCardsSumEqualsToTwentyAndHaveBulls(cards: bullcards))
        }
        
    }
    
    func showCardInfo(inputArray: [Int]){
        var infoString : String = ""
        
        for cardIndex in inputArray{
            infoString += cardLabelDic[cardIndex]! + " "
        }
        print(infoString)
        
    }
    // 用来看牛的信息
    func bullInfo(inputBulls:[[PokerBullGame.PokerBullCard]]){
        
        
        for bull in inputBulls{
            var infoString : String = "组牛"
            for bullCard in bull{
                let cardIndex = (bullCard.trueRank - 1) + bullCard.suit * 13
                infoString += cardLabelDic[cardIndex]! + " "
            }
            print(infoString)
        }
        
    }
    
    func bullCardToInfo(inputBullCards: [PokerBullGame.PokerBullCard]){
        var infoString : String = ""
        
        for bullcard in inputBullCards{
            let cardIndex = bullcard.trueRank + bullcard.suit * 13
            infoString += cardLabelDic[cardIndex]! + " "
            
        }
        print(infoString)
    }
    
    
    func generateHandCards(inputArray: [Int])->[Card]{
        var returnCard:[Card] = []
        for cardIndex in inputArray{
            let suit = [cardIndex / 13]
            let rank = (cardIndex % 13) + 1
            let card = Card(suit: suit, rank: rank)
            returnCard.append(card)
        }
        return returnCard
    }
    
    func generateHandBullCards(inputCards:[Card], numberChangeArray:[Int], isNoSuit:Int, jokerMinZero: Int) -> [PokerBullGame.PokerBullCard]{
        var returnCard:[PokerBullGame.PokerBullCard] = []
        
        for card in inputCards{
            let bullCard = PokerBullGame.PokerBullCard(card: card, numberChangeArray: numberChangeArray, isNoSuit: 0, jokerMinZero: 0)
            returnCard.append(bullCard)
        }
        
        return returnCard
    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
