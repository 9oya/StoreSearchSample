//
//  InfoPaginationTbCellVM.swift
//  StoreSearchSample
//
//  Created by Eido Goya on 2022/03/20.
//

import UIKit
import RxSwift
import RxCocoa

class InfoPaginationTbCellVM: CellConfigType {
    
    var disposeBag: DisposeBag = DisposeBag()
    var provider: ServiceProviderProtocol
    
    // MARK: Inputs
    var onAppear = PublishRelay<Bool>()
    
    // MARK: Outputs
    var appModel = PublishRelay<SearchModel>()
    
    init(provider: ServiceProviderProtocol,
         cellHeight: CGFloat,
         model: SearchModel) {
        self.provider = provider
        self.cellHeight = cellHeight
        
        onAppear
            .bind { [weak self] _ in
                self?.bind(model)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: CellConfigType
    
    var cellIdentifier: String = String(describing: InfoPaginationTbCell.self)
    var cellHeight: CGFloat
    
    func configure(cell: UITableViewCell,
                   with indexPath: IndexPath)
    -> UITableViewCell {
        if let cell = cell as? InfoPaginationTbCell {
            cell.viewModel = self
            return cell
        }
        return UITableViewCell()
    }
    
}

extension InfoPaginationTbCellVM {
    
    private func bind(_ model: SearchModel) {
        appModel.accept(model)
        
    }
    
}
