//
//  DetailViewController.swift
//  StoreSearchSample
//
//  Created by Eido Goya on 2022/03/18.
//

import UIKit
import RxSwift

class DetailViewController: UIViewController {
    
    @IBOutlet weak var tv: UITableView!
    
    var disposeBag: DisposeBag = DisposeBag()
    var viewModel: DetailViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let vm = viewModel else { return }
        setupViews(with: vm)
        bind(with: vm)
    }
    
}

extension DetailViewController {
    
    private func setupViews(with viewModel: DetailViewModel) {
        guard let nc = navigationController else { return }
        nc.navigationBar.prefersLargeTitles = false
        
        tv.registerCells([
            DetailHeaderTbCell.self,
            InfoPaginationTbCell.self,
            TextViewTypeATbCell.self
        ])
        tv.rx.setDelegate(self).disposed(by: self.disposeBag)
    }
    
    private func bind(with viewModel: DetailViewModel) {
        
        rx.viewDidDisappear
            .bind { [weak navigationController] _ in
                guard let nc = navigationController else { return }
                nc.navigationBar.prefersLargeTitles = true
            }
            .disposed(by: disposeBag)
        
        // MARK: Inputs
        viewModel
            .cellConfigs
            .bind(to: tv.rx.items) { [weak self] tv, idx, item -> UITableViewCell in
                let cell = tv
                    .dequeueReusableCell(withIdentifier: item.cellIdentifier,
                                         for: IndexPath(row: idx,
                                                        section: 0))
                self?.bindCells(cell)
                return item.configure(cell: cell,
                                      with: IndexPath(row: idx,
                                                      section: 0))
            }
            .disposed(by: disposeBag)
        
        // MARK: Outputs
        Observable.just(true)
            .bind(to: viewModel.onAppear)
            .disposed(by: disposeBag)
    }
    
    private func bindCells(_ cell: UITableViewCell) {
        
        guard let viewModel = viewModel else { return }
        
        if let cell = cell as? TextViewTypeATbCell {
            cell.moreButton.rx
                .tap
                .do(onNext: { _ in
                    let sizeThatFitsTextView = cell.contentsTxtView
                        .sizeThatFits(CGSize(width: cell.contentsTxtView.frame.size.width, height: CGFloat(MAXFLOAT)))
                    viewModel.txtvContentsHeightA = sizeThatFitsTextView.height
                })
                .bind(to: viewModel.moreButtonA)
                .disposed(by: cell.disposeBag)
        }
        
    }
    
}

extension DetailViewController: UITableViewDelegate {
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel?.cellConfigs.value[indexPath.row].cellHeight ?? 0
    }
    
}
