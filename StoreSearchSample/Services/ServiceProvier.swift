//
//  ServiceProvier.swift
//  StoreSearchSample
//
//  Created by Eido Goya on 2022/03/18.
//

import Foundation

protocol ServiceProviderProtocol {
    var searchService: SearchServiceProtocol { get }
    var imageCacheService: ImageCacheServiceProtocol { get }
    var imageLoadService: ImageLoadServiceProtocol { get }
}

struct ServiceProvider: ServiceProviderProtocol {
    var searchService: SearchServiceProtocol
    var imageCacheService: ImageCacheServiceProtocol
    var imageLoadService: ImageLoadServiceProtocol
}

extension ServiceProvider {
    
    static func resolve() -> ServiceProviderProtocol {
        let provider = ManagerProvider.resolve()
        let searchService = SearchService(provider: provider,
                                          decoder: JSONDecoder())
        let imageCacheService = ImageCacheService(provider: provider)
        
        return ServiceProvider(
            searchService: searchService,
            imageCacheService: imageCacheService,
            imageLoadService: ImageLoadService(searchService: searchService,
                                               imageCacheService: imageCacheService)
        )
    }
    
}
