//
//  NetworkService.swift
//  GuessTheNumber
//
//  Created by Alexander on 13.09.24.
//

import Foundation

// MARK: - ITaskCancelable
protocol ITaskCancelable {
    func cancel()
}

// MARK: - Base Network Errors
enum NetworkLayerError: Error {
    case noData
    case technicalError
    
    var errorMessage: String {
        switch self {
        case .noData:
            return StringConstants.ErrorMessages.noDataErrorMessageText
        case .technicalError:
            return StringConstants.ErrorMessages.technicalErrorMessageText
        }
    }
}

// MARK: - NetworkService
final class NetworkService {
    static var baseURL = SettingsHelper.currentStand.serverURL
}

// MARK: - StandSetting
enum StandSetting: String {
    case dev = "api_stand_dev"
    case prod = "api_stand_prod"
    
    var serverURL: String {
        switch self {
        case .dev:
            return "http://www.randomnumberapi.com"
        case .prod:
            return "http://www.randomnumberapi.com"
        }
    }
}

// MARK: - SettingsHelper
final class SettingsHelper {
    
    static var currentStand: StandSetting {
        #if DEBUG
        guard // base url change support
            let standKey = UserDefaults.standard.value(forKey: "api_stand_key") as? String,
            let standSetting = StandSetting(rawValue: standKey)
        else { return .dev }
        
        return standSetting
        #else
        return .prod
        #endif
    }
    
}
