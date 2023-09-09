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
    

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        let isCompareSuit = 0
        let isAceStraight = 1
        let minRank = 0
        let handNum = 1
        let communityNum = 2
        let handUseType = 0
        let handUseNum = 0
        let suitRules = [3,2,1,0]
        let rankRules = [
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
        
        let cardArray = [1,2,3]
        let args = [1,2,3]
        let result =  TexasPokerGame.calResult(cardArray: cardArray, args: args, rankRules: GameManager.getCheckedIndexes(rankRules: rankRules), suitRules: suitRules)
        
        
        print("test test")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
