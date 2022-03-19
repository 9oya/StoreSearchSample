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
            SearchTVCell.self
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
                return item.cellConfigurator(cell: cell,
                                             indexPath: IndexPath(row: idx,
                                                                  section: 0))
            }
            .disposed(by: disposeBag)
        
        // MARK: Outputs
        sc.searchBar.rx.textDidEndEditing
            .bind { _ in
                if let term = self.sc.searchBar.text {
                    self.viewModel?.searchApps.accept(term)
                }
            }
            .disposed(by: disposeBag)
//        sc.searchBar.rx.text
//            .orEmpty
//            .throttle(.seconds(1),
//                      scheduler: MainScheduler.instance)
//            .distinctUntilChanged()
//            .subscribe(onNext: { term in
//                self.viewModel?.searchApps.accept(term)
//            })
//            .disposed(by: disposeBag)
        
    }
    
    private func bindCells(_ cell: UITableViewCell) {
        
    }
    
}

extension SearchViewController: UITableViewDelegate {
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel?.cellConfigs.value[indexPath.row].cellHeight ?? 0
    }
    
}
