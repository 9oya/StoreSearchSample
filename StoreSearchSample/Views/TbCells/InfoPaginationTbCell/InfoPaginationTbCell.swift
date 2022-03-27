//
//  InfoPaginationTbCell.swift
//  StoreSearchSample
//
//  Created by Eido Goya on 2022/03/20.
//

import UIKit
import RxSwift
import RxCocoa
import SSPager

class InfoPaginationTbCell: UITableViewCell {
    
    var pagerView: SSPagerView!
    
    var viewModel: InfoPaginationTbCellVM? {
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
        configureViews()
        viewModel = nil
        disposeBag = DisposeBag()
    }
    
}

extension InfoPaginationTbCell {
    
    private func configureViews() {
        selectionStyle = .none
        
        pagerView = {
            let pagerView = SSPagerView()
            pagerView.interitemSpacing = 0
            pagerView.backgroundColor = .white
            pagerView.itemSize = CGSize(width: 110,
                                        height: 100)
            pagerView.contentsInset = UIEdgeInsets(top: 0,
                                                   left: 15,
                                                   bottom: 0,
                                                   right: 15)
            pagerView.pagingMode = .disable
            
            let id = String.className(InfoPagerViewCell.self)
            pagerView.register(UINib(nibName: id,
                                     bundle: nil),
                               forCellWithReuseIdentifier: id)
            pagerView.translatesAutoresizingMaskIntoConstraints = false
            return pagerView
        }()
        
        contentView.addSubview(pagerView)
        
        NSLayoutConstraint.activate([
            pagerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            pagerView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            pagerView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            pagerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
    }
    
    private func bind(with viewModel: InfoPaginationTbCellVM) {
        
        // MARK: Inputs
        viewModel
            .infoModels
            .bind(to: pagerView.rx.pages(cellIdentifier: String(describing: InfoPagerViewCell.self))) { idx, item, cell in
                if let cell = cell as? InfoPagerViewCell {
                    cell.titleLabel.text = item.title
                    
                    if let subTitle = item.subTitle {
                        cell.contentsLabel.isHidden = false
                        cell.contentsImgView.isHidden = true
                        cell.contentsLabel.text = subTitle
                    } else if let img = item.image {
                        cell.contentsLabel.isHidden = true
                        cell.contentsImgView.isHidden = false
                        cell.contentsImgView.tintColor = .systemGray
                        cell.contentsImgView.image = img
                    }
                    
                    if let desc = item.descTxt {
                        cell.descLabel.isHidden = false
                        cell.starsStackView.isHidden = true
                        cell.descLabel.text = desc
                    } else if let imgvs = cell.starsStackView.arrangedSubviews as? [UIImageView],
                              let rating = item.rating {
                        cell.descLabel.isHidden = true
                        cell.starsStackView.isHidden = false
                        self.genStars(with: rating,
                                      for: imgvs)
                    }
                    
                    if idx == 4 { cell.verticalSeperator.isHidden = true }
                }
            }
            .disposed(by: disposeBag)
        
        // MARK: Outputs
        Observable.just(true)
            .asObservable()
            .bind(to: viewModel.onAppear)
            .disposed(by: disposeBag)
    }
    
}
