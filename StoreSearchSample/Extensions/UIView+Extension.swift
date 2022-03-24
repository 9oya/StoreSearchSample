//
//  UIView+Extension.swift
//  StoreSearchSample
//
//  Created by Eido Goya on 2022/03/24.
//

import UIKit

extension UIView {
    
    func addShadowView(offset:CGSize=CGSize(width: 0, height: 3), opacity:Float=0.3, radius:CGFloat=3, color:CGColor=UIColor.darkGray.cgColor, maskToBounds:Bool=false) {
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
        self.layer.shadowColor = color
        self.layer.masksToBounds = maskToBounds
    }
    
    func genStars(with rating: Float, for stars: [UIImageView]) {
        stars.forEach { iv in
            iv.image = UIImage(named: "starfill0")
        }
        if rating > 4 {
            stars[0].image = UIImage(named: "starfill6")
            stars[1].image = UIImage(named: "starfill6")
            stars[2].image = UIImage(named: "starfill6")
            stars[3].image = UIImage(named: "starfill6")
            stars[4].image = self.starImage(with: rating-4)
        } else if rating > 3 {
            stars[0].image = UIImage(named: "starfill6")
            stars[1].image = UIImage(named: "starfill6")
            stars[2].image = UIImage(named: "starfill6")
            stars[3].image = self.starImage(with: rating-3)
        } else if rating > 2 {
            stars[0].image = UIImage(named: "starfill6")
            stars[1].image = UIImage(named: "starfill6")
            stars[2].image = self.starImage(with: rating-2)
        } else if rating > 1 {
            stars[0].image = UIImage(named: "starfill6")
            stars[1].image = self.starImage(with: rating-1)
        } else if rating > 0 {
            stars[0].image = self.starImage(with: rating)
        }
    }
    
    private func starImage(with rate: Float)
    -> UIImage {
        var image: UIImage = UIImage(named: "starfill0")!
        if rate > 0.81 {
            image = UIImage(named: "starfill6")!
        } else if rate > 0.65 {
            image = UIImage(named: "starfill5")!
        } else if rate > 0.48 {
            image = UIImage(named: "starfill4")!
        } else if rate > 0.32 {
            image = UIImage(named: "starfill3")!
        } else if rate > 0.16 {
            image = UIImage(named: "starfill2")!
        } else if rate > 0 {
            image = UIImage(named: "starfill1")!
        }
        return image
    }
    
}
