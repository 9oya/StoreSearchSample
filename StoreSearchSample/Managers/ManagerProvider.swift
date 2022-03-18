//
//  ManagerProvider.swift
//  StoreSearchSample
//
//  Created by Eido Goya on 2022/03/18.
//

import UIKit

protocol ManagerProviderProtocol {
    
}

struct ManagerProvider: ManagerProviderProtocol {
    
}

extension ManagerProvider {
    static func resolve() -> ManagerProviderProtocol {
        return ManagerProvider(
        )
    }
}
