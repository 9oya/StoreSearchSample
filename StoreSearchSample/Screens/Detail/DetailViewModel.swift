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
    var logoImg: UIImage?
    
    init(appModel: SearchModel,
         provider: ServiceProviderProtocol) {
        self.provider = provider
        
        onAppear
            .flatMap { _ -> Observable<SearchModel> in
                return .just(appModel)
            }
            .do(onNext: { model in
                DispatchQueue.global(qos: .userInteractive).async {
                    guard let urlStr = model.artworkUrl60,
                            let url = URL(string: urlStr) else {
                        return
                    }
                    do {
                        let data = try Data(contentsOf: url)
                        self.logoImg = UIImage(data: data)
                    } catch let error {
                        print(error.localizedDescription)
                    }
                    
                }
            })
            .flatMap(convertToCellConfigs)
            .bind(to: cellConfigs)
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
                    DetailInfoModel(title: model.userRatingCount.formatUsingAbbrevation()+"개의 평가",
                                    subTitle: String(format: "%.1f", Float(model.averageUserRating ?? 0)),
                                    rating: model.averageUserRating),
                    DetailInfoModel(title: "연령",
                                    subTitle: model.trackContentRating,
                                    descTxt: "세"),
                    DetailInfoModel(title: "차트",
                                    subTitle: "#0",
                                    descTxt: model.genres?.first ?? ""),
                    DetailInfoModel(title: "개발자",
                                    descTxt: model.artistName,
                                    image: UIImage(systemName: "person.crop.square")),
                    DetailInfoModel(title: "언어",
                                    subTitle: model.languageCodesISO2A.filter { $0 == "KO" }.first ?? model.languageCodesISO2A.first ?? "",
                                    descTxt: "\(model.languageCodesISO2A.count)개 언어")
                ])
            )
            
            if let releaseNotes = model.releaseNotes {
                let (height, isChanged) = self.calculateTxtViewHeight(170, 62+15, releaseNotes)
                configs.append(TextViewTypeATbCellVM(
                    cellHeight: height,
                    model: model,
                    titleTxt: "새로운 기능",
                    versionTxt: "버전 "+model.version,
                    buttonTxt: "더 보기",
                    isMoreButtonHidden: isChanged)
                )
            }
            
            configs.append(PreviewTbCellVM(
                provider: self.provider,
                cellHeight: 37+(696*0.5)+25, // header+body+footer
                model: model,
                titleTxt: "미리보기")
            )
            
            let (height, isChanged) = self.calculateTxtViewHeight(120, 30, model.description)
            configs.append(TextViewTypeBTbCellVM(
                cellHeight: height,
                model: model,
                buttonTxt: "더 보기",
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
