//
//  GuessTheNumberTests.swift
//  GuessTheNumberTests
//
//  Created by Alexander on 13.09.24.
//

import XCTest
@testable import GuessTheNumber

final class GuessTheNumberTests: XCTestCase {
    var game: GameViewModel!
    
    override func setUpWithError() throws {
        game = GameViewModel()
    }
    
    override func tearDownWithError() throws {
        game = nil
    }
    
    func testNewRound() {
        game.reload()
    }
    
    func testRestart() {
        game.reload()
    }
}
