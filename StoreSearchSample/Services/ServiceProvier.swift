//
//  ServiceProvier.swift
//  StoreSearchSample
//
//  Created by Eido Goya on 2022/03/18.
//

import UIKit

protocol ServiceProvierProtocol {
    
}

struct ServiceProvier: ServiceProvierProtocol {
    
}

extension ServiceProvier {
    static func resolve() -> ServiceProvierProtocol {
        return ServiceProvier(
        )
    }
}
