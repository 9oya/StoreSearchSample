//
//  SearchViewController.swift
//  StoreSearchSample
//
//  Created by Eido Goya on 2022/03/18.
//

import UIKit

class SearchViewController: UIViewController {
    
    var viewModel: SearchViewModel? {
        didSet {
            if let viewModel = viewModel {
                setupViews(viewModel)
                bind(viewModel)
            }
        }
    }
    
}

extension SearchViewController {
    
    private func setupViews(_ viewModel: SearchViewModel) {
        
    }
    
    private func bind(_ viewModel: SearchViewModel) {
        
    }
    
}
