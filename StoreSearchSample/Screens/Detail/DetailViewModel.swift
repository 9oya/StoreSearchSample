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
    
    var txtvContentsHeightA: (Int, CGFloat) = (2, 170)
    var txtvContentsHeightB: (Int, CGFloat) = (4, 120)
    
    // MARK: Inputs
    var onAppear = PublishRelay<Bool>()
    
    // MARK: Outputs
    var cellConfigs = BehaviorRelay<[CellConfigType]>(value: [])
    
    init(appModel: SearchModel,
         provider: ServiceProviderProtocol) {
        self.provider = provider
        
        onAppear
            .flatMap { _ -> Observable<SearchModel> in
                return .just(appModel)
            }
            .flatMap(convertToCellConfigs)
            .bind { [weak self] configs in
                self?.cellConfigs.accept(configs)
            }
            .disposed(by: disposeBag)
    }
    
}

extension DetailViewModel {
    
    private func convertToCellConfigs(with model: SearchModel)
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
                cellHeight: self.txtvContentsHeightA.1,
                model: model,
                titleTxt: "새로운 기능")
            )
            
            configs.append(PreviewTbCellVM(
                provider: self.provider,
                cellHeight: 37+(696*0.5)+15, // header+body+footer
                model: model,
                titleTxt: "미리보기")
            )
            
            configs.append(TextViewTypeBTbCellVM(
                cellHeight: self.txtvContentsHeightB.1,
                model: model)
            )
            
            observer.onNext(configs)
            return Disposables.create()
        }
    }
    
}
