//
//  SearchViewController.swift
//  StoreSearchSample
//
//  Created by Eido Goya on 2022/03/18.
//

import UIKit

class SearchViewController: UIViewController {
    
    var sc: UISearchController!
    @IBOutlet var tv: UITableView!
    
    var viewModel: SearchViewModel? {
        didSet {
            if let viewModel = viewModel {
                setupViews(with: viewModel)
                bind(with: viewModel)
            }
        }
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
    }
    
    private func bind(with viewModel: SearchViewModel) {
        
    }
    
}
