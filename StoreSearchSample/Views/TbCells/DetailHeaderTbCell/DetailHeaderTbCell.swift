//
//  DetailHeaderTbCell.swift
//  StoreSearchSample
//
//  Created by Eido Goya on 2022/03/20.
//

import UIKit
import RxSwift
import RxCocoa

class DetailHeaderTbCell: UITableViewCell {
    
    @IBOutlet weak var iconImgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var openButton: UIButton!
    
    var viewModel: DetailHeaderTbCellVM? {
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
        iconImgView.image = nil
        titleLabel.text = nil
        subTitleLabel.text = nil
        viewModel = nil
        disposeBag = DisposeBag()
    }
    
}

extension DetailHeaderTbCell {
    
    private func configureViews() {
        selectionStyle = .none
        
        iconImgView.clipsToBounds = true
        iconImgView.layer.cornerRadius = 20.0
        iconImgView.layer.borderWidth = 0.7
        iconImgView.layer.borderColor = UIColor.systemGray5.cgColor
        
        openButton.layer.cornerRadius = 13.0
        openButton.backgroundColor = .systemBlue
    }
    
    
    private func bind(with viewModel: DetailHeaderTbCellVM) {
        
        // MARK: Inputs
        viewModel
            .iconImg
            .observe(on: MainScheduler.instance)
            .bind(to: iconImgView.rx.image)
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
