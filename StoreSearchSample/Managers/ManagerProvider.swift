//
//  ManagerProvider.swift
//  StoreSearchSample
//
//  Created by Eido Goya on 2022/03/18.
//

import UIKit

protocol ManagerProviderProtocol {
    var networkManager: NetworkManagerProtocol { get }
    var memoryCacheManager: MemoryCacheManagerProtocol { get }
    var diskCacheManager: DiskCacheManagerProtocol { get }
}

struct ManagerProvider: ManagerProviderProtocol {
    var networkManager: NetworkManagerProtocol
    var memoryCacheManager: MemoryCacheManagerProtocol
    var diskCacheManager: DiskCacheManagerProtocol
}

extension ManagerProvider {
    
    static func resolve() -> ManagerProviderProtocol {
        let urlSession = URLSession(configuration: .default)
        let imageCache = NSCache<NSString, UIImage>()
        let fileManager = FileManager.default
        
        return ManagerProvider(
            networkManager: NetworkManager(session: urlSession),
            memoryCacheManager: MemoryCacheManager(cacheManager: imageCache),
            diskCacheManager: DiskCacheManager(fileManager: fileManager)
        )
    }
    
}
