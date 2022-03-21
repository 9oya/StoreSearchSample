//
//  DetailViewModel.swift
//  StoreSearchSample
//
//  Created by Eido Goya on 2022/03/18.
//

import UIKit
import RxSwift
import RxRelay

class DetailViewModel {
    
    var provider: ServiceProviderProtocol
    var disposeBag: DisposeBag = DisposeBag()
    
    var txtvContentsHeightA: CGFloat = 220
    var txtvContentsHeightB: CGFloat = 220
    
    // MARK: Inputs
    var onAppear = PublishRelay<Bool>()
    var moreButtonA = PublishRelay<Void>()
    
    // MARK: Outputs
    var cellConfigs = BehaviorRelay<[CellConfigType]>(value: [])
    
    init(appModel: SearchModel,
         provider: ServiceProviderProtocol) {
        self.provider = provider
        
        onAppear
            .flatMap { _ -> Observable<SearchModel> in
                return .just(appModel)
            }
            .flatMap { [weak self] model -> Observable<[CellConfigType]> in
                return self?.convertToCellConfigs(with: model) ?? .never()
            }
            .bind { [weak self] configs in
                self?.cellConfigs.accept(configs)
            }
            .disposed(by: disposeBag)

        moreButtonA
            .flatMap { _ -> Observable<SearchModel> in
                return .just(appModel)
            }
            .flatMap { [weak self] model -> Observable<[CellConfigType]> in
                return self?.convertToCellConfigs(with: model, true) ?? .never()
            }
            .bind { [weak self] configs in
                self?.cellConfigs.accept(configs)
            }
            .disposed(by: disposeBag)
    }
    
}

extension DetailViewModel {
    
    private func convertToCellConfigs(with model: SearchModel,
                                      _ isMoreA: Bool = false)
    -> Observable<[CellConfigType]> {
        return Observable.create { [weak self] observer in
            guard let `self` = self else { return Disposables.create() }
            
            var configs: [CellConfigType] = []
            
            configs.append(DetailHeaderTbCellVM(
                provider: self.provider,
                cellHeight: 130,
                model: model)
            )
            
            configs.append(InfoPaginationTbCellVM(
                provider: self.provider,
                cellHeight: 110,
                model: model)
            )
            
            configs.append(TextViewTypeATbCellVM(
                cellHeight: self.txtvContentsHeightA,
                model: model)
            )
            
            observer.onNext(configs)
            return Disposables.create()
        }
    }
    
}
