//
//  ViewController.swift
//  SampleApp
//
//  Created by James Donald on 11/20/16.
//  Copyright © 2016 forge. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController
{
    //MARK: - API -
    static let flickrKey    = "a1a97948e97e2b659d3735f277f7bd2e"
    static let flickrSecret = "0117dab022a8ed77"
    
    //MARK: - UI -
    @IBOutlet fileprivate var imageCollectionView:UICollectionView?
    
    //MARK: - Properties - 
    var imageData = Array< Dictionary<String, AnyObject> >()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // load a cell comprised of only an image view
        let cellNib = UINib(nibName: "ImageCollectionViewCell", bundle: Bundle.main)
        self.imageCollectionView?.register(cellNib, forCellWithReuseIdentifier: "ImageCollectionViewCell")
        
        // fetch some public images from flickr
        self.fetchImages()
    }
    
    func fetchImages()
    {
        let params = ["method":"flickr.photos.search", "api_key":ViewController.flickrKey, "tags":"cars",
                      "media":"photos", "format":"json", "nojsoncallback":"1"]
        
        weak var weakself = self
        Alamofire.request("https://api.flickr.com/services/rest", method: HTTPMethod.get, parameters: params, headers: [:])
        .validate()
        .responseJSON(queue: DispatchQueue.main)
        {(response) in
            switch(response.result)
            {
            case .success(let data):
                if let photoListInfoDict = data as? NSDictionary,
                   let photoPaging = photoListInfoDict["photos"] as? NSDictionary,
                   let photoList = photoPaging["photo"] as? Array< Dictionary<String, AnyObject> >
                {
                    weakself?.imageData = photoList
                    weakself?.imageCollectionView?.reloadData()
                }
            case .failure(let error):
                assertionFailure("\(error)")
            }
        }
    }
    
    func buildImageURL(withFarmID farmID:NSNumber, serverID:String, id:String, secret:String) -> URL?
    {
        return URL(string: "https://farm\(farmID).staticflickr.com/\(serverID)/\(id)_\(secret).jpg")
    }
}

extension ViewController: UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    { return self.imageData.count }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        guard let imageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath)  as? ImageCollectionViewCell else
        { return UICollectionViewCell(frame: CGRect()) }
        
        let imageInfoDict = self.imageData[indexPath.item]
        let farmID      = (imageInfoDict["farm"] as? NSNumber) ?? 0
        let serverID    = (imageInfoDict["server"] as? String) ?? ""
        let id          = (imageInfoDict["id"] as? String) ?? ""
        let secret      = (imageInfoDict["secret"] as? String) ?? ""
        if let imageURL = self.buildImageURL(withFarmID: farmID, serverID: serverID, id: id, secret: secret)
        { imageCell.setup(withImageURL: imageURL) }
        
        return imageCell
    }
}
