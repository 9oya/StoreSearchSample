//
//  SearchViewModel.swift
//  StoreSearchSample
//
//  Created by Eido Goya on 2022/03/18.
//

import UIKit
import RxSwift
import RxRelay

class SearchViewModel {
    
    let title: String
    let placeHolder: String
    
    var provider: ServiceProviderProtocol
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: Inputs
    var searchApps = PublishRelay<String>()
    
    // MARK: Outputs
    var cellConfigs = BehaviorRelay<[CellConfigType]>(value: [])
    
    init(title: String,
         placeHolder: String,
         provider: ServiceProviderProtocol) {
        self.title = title
        self.placeHolder = placeHolder
        self.provider = provider
        
        searchApps
            .flatMap(requestAPISearch)
            .flatMap(convertToCellConfigs)
            .subscribe(onNext: { [weak self] configs in
                self?.cellConfigs.accept(configs)
            })
            .disposed(by: disposeBag)
        
        
    }
    
}

extension SearchViewModel {
    
    private func requestAPISearch(with term: String)
    -> PrimitiveSequence<SingleTrait, Result<SearchResponseModel, Error>> {
        return provider
            .searchService
            .search(term: term,
                    entity: "software",
                    country: "kr",
                    limit: "2")
    }
    
    private func convertToCellConfigs(with result: Result<SearchResponseModel, Error>)
    -> Observable<[CellConfigType]> {
        return Observable.create { observer in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let rsp):
                var configs: [CellConfigType] = []
                rsp.results?
                    .forEach { model in
                        configs.append(
                            SearchTVCellVM(
                                provider: self.provider,
                                cellHeight: 300,
                                model: model
                            )
                        )
                }
                observer.onNext(configs)
            }
            return Disposables.create()
        }
    }
    
}
