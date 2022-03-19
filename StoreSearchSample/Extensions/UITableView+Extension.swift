//
//  UITableView+Extension.swift
//  StoreSearchSample
//
//  Created by Eido Goya on 2022/03/19.
//

import UIKit

extension UITableView {
    func registerCells(_ cellTypes: [UITableViewCell.Type]) {
        cellTypes.forEach { cellType in
            let id = String.className(cellType)
            self.register(UINib(nibName: id,
                                bundle: nil),
                          forCellReuseIdentifier: id)
        }
    }
}
