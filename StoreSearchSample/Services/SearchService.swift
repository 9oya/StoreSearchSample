//
//  SearchService.swift
//  StoreSearchSample
//
//  Created by Eido Goya on 2022/03/18.
//

import RxSwift

enum DownloadImageError: Error, CustomStringConvertible {
    case invalidUrlStr
    case invalidData
    
    var description: String {
        switch self {
        case .invalidUrlStr:
            return "DownloadImageError: invalidUrlStr"
        case .invalidData:
            return "DownloadImageError: invalidData"
        }
    }
}

protocol SearchServiceProtocol {
    
    func search(term: String, entity: String, country: String, limit: String)
    -> PrimitiveSequence<SingleTrait, Result<SearchResponseModel, Error>>
    
    func download(urlStr: String)
    -> PrimitiveSequence<SingleTrait, Result<UIImage, Error>>
    
}

class SearchService: SearchServiceProtocol {
    
    var provider: ManagerProviderProtocol
    var decoder: JSONDecoder
    
    init(provider: ManagerProviderProtocol,
         decoder: JSONDecoder) {
        self.provider = provider
        self.decoder = decoder
    }
    
    func search(term: String, entity: String, country: String, limit: String)
    -> PrimitiveSequence<SingleTrait, Result<SearchResponseModel, Error>> {
        let req = NetworkRouter
            .search(term: term, entity: entity, country: country, limit: limit)
            .asURLRequest()
        return Single.create { [weak self] single in
            self?.provider
                .networkManager
                .dataTask(request: req) { result in
                    switch result {
                    case .failure(let error):
                        single(.failure(error))
                    case .success(let data):
                        do {
                            if let model = try self?.decoder
                                .decode(SearchResponseModel.self,
                                        from: data) {
                                single(.success(.success(model)))
                            }
                        } catch let error {
                            single(.failure(error))
                        }
                    }
                }
            return Disposables.create()
        }
    }
    
    func download(urlStr: String)
    -> PrimitiveSequence<SingleTrait, Result<UIImage, Error>> {
        return Single.create { [weak self] single in
            guard let `self` = self else { return Disposables.create() }
            guard let url = URL(string: urlStr) else {
                single(.failure(DownloadImageError.invalidUrlStr))
                return Disposables.create()
            }
            self.provider
                .networkManager
                .dataTask(request: url) { result in
                    switch result {
                    case .failure(let error):
                        single(.failure(error))
                    case .success(let data):
                        if let image = UIImage(data: data) {
                            single(.success(.success(image)))
                        } else {
                            single(.failure(DownloadImageError.invalidData))
                        }
                    }
                }
            return Disposables.create()
        }
    }
    
}
