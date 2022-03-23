//
//  TextViewTypeATbCellVM.swift
//  StoreSearchSample
//
//  Created by Eido Goya on 2022/03/20.
//

import UIKit
import RxSwift
import RxCocoa

class TextViewTypeATbCellVM: CellConfigType {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: Inputs
    var onAppear = PublishRelay<Bool>()
    
    // MARK: Outputs
    var titleTxt = PublishRelay<String>()
    var appModel = PublishRelay<SearchModel>()
    
    init(cellHeight: CGFloat,
         model: SearchModel,
         titleTxt: String) {
        self.cellHeight = cellHeight
        
        onAppear
            .bind { [weak self] _ in
                guard let `self` = self else { return }
                self.appModel.accept(model)
                self.titleTxt.accept(titleTxt)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: CellConfigType
    
    var cellIdentifier: String = String(describing: TextViewTypeATbCell.self)
    var cellHeight: CGFloat
    
    func configure(cell: UITableViewCell,
                   with indexPath: IndexPath)
    -> UITableViewCell {
        if let cell = cell as? TextViewTypeATbCell {
            cell.viewModel = self
            return cell
        }
        return UITableViewCell()
    }
}
