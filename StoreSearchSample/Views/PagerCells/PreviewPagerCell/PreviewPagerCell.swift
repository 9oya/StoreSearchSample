//
//  PreviewPagerCell.swift
//  StoreSearchSample
//
//  Created by Eido Goya on 2022/03/21.
//

import UIKit
import SSPager
import RxSwift
import RxCocoa

class PreviewPagerCell: SSPagerViewCell {

    @IBOutlet weak var imgView: UIImageView!
    
    var imgUrl = PublishRelay<String>()
    
    var disposeBag: DisposeBag = DisposeBag()
    var provider: ServiceProviderProtocol? {
        didSet {
            bind(provider!)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgView.layer.cornerRadius = 15.0
        
        imgView.layer.borderWidth = 1.0
        imgView.layer.borderColor = UIColor.systemGray5.cgColor
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imgView.image = nil
        disposeBag = DisposeBag()
    }
    
    private func bind(_ provider: ServiceProviderProtocol) {
        imgUrl
            .flatMap(provider.imageLoadService.fetchCachedImage)
            .flatMap(provider.imageLoadService.downloadImage)
            .flatMap(provider.imageLoadService.cacheImage)
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] result in
                switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                case let .success((_, img)):
                    self?.imgView.image = img
                }
            })
            .disposed(by: disposeBag)
    }
}
