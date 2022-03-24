//
//  DetailInfoModel.swift
//  StoreSearchSample
//
//  Created by Eido Goya on 2022/03/24.
//

import UIKit

struct DetailInfoModel {
    let title: String
    let subTitle: String?
    let descTxt: String?
    let rating: Float?
    let image: UIImage?
    
    init(title: String,
         subTitle: String? = nil,
         descTxt: String? = nil,
         rating: Float? = nil,
         image: UIImage? = nil) {
        self.title = title
        self.subTitle = subTitle
        self.descTxt = descTxt
        self.rating = rating
        self.image = image
    }
}
