//
//  TextViewTypeBTbCell.swift
//  StoreSearchSample
//
//  Created by Eido Goya on 2022/03/21.
//

import UIKit
import RxSwift
import RxCocoa

class TextViewTypeBTbCell: UITableViewCell {
    
    @IBOutlet weak var contentsTxtView: UITextView!
    @IBOutlet weak var moreButton: UIButton!
    
    var viewModel: TextViewTypeBTbCellVM? {
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

extension TextViewTypeBTbCell {
    
    private func configureViews() {
        selectionStyle = .none
        
        moreButton.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        moreButton.backgroundColor = .white
        moreButton.addShadowView(offset: CGSize(width: -10, height: 0),
                                 opacity: 1,
                                 radius: 10,
                                 color: UIColor.white.cgColor,
                                 maskToBounds: false)
    }
    
    private func bind(with viewModel: TextViewTypeBTbCellVM) {
        
        // MARK: Inputs
        UIView.transition(with: moreButton,
                          duration: 0.5,
                          options: .transitionCrossDissolve) { [weak self] in
            guard let `self` = self else { return }
            self.moreButton.isHidden = self.viewModel?.isMoreButtonHidden ?? false
        }
        
        viewModel
            .appModel
            .map { $0.description }
            .bind(to: contentsTxtView.rx.text)
            .disposed(by: disposeBag)
        
        viewModel
            .buttonTxt
            .bind(onNext: { [weak self] text in
                self?.moreButton.setTitle(text, for: .normal)
            })
            .disposed(by: disposeBag)
        
        // MARK: Outputs
        Observable.just(true)
            .asObservable()
            .bind(to: viewModel.onAppear)
            .disposed(by: disposeBag)
    }
    
}
