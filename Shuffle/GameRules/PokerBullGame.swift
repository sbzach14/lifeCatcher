//
//  PokerBullGame.swift
//  Shuffle
//
//  Created by Ariel on 2023/8/24.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation


//# UI STRUCTURE TO ARGUMENT VALUE
//# number of cards -> int value:
//# 0: 20, 1: 32, 2: 36, 3: 40, 4: 42, 5: 52, 6: 54
//
//# way to deal cards -> int value:
//# 0, normal dealing, 5 cards each
//# 1, one card each for the first round and begin from the largest card
//# 2, normal dealing, 3 cards each
//# 3, normal dealing, 4 cards each*
//# 4, normal dealing, 10 cards each*
//
//# numberchangearray
//# if card number change -> int Array:
//# 0, 10 -> 0, 1, 1/0(计算点数时还是10)*, 1/0(计算点数时候时0/1)*
//# 1, J -> 0, 1, 11
//# 2, Q -> 0, 1, 2, 12
//# 3, K -> 0, 1, 6, 13
//# 4, BLACKJoker ->0, 1, 3, any*
//# 5, REDJOKER ->0, 1, 6, any*
//# 6, 3 -> 3, 3/6*
//# 7, 6 -> 6, 3/6*
//# 8, Spade A -> 1, 0(公牌)
//
//# Bull Rule for dealing 0, 1 -> int Array 0->no 1->yes:
//# 0, any three cards equal to 10 * n
//# 1, total five cards equal to 10 * n
//# 2, Threecard
//# 3, thress card straight
//# 4, only contains J,K,Q,A,JOKER is BULLBULL(不看点数)
//# 5, Three cards equal to 1
//# 6, Five cards sum <= 10 (sum is the Bull number, exp. 1,2,2,2,1 牛8)
//# 7, five cards sum <= 9
//# 8, any three cards equal to 10 * n and at least > 20
//
//# Rank Rule for dealing 0, 1, 4-> int Array
//# 0, five cards sum >= 40
//# 1, Fourcard
//# 2, five cards sum <= 10
//# 3, five cards sum == 20 and have bull
//# 4, five cards sum == 30 and have bull
//# 5, Threecard and other two sum == 10
//# 6, five cards sum == 20 or 30
//# 7, Fullhouse
//# 8, straight
//# 9, Bullbull
//# 10, Bull
//# 11, GoldBull (JQK)
//# 12, SilverBull (JQK10)
//# 13, Twopair
//# 14, BullNine
//# 15, Onepair
//# 16, Flush
//# 17, all cards < 5
//# 18, DiamandBull(JQKJOKER)
//# 19, Bull+9pair max
//# 20, Bull + JQ
//# 21, Bull + 10J
//# 22, Bull + A10
//# 23, 235+pair
//# 24, Bull + 10pair max
//# 25, five cards sum = 40
//# 26, IRONBULL threecard + other two sums 10 * n
//# 27, same color, all red or all black
//# 28, straight Bull
//# 29, hard bull three 2,3,5 -> bull
//# 30，StraightFlush
//# 31, FiveOne
//# 32, five cards sum == 10
//# 33, five cards sum == 20
//# 34, five cards sum == 30
//# 35, five cards sum == 40
//# 36, five cards sum == 5
//# 37, spade A with JQK
//# 38, BUll + Apairmax
//# 39, BUll with spade A
//# 40, GoldBull with Spade A
//
//# Rank Rule for dealing 2-> int Array
//# 0，threecard
//# 1, KQJ
//# 2, QJ10
//# 3, sum = 10 bull
//# 4, StraightFlush
//# 5, Straight
//
//
//# Second rank rule ->int Array
//# 0, 0 同牛同点比最大牌，无牛比最大牌, 1 同牛同点比牛架后的两张, 无牛比最大 2 同牛同点一样大，无牛一样大
//# 3, 五小一样大
//# 4, 五小谁小谁大
//# 5, 五小谁大谁大
//# 6, 顺子五小一样大*
//# 7, 不分花色
//# 8, 无牛只比最大两张牌
//# 9，Joker是最小的0*
