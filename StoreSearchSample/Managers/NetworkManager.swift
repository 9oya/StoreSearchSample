//
//  NetworkManager.swift
//  StoreSearchSample
//
//  Created by Eido Goya on 2022/03/18.
//

import Foundation

protocol URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension URLSession: URLSessionProtocol {
}

protocol NetworkManagerProtocol {
    func dataTask(request: URLRequest,
                  completion: @escaping (Result<Data, Error>)->Void)
    func dataTask(request: URL,
                  completion: @escaping (Result<Data, Error>)->Void)
}

class NetworkManager: NetworkManagerProtocol {
    
    private let session: URLSessionProtocol
    
    init(session: URLSessionProtocol) {
        self.session = session
    }
    
    func dataTask(request: URLRequest,
                  completion: @escaping (Result<Data, Error>)->Void) {
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data,
                      let response = response as? HTTPURLResponse {
                if response.statusCode == 200 {
                    completion(.success(data))
                } else {
                    let error = NSError(domain: "",
                                        code: response.statusCode,
                                        userInfo: [NSLocalizedDescriptionKey: String(decoding: data, as: UTF8.self)])
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    func dataTask(request: URL,
                  completion: @escaping (Result<Data, Error>)->Void) {
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data,
                      let response = response as? HTTPURLResponse {
                if response.statusCode == 200 {
                    completion(.success(data))
                } else {
                    let error = NSError(domain: "",
                                        code: response.statusCode,
                                        userInfo: [NSLocalizedDescriptionKey: String(decoding: data, as: UTF8.self)])
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}
