//
//  TextViewTypeBTbCellVM.swift
//  StoreSearchSample
//
//  Created by Eido Goya on 2022/03/21.
//

import UIKit
import RxSwift
import RxCocoa

class TextViewTypeBTbCellVM: CellConfigType {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: Inputs
    var onAppear = PublishRelay<Bool>()
    
    // MARK: Outputs
    var appModel = PublishRelay<SearchModel>()
    
    init(cellHeight: CGFloat,
         model: SearchModel) {
        self.cellHeight = cellHeight
        
        onAppear
            .bind { [weak self] _ in
                self?.bind(model)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: CellConfigType
    
    var cellIdentifier: String = String(describing: TextViewTypeBTbCell.self)
    var cellHeight: CGFloat
    
    func configure(cell: UITableViewCell,
                   with indexPath: IndexPath)
    -> UITableViewCell {
        if let cell = cell as? TextViewTypeBTbCell {
            cell.viewModel = self
            return cell
        }
        return UITableViewCell()
    }
}

extension TextViewTypeBTbCellVM {
    
    private func bind(_ model: SearchModel) {
        appModel.accept(model)
        
        
    }
    
}
