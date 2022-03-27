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
    var infoModels = PublishRelay<[DetailInfoModel]>()
    
    init(provider: ServiceProviderProtocol,
         cellHeight: CGFloat,
         infoModels: [DetailInfoModel]) {
        self.provider = provider
        self.cellHeight = cellHeight
        
        onAppear
            .bind { [weak self] _ in
                guard let `self` = self else { return }
                self.infoModels.accept(infoModels)
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
