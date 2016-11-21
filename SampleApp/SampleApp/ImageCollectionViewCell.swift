//
//  ImageCollectionViewCell.swift
//  SampleApp
//
//  Created by James Donald on 11/20/16.
//  Copyright © 2016 forge. All rights reserved.
//

import UIKit
import AlamofireImage

class ImageCollectionViewCell: UICollectionViewCell
{
    @IBOutlet private var imageView:UIImageView?
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        
        self.imageView?.image = nil
    }
    
    func setup(withImageURL imgURL: URL?)
    {
        //ensure we have a valid url
        guard let imageURL = imgURL else
        { return }
        
        // load the image asynchronously in the background
        self.imageView?.af_setImage(withURL: imageURL)
    }
}
