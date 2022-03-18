//
//  ImageLoadService.swift
//  StoreSearchSample
//
//  Created by Eido Goya on 2022/03/18.
//

import UIKit
import RxSwift

protocol ImageLoadServiceProtocol {
    
    func fetchCachedImage(_ urlStr: String)
    -> PrimitiveSequence<SingleTrait, Result<(String, UIImage?), Error>>
    
    func downloadImage(_ result: Result<(String, UIImage?), Error>)
    -> PrimitiveSequence<SingleTrait, Result<(String, UIImage), Error>>
    
    func cacheImage(_ result: Result<(String, UIImage), Error>)
    -> PrimitiveSequence<SingleTrait, Result<(String, UIImage), Error>>
    
}

class ImageLoadService: ImageLoadServiceProtocol {
    
    var searchService: SearchServiceProtocol?
    var imageCacheService: ImageCacheServiceProtocol?
    var disposeBag = DisposeBag()
    
    init(searchService: SearchServiceProtocol,
         imageCacheService: ImageCacheServiceProtocol) {
        self.searchService = searchService
        self.imageCacheService = imageCacheService
    }
    
    func fetchCachedImage(_ urlStr: String) -> PrimitiveSequence<SingleTrait, Result<(String, UIImage?), Error>> {
        let key = urlStr.removeSpecialCharsFromString()
        return Single.create { [weak self] single in
            guard let `self` = self else { return Disposables.create() }
            self.imageCacheService?
                .fetchCachedImage(key: key)
                .asObservable()
                .bind(onNext: { result in
                    switch result {
                    case .failure(let error):
                        single(.failure(error))
                    case .success(let image):
                        single(.success(.success((key, image))))
                    }
                }).disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    func downloadImage(_ result: Result<(String, UIImage?), Error>) -> PrimitiveSequence<SingleTrait, Result<(String, UIImage), Error>> {
        return Single.create { [weak self] single in
            guard let `self` = self else { return Disposables.create() }
            switch result {
            case .failure(let error):
                single(.failure(error))
            case let .success((urlStr, image)):
                if image != nil {
                    single(.success(.success((urlStr, image!))))
                    return Disposables.create()
                }
                self.searchService?
                    .download(urlStr: urlStr)
                    .asObservable()
                    .bind(onNext: { result in
                        switch result {
                        case .failure(let error):
                            single(.failure(error))
                        case .success(let image):
                            single(.success(.success((urlStr, image))))
                        }
                    })
                    .disposed(by: self.disposeBag)
            }
            return Disposables.create()
        }
    }
    
    func cacheImage(_ result: Result<(String, UIImage), Error>) -> PrimitiveSequence<SingleTrait, Result<(String, UIImage), Error>> {
        return Single.create { [weak self] single in
            guard let `self` = self else { return Disposables.create() }
            switch result {
            case .failure(let error):
                single(.failure(error))
            case let .success((urlStr, image)):
                self.imageCacheService?
                    .cacheImage(key: urlStr,
                                image: image)
                    .asObservable()
                    .bind(onNext: { result in
                        switch result {
                        case .failure(let error):
                            single(.failure(error))
                        case .success(let image):
                            single(.success(.success((urlStr, image))))
                        }
                    })
                    .disposed(by: self.disposeBag)
            }
            return Disposables.create()
        }
    }
    
}
