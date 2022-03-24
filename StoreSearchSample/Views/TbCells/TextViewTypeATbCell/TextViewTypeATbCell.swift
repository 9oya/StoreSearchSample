//
//  TextViewTypeATbCell.swift
//  StoreSearchSample
//
//  Created by Eido Goya on 2022/03/20.
//

import UIKit
import RxSwift
import RxCocoa

class TextViewTypeATbCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var contentsTxtView: UITextView!
    @IBOutlet weak var moreButton: UIButton!
    
    var viewModel: TextViewTypeATbCellVM? {
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
        viewModel = nil
        disposeBag = DisposeBag()
    }
    
}

extension TextViewTypeATbCell {
    
    private func configureViews() {
        selectionStyle = .none
        
        moreButton.backgroundColor = .white
        moreButton.addShadowView(offset: CGSize(width: -10, height: 0),
                                 opacity: 1,
                                 radius: 10,
                                 color: UIColor.white.cgColor,
                                 maskToBounds: false)
    }
    
    private func bind(with viewModel: TextViewTypeATbCellVM) {
        
        // MARK: Inputs
        UIView.transition(with: moreButton,
                          duration: 0.5,
                          options: .transitionCrossDissolve) { [weak self] in
            guard let `self` = self else { return }
            self.moreButton.isHidden = self.viewModel?.isMoreButtonHidden ?? false
        }
        
        viewModel
            .titleTxt
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel
            .versionTxt
            .bind(to: versionLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel
            .buttonTxt
            .bind(onNext: { [weak self] text in
                self?.moreButton.setTitle(text, for: .normal)
            })
            .disposed(by: disposeBag)
        
        viewModel
            .appModel
            .map { $0.trackName }
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel
            .appModel
            .map { $0.releaseNotes }
            .bind(to: contentsTxtView.rx.text)
            .disposed(by: disposeBag)
        
        // MARK: Outputs
        Observable.just(true)
            .asObservable()
            .bind(to: viewModel.onAppear)
            .disposed(by: disposeBag)
    }
    
}
