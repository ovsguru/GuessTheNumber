//
//  GameViewModel.swift
//  GuessTheNumber
//
//  Created by Alexander on 14.09.24.
//

import Foundation
import SwiftUI

enum GameState: Equatable {
    case loadingData, waitingUserAction,  error, passedSuccessfully, tryOtherValue
}

struct Alert {
    var message: String?
    var actionTitle: String
    var action: (()->())?
    
    mutating func build(message: String?, onAction: (()->())?) -> Alert {
        self.action = onAction
        self.message = message ?? self.message
        return self
    }
}

final class GameViewModel : ObservableObject {
    private var game: GameModel?
    private let randomNumberGenerator: IRandomNumberGenerator = RandomNumberGenerator()
    
    var rootVC: UIViewController?
    
    @Published var alertIsVisible = false
    @Published var gameState: GameState = .waitingUserAction
    
    @Published var userInputValue: String = ""
    
    @Published var alert: Alert?
    @Published var boundsText: String = ""
    
    var numberOfAttempts: Int {
        get {
            return game?.numberOfAttempts ?? 0
        }
    }

    func compareWihTarget(input: String) {
        guard let number = Int(input),
        let result = game?.compareAndUpdateAttemtsCount(input: number) else {
            return
        }
    
        switch result {
        case .guessed:
            alert = Alert(message: "Поздравляем, Вы угадали число!\nПопыток использовано: \(game?.numberOfAttempts ?? 1)", actionTitle: StringConstants.General.newGame, action: { [weak self] in
                self?.reload()
            })
            alertIsVisible = true
            userInputValue = ""
        case .greater:
            boundsText = "Введенное число \(number) больше загаданного"
            alertIsVisible = false
            userInputValue = ""
        default:
            boundsText = "Введенное число \(number) меньше загаданного"
            alertIsVisible = false
            userInputValue = ""
        }
    }
    
    func reload() {
        boundsText = ""
        userInputValue = ""
        gameState = .loadingData
        self.alert = nil
        randomNumberGenerator.generateRandomNumber { [weak self] result in
            switch result {
            case .success(let number):
                self?.game = GameModel(target: number)
                self?.gameState = .waitingUserAction
                self?.alertIsVisible = false
            case .failure(let error):
                self?.alertIsVisible = true
                self?.gameState = .error
                self?.alert = ErrorAlerts.defaultErrorAlert.build(message: error.errorMessage, onAction: { [weak self] in
                    self?.reload()
                })
                print(error.errorMessage)
            }
        }
    }
}

enum ErrorAlerts {
    static var defaultErrorAlert: Alert = Alert(message: StringConstants.ErrorMessages.technicalErrorMessageText, actionTitle: StringConstants.General.reload)
}

enum ResultAlerts {
    static var defaultSuccessAlert: Alert = Alert(message: StringConstants.ErrorMessages.technicalErrorMessageText, actionTitle: StringConstants.General.reload)
}
