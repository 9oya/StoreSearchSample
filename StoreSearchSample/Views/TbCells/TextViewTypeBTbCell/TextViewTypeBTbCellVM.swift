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
    
    var isMoreButtonHidden: Bool
    
    // MARK: Inputs
    var onAppear = PublishRelay<Bool>()
    
    // MARK: Outputs
    var appModel = PublishRelay<SearchModel>()
    var buttonTxt = PublishRelay<String>()
    
    init(cellHeight: CGFloat,
         model: SearchModel,
         buttonTxt: String,
         isMoreButtonHidden: Bool,
         bind: ((UITableViewCell, CellConfigType, IndexPath) -> Void)?) {
        
        self.cellHeight = cellHeight
        self.isMoreButtonHidden = isMoreButtonHidden
        self.bind = bind
        
        onAppear
            .bind { [weak self] _ in
                self?.appModel.accept(model)
                self?.buttonTxt.accept(buttonTxt)
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
    
    var bind: ((UITableViewCell, CellConfigType, IndexPath) -> Void)?
    
}
