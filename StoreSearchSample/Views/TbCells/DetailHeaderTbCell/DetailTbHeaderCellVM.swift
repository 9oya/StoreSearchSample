//
//  DetailHeaderTbCellVM.swift
//  StoreSearchSample
//
//  Created by Eido Goya on 2022/03/20.
//

import UIKit
import RxSwift
import RxCocoa

class DetailHeaderTbCellVM: CellConfigType {
    
    var disposeBag: DisposeBag = DisposeBag()
    var provider: ServiceProviderProtocol
    
    // MARK: Inputs
    var onAppear = PublishRelay<Bool>()
    
    // MARK: Outputs
    var iconImg = PublishRelay<UIImage>()
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
    
    var cellIdentifier: String = String(describing: DetailHeaderTbCell.self)
    var cellHeight: CGFloat
    
    func configure(cell: UITableViewCell,
                   with indexPath: IndexPath)
    -> UITableViewCell {
        if let cell = cell as? DetailHeaderTbCell {
            cell.viewModel = self
            return cell
        }
        return UITableViewCell()
    }
    
}

extension DetailHeaderTbCellVM {
    
    private func bind(_ model: SearchModel) {
        appModel.accept(model)
        
        Observable.just(model)
            .compactMap { $0.artworkUrl512 }
            .flatMap(provider.imageLoadService.fetchCachedImage)
            .flatMap(provider.imageLoadService.downloadImage)
            .flatMap(provider.imageLoadService.cacheImage)
            .bind(onNext: { [weak self] result in
                switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                case let .success((_, img)):
                    self?.iconImg.accept(img)
                }
            })
            .disposed(by: disposeBag)
    }
    
}
