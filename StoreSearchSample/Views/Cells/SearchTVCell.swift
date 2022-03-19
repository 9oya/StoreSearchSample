//
//  SearchTVCell.swift
//  StoreSearchSample
//
//  Created by Eido Goya on 2022/03/18.
//

import UIKit
import RxSwift
import RxCocoa

class SearchTVCell: UITableViewCell {
    
    var viewModel: SearchTVCellVM? {
        didSet {
            if let vm = viewModel {
                bind(with: vm)
            }
        }
    }
    var disposeBag = DisposeBag()

    @IBOutlet weak var appIconImgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var ratingStackView: UIStackView!
    @IBOutlet weak var ratingCntLabel: UILabel!
    @IBOutlet weak var openButton: UIButton!
    @IBOutlet weak var previewStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        
        appIconImgView.clipsToBounds = true
        appIconImgView.layer.cornerRadius = 12.0
        appIconImgView.layer.borderWidth = 0.5
        appIconImgView.layer.borderColor = UIColor.systemGray5.cgColor
        
        previewStackView
            .arrangedSubviews
            .forEach { imgv in
                imgv.clipsToBounds = true
                imgv.layer.cornerRadius = 12.0
                imgv.layer.borderWidth = 0.5
                imgv.layer.borderColor = UIColor.systemGray5.cgColor
            }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        if appIconImgView != nil {
            appIconImgView.image = nil
            titleLabel.text = nil
            subTitleLabel.text = nil
            ratingCntLabel.text = nil
            viewModel = nil
            disposeBag = DisposeBag()
        }
    }
    
    func bind(with viewModel: SearchTVCellVM) {
        
        // MARK: Inputs
        viewModel
            .iconImg
            .observe(on: MainScheduler.instance)
            .bind(to: appIconImgView.rx.image)
            .disposed(by: disposeBag)
        
        viewModel
            .previewImgs
            .observe(on: MainScheduler.instance)
            .bind(onNext: { imgDict in
                if let img = imgDict[0],
                   let imgv = self.previewStackView.arrangedSubviews[1] as? UIImageView {
                    imgv.image = img
                } else if let img = imgDict[1],
                          let imgv = self.previewStackView.arrangedSubviews[2] as? UIImageView {
                    imgv.image = img
                } else if let img = imgDict[2],
                          let imgv = self.previewStackView.arrangedSubviews[3] as? UIImageView {
                    imgv.image = img
                }
            })
            .disposed(by: disposeBag)
        
        viewModel
            .appModel
            .map { $0.trackName}
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel
            .appModel
            .compactMap { $0.genres?.first }
            .bind(to: subTitleLabel.rx.text)
            .disposed(by: disposeBag)
        
        // MARK: Outputs
        Observable.just(true)
            .asObservable()
            .bind(to: viewModel.onAppear)
            .disposed(by: disposeBag)
    }
    
}

class SearchTVCellVM: CellConfigType {
    
    var disposeBag: DisposeBag = DisposeBag()
    var provider: ServiceProviderProtocol
    
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
        
        onAppear
            .bind { [weak self] _ in
                self?.bind(model)
            }
            .disposed(by: disposeBag)
    }
    
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
    
    // MARK: CellConfigType
    
    var cellIdentifier: String = String(describing: SearchTVCell.self)
    var cellHeight: CGFloat
    
    func cellConfigurator(cell: UITableViewCell, indexPath: IndexPath) -> UITableViewCell {
        if let cell = cell as? SearchTVCell {
            cell.viewModel = self
            return cell
        }
        return UITableViewCell()
    }
    
}
