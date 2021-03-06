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
    
    // MARK: Inputs
    var onAppear = PublishRelay<Bool>()
    
    // MARK: Outputs
    var cellConfigs = BehaviorRelay<[CellConfigType]>(value: [])
    var logoImg = PublishRelay<UIImage>()
    
    init(appModel: SearchModel,
         provider: ServiceProviderProtocol) {
        self.provider = provider
        
        onAppear
            .flatMap { _ -> Observable<SearchModel> in
                return .just(appModel)
            }
            .flatMap(convertToCellConfigs)
            .bind(to: cellConfigs)
            .disposed(by: disposeBag)
                
        onAppear
            .flatMap { _ -> Observable<SearchModel> in
                return .just(appModel)
            }
            .compactMap { $0.artworkUrl100 }
            .flatMap(provider.imageLoadService.fetchCachedImage)
            .flatMap(provider.imageLoadService.downloadImage)
            .flatMap(provider.imageLoadService.cacheImage)
            .bind(onNext: { [weak self] result in
                switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                case let .success((_, img)):
                    self?.logoImg.accept(img)
                }
            })
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
                infoModels: [
                    DetailInfoModel(title: model.userRatingCount.formatUsingAbbrevation()+"?????? ??????",
                                    subTitle: String(format: "%.1f", Float(model.averageUserRating ?? 0)),
                                    rating: model.averageUserRating),
                    DetailInfoModel(title: "??????",
                                    subTitle: model.trackContentRating,
                                    descTxt: "???"),
                    DetailInfoModel(title: "??????",
                                    subTitle: "#0",
                                    descTxt: model.genres?.first ?? ""),
                    DetailInfoModel(title: "?????????",
                                    descTxt: model.artistName,
                                    image: UIImage(systemName: "person.crop.square")),
                    DetailInfoModel(title: "??????",
                                    subTitle: model.languageCodesISO2A.filter { $0 == "KO" }.first ?? model.languageCodesISO2A.first ?? "",
                                    descTxt: "\(model.languageCodesISO2A.count)??? ??????")
                ])
            )
            
            if let releaseNotes = model.releaseNotes {
                let (height, isChanged) = self.calculateTxtViewHeight(170, 62+15, releaseNotes)
                configs.append(TextViewTypeATbCellVM(
                    cellHeight: height,
                    model: model,
                    titleTxt: "????????? ??????",
                    versionTxt: "?????? "+model.version,
                    buttonTxt: "??? ??????",
                    isMoreButtonHidden: isChanged)
                )
            }
            
            configs.append(PreviewTbCellVM(
                provider: self.provider,
                cellHeight: 37+(696*0.5)+25, // header+body+footer
                model: model,
                titleTxt: "????????????")
            )
            
            let (height, isChanged) = self.calculateTxtViewHeight(120, 30, model.description)
            configs.append(TextViewTypeBTbCellVM(
                cellHeight: height,
                model: model,
                buttonTxt: "??? ??????",
                isMoreButtonHidden: isChanged)
            )
            
            observer.onNext(configs)
            return Disposables.create()
        }
    }
    
    private func calculateTxtViewHeight(_ defaultHeight: CGFloat,
                                        _ addHeight: CGFloat,
                                        _ contents: String) -> (CGFloat, Bool) {
        let tempTxtView = UITextView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width-30, height: 0))
        tempTxtView.text = contents
        let sizeThatFitsTextView = tempTxtView
            .sizeThatFits(CGSize(width: tempTxtView.frame.size.width,
                                 height: CGFloat(MAXFLOAT)))
        let calculatedHeight = sizeThatFitsTextView.height+addHeight
        var resultHeight: CGFloat = defaultHeight
        var isChanged: Bool = false
        if resultHeight > calculatedHeight {
            resultHeight = calculatedHeight
            isChanged = true
        }
        return (resultHeight, isChanged)
    }
    
}
