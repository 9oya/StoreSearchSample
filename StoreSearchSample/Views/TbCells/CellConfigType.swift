//
//  CellConfigType.swift
//  StoreSearchSample
//
//  Created by Eido Goya on 2022/03/18.
//

import UIKit

protocol CellConfigType {
    var cellIdentifier: String { get }
    var cellHeight: CGFloat { get }
    func configure(cell: UITableViewCell,
                   with indexPath: IndexPath)
    -> UITableViewCell
}
