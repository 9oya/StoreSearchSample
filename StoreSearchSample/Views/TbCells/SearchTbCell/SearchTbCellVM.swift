//
//  SearchTbCellVM.swift
//  StoreSearchSample
//
//  Created by Eido Goya on 2022/03/20.
//

import UIKit
import RxSwift
import RxCocoa

class SearchTbCellVM: CellConfigType {
    
    var disposeBag: DisposeBag = DisposeBag()
    var provider: ServiceProviderProtocol
    var model: SearchModel?
    
    // MARK: Inputs
    var onAppear = PublishRelay<Bool>()
    
    // MARK: Outputs
    var iconImg = PublishRelay<UIImage>()
    var previewImgs = PublishRelay<[Int:UIImage]>()
    var appModel = PublishRelay<SearchModel>()
    
    init(provider: ServiceProviderProtocol,
         cellHeight: CGFloat,
         model: SearchModel) {
        self.provider = provider
        self.cellHeight = cellHeight
        self.model = model
        
        onAppear
            .bind { [weak self] _ in
                self?.bind(model)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: CellConfigType
    
    var cellIdentifier: String = String(describing: SearchTbCell.self)
    var cellHeight: CGFloat
    
    func configure(cell: UITableViewCell,
                   with indexPath: IndexPath)
    -> UITableViewCell {
        if let cell = cell as? SearchTbCell {
            cell.viewModel = self
            return cell
        }
        return UITableViewCell()
    }
    
}

extension SearchTbCellVM {
    
    private func bind(_ model: SearchModel) {
        appModel.accept(model)
        
        Observable.just(model)
            .compactMap { $0.artworkUrl100 }
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
        
        if let cntOfPic = model.screenshotUrls?.count {
            var cnt = 3
            if cntOfPic < cnt {
                cnt = cntOfPic
            }
            for idx in 0...cnt-1 {
                downloadPreviewImg(with: idx, model)
            }
        }
    }
    
    private func downloadPreviewImg(with idx: Int, _ model: SearchModel) {
        Observable.just(model)
            .compactMap { $0.screenshotUrls }
            .compactMap { $0[idx] }
            .flatMap(provider.imageLoadService.fetchCachedImage)
            .flatMap(provider.imageLoadService.downloadImage)
            .flatMap(provider.imageLoadService.cacheImage)
            .bind(onNext: { [weak self] result in
                switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                case let .success((_, img)):
                    self?.previewImgs.accept([idx : img])
                }
            })
            .disposed(by: disposeBag)
    }
    
}
