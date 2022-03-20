//
//  SearchViewController.swift
//  StoreSearchSample
//
//  Created by Eido Goya on 2022/03/18.
//

import UIKit
import RxSwift

class SearchViewController: UIViewController {
    
    var sc: UISearchController!
    @IBOutlet var tv: UITableView!
    
    var disposeBag: DisposeBag = DisposeBag()
    
    var viewModel: SearchViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let vm = viewModel else { return }
        setupViews(with: vm)
        bind(with: vm)
    }
    
}

extension SearchViewController {
    
    private func setupViews(with viewModel: SearchViewModel) {
        guard let nc = navigationController else { return }
        nc.navigationBar.prefersLargeTitles = true
        navigationItem.title = viewModel.title
        sc = {
            let sc = UISearchController(searchResultsController: nil)
            sc.obscuresBackgroundDuringPresentation = false
            sc.searchBar.placeholder = viewModel.placeHolder
            return sc
        }()
        navigationItem.searchController = sc
        
        tv.registerCells([
            SearchTbCell.self
        ])
        tv.rx.setDelegate(self).disposed(by: self.disposeBag)
    }
    
    private func bind(with viewModel: SearchViewModel) {
        
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
        sc.searchBar.rx
            .textDidEndEditing
            .throttle(.seconds(1),
                      scheduler: MainScheduler.instance)
            .map { [weak self] _ -> String? in
                self?.sc.searchBar.text
            }
            .distinctUntilChanged()
            .do(onNext: { [weak self] _ in
                if self?.tv.visibleCells.count ?? 0 > 0 {
                    self?.tv.scrollToRow(at: IndexPath(row: 0, section: 0),
                                         at: .top,
                                         animated: false)
                }
            })
            .compactMap { $0 }
            .bind { [weak self] text in
                self?.viewModel?.searchApps.accept(text)
            }
            .disposed(by: disposeBag)
        
    }
    
    private func bindCells(_ cell: UITableViewCell) {
        if let cell = cell as? SearchTbCell {
            cell.openButton.rx
                .tap
                .do(onNext: { _ in
                    UIView.animate(withDuration: 0.2) {
                        cell.openButton.backgroundColor = .black.withAlphaComponent(0.2)
                    }
                    UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveEaseOut) {
                        cell.openButton.backgroundColor = .systemGray6
                    }
                })
                .delay(.milliseconds(200), scheduler: MainScheduler.instance)
                .bind(onNext: { [weak self] _ in
                    guard let `self` = self else { return }
                    let vm = DetailViewModel()
                    let vc = DetailViewController(nibName: "DetailViewController",
                                                  bundle: nil)
                    vc.viewModel = vm
                    self.navigationController?.pushViewController(vc,
                                                                  animated: true)
                        
                })
                .disposed(by: cell.disposeBag)
        }
    }
    
}

extension SearchViewController: UITableViewDelegate {
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel?.cellConfigs.value[indexPath.row].cellHeight ?? 0
    }
    
}
