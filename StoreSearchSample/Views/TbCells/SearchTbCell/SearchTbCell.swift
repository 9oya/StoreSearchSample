//
//  SearchTbCell.swift
//  StoreSearchSample
//
//  Created by Eido Goya on 2022/03/18.
//

import UIKit
import RxSwift
import RxCocoa

class SearchTbCell: UITableViewCell {
    
    @IBOutlet weak var appIconImgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var ratingStackView: UIStackView!
    @IBOutlet weak var ratingCntLabel: UILabel!
    @IBOutlet weak var openButton: UIButton!
    @IBOutlet weak var previewStackView: UIStackView!
    
    
    var viewModel: SearchTbCellVM? {
        didSet {
            if let vm = viewModel {
                bind(with: vm)
            }
        }
    }
    var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureViews()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if appIconImgView != nil {
            appIconImgView.image = nil
            titleLabel.text = nil
            subTitleLabel.text = nil
            ratingCntLabel.text = nil
            viewModel = nil
            disposeBag = DisposeBag()
        }
    }
    
}

extension SearchTbCell {
    
    private func configureViews() {
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
        
        openButton.layer.cornerRadius = 13.0
        openButton.backgroundColor = .systemGray6
    }
    
    private func bind(with viewModel: SearchTbCellVM) {
        
        // MARK: Inputs
        viewModel
            .iconImg
            .observe(on: MainScheduler.instance)
            .bind(to: appIconImgView.rx.image)
            .disposed(by: disposeBag)
        
        viewModel
            .previewImgs
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] imgDict in
                guard let `self` = self else { return }
                if let img = imgDict[0],
                   let iv = self.previewStackView.arrangedSubviews[1] as? UIImageView {
                    iv.image = img
                } else if let img = imgDict[1],
                          let iv = self.previewStackView.arrangedSubviews[2] as? UIImageView {
                    iv.image = img
                } else if let img = imgDict[2],
                          let iv = self.previewStackView.arrangedSubviews[3] as? UIImageView {
                    iv.image = img
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
        
        viewModel
            .appModel
            .compactMap { $0.userRatingCount.formatUsingAbbrevation() }
            .bind(to: ratingCntLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel
            .appModel
            .compactMap { $0.averageUserRating }
            .bind { [weak self] rating in
                guard let `self` = self,
                      let imgvs = self.ratingStackView
                        .arrangedSubviews as? [UIImageView] else {
                            return
                        }
                self.genStars(with: rating,
                              for: imgvs)
                
            }
            .disposed(by: disposeBag)
        
        // MARK: Outputs
        Observable.just(true)
            .asObservable()
            .bind(to: viewModel.onAppear)
            .disposed(by: disposeBag)
    }
    
}
