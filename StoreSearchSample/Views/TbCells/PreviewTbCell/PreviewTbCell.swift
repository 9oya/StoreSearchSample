//
//  PreviewTbCell.swift
//  StoreSearchSample
//
//  Created by Eido Goya on 2022/03/21.
//

import UIKit
import RxSwift
import RxCocoa
import SSPager

class PreviewTbCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    var pagerView: SSPagerView!
    
    var viewModel: PreviewTbCellVM? {
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

extension PreviewTbCell {
    
    private func configureViews() {
        selectionStyle = .none
        
        pagerView = {
            let pagerView = SSPagerView()
            pagerView.interitemSpacing = 5
            pagerView.backgroundColor = .systemYellow
            pagerView.itemSize = CGSize(width: 392*0.5,
                                        height: 696*0.5)
            pagerView.contentsInset = UIEdgeInsets(top: 0,
                                                   left: 15,
                                                   bottom: 0,
                                                   right: 15)
            pagerView.pagingMode = .scrollable
            
            let id = String.className(PreviewPagerCell.self)
            pagerView.register(UINib(nibName: id,
                                     bundle: nil),
                               forCellWithReuseIdentifier: id)
            pagerView.translatesAutoresizingMaskIntoConstraints = false
            return pagerView
        }()
        
        contentView.addSubview(pagerView)
        
        NSLayoutConstraint.activate([
            pagerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            pagerView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            pagerView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            pagerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15)
        ])
        
    }
    
    private func bind(with viewModel: PreviewTbCellVM) {
        
        // MARK: Inputs
        viewModel
            .appModel
            .compactMap { $0.screenshotUrls }
            .bind(to: pagerView.rx.pages(cellIdentifier: String(describing: PreviewPagerCell.self))) { [weak self] idx, item, cell in
                if let cell = cell as? PreviewPagerCell {
                    cell.provider = self?.viewModel?.provider
                    cell.imgUrl.accept(item)
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
