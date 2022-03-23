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
    }
    
    private func bind(with viewModel: TextViewTypeATbCellVM) {
        
        // MARK: Inputs
        viewModel
            .titleTxt
            .bind(to: titleLabel.rx.text)
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
