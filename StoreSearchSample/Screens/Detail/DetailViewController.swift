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
            TextViewTypeATbCell.self,
            PreviewTbCell.self,
            TextViewTypeBTbCell.self
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
                self?.bindCells(cell, idx, viewModel)
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
    
    private func bindCells(_ cell: UITableViewCell,
                           _ idx: Int,
                           _ viewModel: DetailViewModel) {
        
        if let cell = cell as? TextViewTypeATbCell {
            cell.moreButton.rx
                .tap
                .bind(onNext: { [weak self] _ in
                    let sizeThatFitsTextView = cell.contentsTxtView
                        .sizeThatFits(CGSize(width: cell.contentsTxtView.frame.size.width,
                                             height: CGFloat(MAXFLOAT)))
                    viewModel.txtvContentsHeightA = (viewModel.txtvContentsHeightA.0,
                                                     sizeThatFitsTextView.height+62+15)
                    self?.tv.reloadRows(at: [IndexPath(row: idx, section: 0)],
                                        with: .automatic)
                })
                .disposed(by: cell.disposeBag)
        } else if let cell = cell as? TextViewTypeBTbCell {
            cell.moreButton.rx
                .tap
                .bind(onNext: { [weak self] _ in
                    let sizeThatFitsTextView = cell.contentsTxtView
                        .sizeThatFits(CGSize(width: cell.contentsTxtView.frame.size.width,
                                             height: CGFloat(MAXFLOAT)))
                    viewModel.txtvContentsHeightB = (viewModel.txtvContentsHeightB.0,
                                                     sizeThatFitsTextView.height+30)
                    self?.tv.reloadRows(at: [IndexPath(row: idx, section: 0)],
                                        with: .automatic)
                })
                .disposed(by: cell.disposeBag)
        }
        
    }
    
}

extension DetailViewController: UITableViewDelegate {
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let vm = viewModel else { return 0 }
        if indexPath.row == vm.txtvContentsHeightA.0 {
            return vm.txtvContentsHeightA.1
        } else if indexPath.row == vm.txtvContentsHeightB.0 {
            return vm.txtvContentsHeightB.1
        }
        return vm.cellConfigs.value[indexPath.row].cellHeight
    }
    
}
