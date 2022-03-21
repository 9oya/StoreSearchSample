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
    }
    
    private func bind(with viewModel: TextViewTypeBTbCellVM) {
        
        // MARK: Inputs
        viewModel
            .appModel
            .map { $0.description }
            .bind(to: contentsTxtView.rx.text)
            .disposed(by: disposeBag)
        
        // MARK: Outputs
        Observable.just(true)
            .asObservable()
            .bind(to: viewModel.onAppear)
            .disposed(by: disposeBag)
    }
    
}
