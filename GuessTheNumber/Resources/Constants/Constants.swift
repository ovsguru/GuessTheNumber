//
//  Constants.swift
//  GuessTheNumber
//
//  Created by Alexander on 13.09.24.
//

import Foundation

enum StringConstants {
    enum ErrorMessages {
        static let noDataErrorMessageText = "Не удалось сгенерировать число. Повторите попытку"
        static let technicalErrorMessageText = "Произошла ошибка. Повторите попытку позже"
    }
    
    enum General {
        static let newGame = "Новая игра"
        static let reload = "Перезагрузить"
    }
}

enum UIConstants {
  enum General {
    public static let strokeWidth = CGFloat(2.0)
    public static let roundedViewLength = CGFloat(56.0)
    public static let roundRectViewWidth = CGFloat(68.0)
    public static let roundRectViewHeight = CGFloat(56.0)
    public static let roundRectCornerRadius = CGFloat(21.0)
  }
}

enum Assets {
    static let keyboard = "ic_keyboard_down"
}
