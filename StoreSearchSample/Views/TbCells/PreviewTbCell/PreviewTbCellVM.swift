//
//  PreviewTbCellVM.swift
//  StoreSearchSample
//
//  Created by Eido Goya on 2022/03/21.
//

import UIKit
import RxSwift
import RxCocoa

class PreviewTbCellVM: CellConfigType {
    
    var disposeBag: DisposeBag = DisposeBag()
    var provider: ServiceProviderProtocol
    
    // MARK: Inputs
    var onAppear = PublishRelay<Bool>()
    
    // MARK: Outputs
    var appModel = PublishRelay<SearchModel>()
    var titleTxt = PublishRelay<String>()
    
    init(provider: ServiceProviderProtocol,
         cellHeight: CGFloat,
         model: SearchModel,
         titleTxt: String) {
        self.provider = provider
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
    
    var cellIdentifier: String = String(describing: PreviewTbCell.self)
    var cellHeight: CGFloat
    
    func configure(cell: UITableViewCell,
                   with indexPath: IndexPath)
    -> UITableViewCell {
        if let cell = cell as? PreviewTbCell {
            cell.viewModel = self
            return cell
        }
        return UITableViewCell()
    }
    
    var bind: ((UITableViewCell, CellConfigType, IndexPath) -> Void)?
    
}
