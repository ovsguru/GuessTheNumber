//
//  GameModel.swift
//  GuessTheNumber
//
//  Created by Alexander on 13.09.24.
//

/// Used as game state machine as compare input number with target value:
/// - guessed: user guessed target value
/// - greater: user should try less number
/// - less: user should try greater number
enum GameActionResult {
    case guessed(attemtsCount: Int)
    case less
    case greater
}

struct GameModel {
    let target: Int
    var numberOfAttempts = 0
    
    init(target: Int) {
        self.target = target
    }
    
    /// Comparation method on input value and target and update numberOfAttempts
    mutating func compareAndUpdateAttemtsCount(input: Int) -> GameActionResult {
        numberOfAttempts += 1
        guard input != target else {
            return .guessed(attemtsCount: numberOfAttempts)
        }
        
        return input < target ? .less : .greater
    }
}
