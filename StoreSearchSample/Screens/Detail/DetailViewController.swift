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
                let indexPath = IndexPath(row: idx, section: 0)
                let cell = tv
                    .dequeueReusableCell(withIdentifier: item.cellIdentifier,
                                         for: indexPath)
                self?.bindCells(cell, item, indexPath)
                return item.configure(cell: cell,
                                      with: indexPath)
            }
            .disposed(by: disposeBag)
        
        // MARK: Outputs
        Observable.just(true)
            .bind(to: viewModel.onAppear)
            .disposed(by: disposeBag)
    }
    
    private func bindCells(_ cell: UITableViewCell,
                           _ cellVM: CellConfigType,
                           _ indexPath: IndexPath) {
        
        if let cell = cell as? TextViewTypeATbCell,
           let cellVM = cellVM as? TextViewTypeATbCellVM {
            cell.moreButton.rx
                .tap
                .bind(onNext: { [weak self] _ in
                    let sizeThatFitsTextView = cell.contentsTxtView
                        .sizeThatFits(CGSize(width: cell.contentsTxtView.frame.size.width,
                                             height: CGFloat(MAXFLOAT)))
                    cellVM.isMoreButtonHidden = true
                    cellVM.cellHeight = sizeThatFitsTextView.height+62+15
                    self?.tv.reloadRows(at: [indexPath],
                                        with: .automatic)
                })
                .disposed(by: cell.disposeBag)
            
        } else if let cell = cell as? TextViewTypeBTbCell,
                  let cellVM = cellVM as? TextViewTypeBTbCellVM {
            cell.moreButton.rx
                .tap
                .bind(onNext: { [weak self] _ in
                    let sizeThatFitsTextView = cell.contentsTxtView
                        .sizeThatFits(CGSize(width: cell.contentsTxtView.frame.size.width,
                                             height: CGFloat(MAXFLOAT)))
                    cellVM.isMoreButtonHidden = true
                    cellVM.cellHeight = sizeThatFitsTextView.height+30
                    self?.tv.reloadRows(at: [indexPath],
                                        with: .automatic)
                })
                .disposed(by: cell.disposeBag)
        } else if let cell = cell as? DetailHeaderTbCell {
            cell.openButton.rx
                .tap
                .bind { _ in
                    UIView.animate(withDuration: 0.2) {
                        cell.openButton.backgroundColor = .black
                    }
                    UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveEaseOut) {
                        cell.openButton.backgroundColor = .systemBlue
                    }
                }
                .disposed(by: cell.disposeBag)
        }
        
    }
    
}

extension DetailViewController: UITableViewDelegate {
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let viewModel = viewModel else { return 0 }
        return viewModel.cellConfigs.value[indexPath.row].cellHeight
    }
    
}
