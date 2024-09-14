//
//  FetchRandomNumberAction.swift
//  GuessTheNumber
//
//  Created by Alexander on 13.09.24.
//

import Foundation

// MARK: - IFetchRandomNumberDataTaskExecutable
protocol IFetchRandomNumberDataTaskExecutable: ITaskCancelable {
    func execute(complition: ((Result<Int, Error>)->())?) -> URLSessionDataTask
}

// MARK: - FetchRandomNumberAction
struct FetchRandomNumberAction {
    var session: URLSession
    var url: URL
    
    var headers: [String : String] = [
        "Content-Type" : "application/json",
    ]
    
    var method: String = "GET"
    
    init(session: URLSession = URLSession.shared,
         count: Int = 1,
         numMin: Int = 1,
         numMax: Int = 100) {
        self.headers = [
            "Content-Type" : "application/json"
        ]
        self.session = session
        url = URL(string: NetworkService.baseURL + "/api/v1.0/random?min=\(numMin)&max=\(numMax)&count=\(count)")!
    }
}

// MARK: - FetchRandomNumberAction IFetchRandomNumberDataTaskExecutable conformance
extension FetchRandomNumberAction: IFetchRandomNumberDataTaskExecutable {
    func cancel() {
        session.invalidateAndCancel()
    }
    
    func execute(complition: ((Result<Int, Error>) -> ())?) -> URLSessionDataTask {
        var request = URLRequest(url: url)
       // request.allHTTPHeaderFields = headers
        request.httpMethod = method
        let task = session.dataTask(with: request) { data, response, error in
            guard error == nil else {
                complition?(.failure(error ?? NetworkLayerError.technicalError))
                return
            }
            
            if let data = data {
                do {
                    let result = try JSONDecoder().decode([Int].self, from: data)
                    guard let fetchedRandomNumber = result.first else {
                        complition?(.failure(NetworkLayerError.noData))
                        return
                    }
                    complition?(.success(fetchedRandomNumber))
                } catch {
                    complition?(.failure(NetworkLayerError.noData))
                }
            }
        }
        
        task.resume()
        return task
    }
}

