//
//  RandomNumberGenerator.swift
//  GuessTheNumber
//
//  Created by Alexander on 13.09.24.
//

import Foundation

protocol IRandomNumberGenerator {
    func generateRandomNumber(complition: ((Result<Int, NetworkLayerError>)->())?)
}

final class RandomNumberGenerator: IRandomNumberGenerator {
    private var currentRequest: URLSessionDataTask?
    
    func generateRandomNumber(complition: ((Result<Int, NetworkLayerError>) -> ())?) {
        currentRequest?.cancel()
        currentRequest = FetchRandomNumberAction().execute { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let result):
                    complition?(.success(result))
                case .failure(let error):
                    guard (error as NSError).code != NSURLErrorCancelled else {
                        return
                    }
                    complition?(.failure(error as? NetworkLayerError ?? .technicalError))
                }
            }
        }
    }
}
