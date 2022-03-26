//
//  DetailViewController.swift
//  StoreSearchSample
//
//  Created by Eido Goya on 2022/03/18.
//

import UIKit
import RxSwift
import RxCocoa

class DetailViewController: UIViewController {
    
    @IBOutlet weak var tv: UITableView!
    
    var disposeBag: DisposeBag = DisposeBag()
    var viewModel: DetailViewModel?
    
    var cellConfigs = BehaviorRelay<[CellConfigType]>(value: [])
    
    var logoImg: UIImage?
    
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
        
        tv.rx.contentOffset
            .bind { [weak self] offset in
                guard let `self` = self else { return }
                if offset.y > 20.0 {
                    let button: UIButton = {
                        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 73, height: 25))
                        button.setTitle("열기", for: .normal)
                        button.setTitleColor(.white, for: .normal)
                        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
                        button.backgroundColor = .systemBlue
                        button.layer.cornerRadius = 15.0
                        return button
                    }()
                    let imgView: UIImageView = {
                        let imgView = UIImageView(image: self.logoImg)
                        imgView.contentMode = .scaleToFill
                        imgView.clipsToBounds = true
                        imgView.backgroundColor = .clear
                        imgView.layer.cornerRadius = 8.0
                        imgView.layer.borderColor = UIColor.systemGray5.cgColor
                        imgView.layer.borderWidth = 1.0
                        imgView.translatesAutoresizingMaskIntoConstraints = false
                        return imgView
                    }()
                    NSLayoutConstraint.activate([
                        imgView.widthAnchor.constraint(equalToConstant: 25),
                        imgView.heightAnchor.constraint(equalToConstant: 25)
                    ])
                    UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn) {
                        self.navigationItem.titleView = imgView
                        self.navigationItem.titleView?.backgroundColor = .clear
                        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
                    }
                } else {
                    UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn) {
                        self.navigationItem.titleView = nil
                        self.navigationItem.rightBarButtonItem = nil
                    }
                }
            }
            .disposed(by: disposeBag)
        
        // MARK: Inputs
        viewModel
            .model
            .do(onNext: { model in
                DispatchQueue.global(qos: .userInteractive).async {
                    guard let urlStr = model.artworkUrl60,
                          let url = URL(string: urlStr) else {
                              return
                          }
                    do {
                        let data = try Data(contentsOf: url)
                        self.logoImg = UIImage(data: data)
                    } catch let error {
                        print(error.localizedDescription)
                    }
                    
                }
            })
            .flatMap(convertToCellConfigs)
            .bind(to: cellConfigs)
            .disposed(by: disposeBag)
                
        cellConfigs
            .bind(to: tv.rx.items) { tv, idx, item -> UITableViewCell in
                let indexPath = IndexPath(row: idx, section: 0)
                let cell = tv
                    .dequeueReusableCell(withIdentifier: item.cellIdentifier,
                                         for: indexPath)
                item.bind?(cell, item, indexPath)
                return item.configure(cell: cell,
                                      with: indexPath)
            }
            .disposed(by: disposeBag)
        
        
        // MARK: Outputs
        Observable.just(true)
            .bind(to: viewModel.onAppear)
            .disposed(by: disposeBag)
    }
    
    private func convertToCellConfigs(with model: SearchModel)
    -> Observable<[CellConfigType]> {
        return Observable.create { [weak self] observer in
            guard let `self` = self,
                  let provider = self.viewModel?.provider else { return Disposables.create() }
            
            var configs: [CellConfigType] = []
            
            configs.append(DetailHeaderTbCellVM(
                provider: provider,
                cellHeight: 130,
                model: model,
                bind: { cell, cellVM, indexPath  in
                    if let cell = cell as? DetailHeaderTbCell {
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
                })
            )
            
            configs.append(InfoPaginationTbCellVM(
                provider: provider,
                cellHeight: 110,
                model: model)
            )
            
            if let releaseNotes = model.releaseNotes {
                let (height, isChanged) = self.calculateTxtViewHeight(170, 62+15, releaseNotes)
                configs.append(TextViewTypeATbCellVM(
                    cellHeight: height,
                    model: model,
                    titleTxt: "새로운 기능",
                    versionTxt: "버전 "+model.version,
                    buttonTxt: "더 보기",
                    isMoreButtonHidden: isChanged,
                    bind: { cell, cellVM, indexPath in
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
                            
                        }
                    })
                )
            }
            
            configs.append(PreviewTbCellVM(
                provider: provider,
                cellHeight: 37+(696*0.5)+25, // header+body+footer
                model: model,
                titleTxt: "미리보기")
            )
            
            let (height, isChanged) = self.calculateTxtViewHeight(120, 30, model.description)
            configs.append(TextViewTypeBTbCellVM(
                cellHeight: height,
                model: model,
                buttonTxt: "더 보기",
                isMoreButtonHidden: isChanged,
                bind: { cell, cellVM, indexPath in
                    if let cell = cell as? TextViewTypeBTbCell,
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
                    }
                })
            )
            
            observer.onNext(configs)
            return Disposables.create()
        }
    }
    
    private func calculateTxtViewHeight(_ defaultHeight: CGFloat,
                                        _ addHeight: CGFloat,
                                        _ contents: String) -> (CGFloat, Bool) {
        let tempTxtView = UITextView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width-30, height: 0))
        tempTxtView.text = contents
        let sizeThatFitsTextView = tempTxtView
            .sizeThatFits(CGSize(width: tempTxtView.frame.size.width,
                                 height: CGFloat(MAXFLOAT)))
        let calculatedHeight = sizeThatFitsTextView.height+addHeight
        var resultHeight: CGFloat = defaultHeight
        var isChanged: Bool = false
        if resultHeight > calculatedHeight {
            resultHeight = calculatedHeight
            isChanged = true
        }
        return (resultHeight, isChanged)
    }
    
}

extension DetailViewController: UITableViewDelegate {
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellConfigs.value[indexPath.row].cellHeight
    }
    
}
