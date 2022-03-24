//
//  ImageCacheService.swift
//  StoreSearchSample
//
//  Created by Eido Goya on 2022/03/18.
//

import UIKit
import RxSwift

enum CacheError: Error, CustomStringConvertible {
    case invalidImage
    case failureDiskStore
    
    var description: String {
        switch self {
        case .invalidImage:
            return "CacheError: invalidImage"
        case .failureDiskStore:
            return "CacheError: failureDiskStore"
        }
    }
}

protocol ImageCacheServiceProtocol {
    
    func cacheImage(key: String,
                    image: UIImage)
    -> PrimitiveSequence<SingleTrait, Result<UIImage, Error>>
    
    func fetchCachedImage(key: String)
    -> PrimitiveSequence<SingleTrait, Result<UIImage?, Error>>
    
}

class ImageCacheService: ImageCacheServiceProtocol {
    
    var provider: ManagerProviderProtocol
    
    init(provider: ManagerProviderProtocol) {
        self.provider = provider
    }
    
    func cacheImage(key: String, image: UIImage)
    -> PrimitiveSequence<SingleTrait, Result<UIImage, Error>> {
        return Single.create { [weak self] single in
            guard let `self` = self else { return Disposables.create() }
            self.provider
                .memoryCacheManager
                .store(key: key,
                       image: image)
            guard let data = image.pngData() else {
                single(.failure(CacheError.invalidImage))
                return Disposables.create()
            }
            _ = self.provider
                .diskCacheManager
                .storeIfNeed(key: key,
                             data: data)
            single(.success(.success(image)))
            
            return Disposables.create()
        }
    }
    
    func fetchCachedImage(key: String)
    -> PrimitiveSequence<SingleTrait, Result<UIImage?, Error>> {
        return Single.create { [weak self] single in
            guard let `self` = self else { return Disposables.create() }
            if let cachedImg = self.provider
                .memoryCacheManager
                .fetch(key: key) {
                single(.success(.success(cachedImg)))
            } else if let cachedData = self.provider
                        .diskCacheManager
                        .fetch(key: key),
                      let cachedImg = UIImage(data: cachedData) {
                self.provider
                    .memoryCacheManager
                    .store(key: key, image: cachedImg)
                single(.success(.success(cachedImg)))
            } else {
                single(.success(.success(nil)))
            }
            return Disposables.create()
        }
    }
}
