//
//  NetworkRouter.swift
//  StoreSearchSample
//
//  Created by Eido Goya on 2022/03/18.
//

import Foundation

enum HTTPHeaderField: String {
    case authentication = "Authorization"
    case contentType = "Content-Type"
    case acceptType = "accept"
    case acceptEncoding = "Accept-Encoding"
    case userAgent = "User-Agent"
    case appToken = "App-Token"
}

enum AcceptType: String {
    case anyMIMEgtype = "*/*"
}

enum ContentType: String {
    case json = "application/json; charset=utf-8"
    case xwwwFormUrlencoded = "application/x-www-form-urlencoded; charset=utf-8"
}

enum HTTPStatus: Int {
  case ok = 200

  case badRequest = 400
  case notAuthorized = 401
  case paymentRequired = 402
  case forbidden = 403
  case notFound = 404

  case internalServerError = 500
}

enum NetworkRouter {
    
    // MARK: Base URL
    static let baseURL = "https://itunes.apple.com/search"
    
    // MARK: Cases
    // GET
    case search(term: String, entity: String, country: String, limit: String)
    
    // MARK: HTTPMethod
    private var method: String {
        switch self {
        case .search:
            return "GET"
        }
    }
    
    // MARK: Path
    private var path: String {
        switch self {
        case .search:
            return "/search"
        }
    }
    
    // MARK: Parameters
    private var parameters: [String: Any]? {
        switch self {
        case .search:
            return nil
        }
    }
    
    // MARK: QueryStrings
    private var queryItems: [URLQueryItem]? {
        var queryItems = [URLQueryItem]()
        
        switch self {
        case let .search(term, entity, country, limit):
            queryItems.append(URLQueryItem(name: "term", value: term))
            queryItems.append(URLQueryItem(name: "entity", value: entity))
            queryItems.append(URLQueryItem(name: "country", value: country))
            queryItems.append(URLQueryItem(name: "limit", value: limit))
        }
        
        guard let appId = Bundle.main.object(forInfoDictionaryKey: "APIKEY") as? String else {
            return queryItems
        }
        queryItems.append(URLQueryItem(name: "appid", value: appId))
        
        return queryItems
    }
    
    // MARK: HTTPHeader
    private func getAdditionalHttpHeaders() -> [(String, String)] {
        var headers = [(String, String)]()
        switch self {
        case .search:
            headers = [(String, String)]()
            return headers
        }
    }
    
    func asURLRequest() -> URLRequest {
        // Base URL
        let url: URL = URL(string: NetworkRouter.baseURL)!
        
        // Path
        var urlComponents = URLComponents(url: url.appendingPathComponent(path), resolvingAgainstBaseURL: false)
        
        // QueryStrings
        if let queryItems = queryItems {
            urlComponents?.queryItems = queryItems
        }
        
        // URLRequest
        var urlRequest = URLRequest(url: urlComponents!.url!)
        
        // HTTP Method
        urlRequest.httpMethod = method
        
        // Common Headers
        urlRequest.addValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.acceptEncoding.rawValue)
        
        // Additional Headers
        let headers = getAdditionalHttpHeaders()
        headers.forEach { (header) in
            urlRequest.addValue(header.1, forHTTPHeaderField: header.0)
        }
        
        // Parameters
        if let parameters = parameters {
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            } catch let error {
                print(error.localizedDescription)
            }
        }
        
        return urlRequest
    }
}
