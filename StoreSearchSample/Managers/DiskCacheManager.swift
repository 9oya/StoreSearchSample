//
//  DiskCacheManager.swift
//  StoreSearchSample
//
//  Created by Eido Goya on 2022/03/18.
//

import UIKit

protocol DiskCacheManagerProtocol {
    
    func storeIfNeed(key: String, data: Data) -> Bool
    
    func fetch(key: String) -> Data?
    
}

class DiskCacheManager: DiskCacheManagerProtocol {
    
    private let fileManager: FileManager
    
    init(fileManager: FileManager) {
        self.fileManager = fileManager
    }
    
    func storeIfNeed(key: String, data: Data) -> Bool {
        guard let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else {
            return false
        }
        var filePath = URL(fileURLWithPath: path)
        filePath.appendPathComponent(key)
        
        if !fileManager.fileExists(atPath: filePath.path) {
            return fileManager.createFile(atPath: filePath.path,
                                   contents: data, attributes: nil)
        }
        
        // file already exists
        return true
    }
    
    func fetch(key: String) -> Data? {
        if let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory,
                                                          .userDomainMask,
                                                          true).first {
            var filePath = URL(fileURLWithPath: path)
            filePath.appendPathComponent(key)
            if fileManager.fileExists(atPath: filePath.path),
               let data = try? Data(contentsOf: filePath) {
                return data
            }
        }
        return nil
    }
    
}
