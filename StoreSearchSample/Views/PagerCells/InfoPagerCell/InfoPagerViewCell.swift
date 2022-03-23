//
//  InfoPagerViewCell.swift
//  StoreSearchSample
//
//  Created by Eido Goya on 2022/03/20.
//

import UIKit
import SSPager

class InfoPagerViewCell: SSPagerViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentsLabel: UILabel!
    @IBOutlet weak var contentsImgView: UIImageView!
    @IBOutlet weak var starsStackView: UIStackView!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var verticalSeperator: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
