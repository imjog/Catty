/**
 *  Copyright (C) 2010-2017 The Catrobat Team
 *  (http://developer.catrobat.org/credits)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  (http://developer.catrobat.org/license_additional_term)
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */


import UIKit

class ImageLibraryCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var imageCollectionView: UICollectionView!
    
    var imageType: NSString?
    var paintDelegate : PaintDelegate! = nil
    var arrayOfImageData: Array<Dictionary<String, AnyObject> > = []
    var sectionArray:Array<String> = []
    var numberOfItemsInSection:Array<Int> = []
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewWillAppear(animated: Bool) {
    }
    
    override func viewDidLayoutSubviews() {
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(imageCollectionView == nil)
        {
            print("CollectionView is nil")
        }
        
        var url = NSURL()
        
        if(imageType == "backgrounds") {
            url = NSURL(string: "https://share.catrob.at/pocketcode/api/media/package/Backgrounds/json")!
        }
        else if (imageType == "looks") {
            url = NSURL(string: "https://share.catrob.at/pocketcode/api/media/package/Looks/json")!
        }
        else {
            print("Fatal Error: no image type")
        }
        
        var jsonObject :  NSArray = []
        do {
            let jsonData = try NSData(contentsOfURL: url, options: NSDataReadingOptions())
            do {
                jsonObject = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .MutableContainers) as! NSArray
            } catch {
                print("Fatal Error: \(error)")
            }
        } catch {
            print("Fatal Error: \(error)")
            return;
        }
        
        if jsonObject.count != 0 {
            arrayOfImageData = jsonObject as! Array<Dictionary<String, AnyObject>>
            
            for dict in arrayOfImageData {
                if sectionArray.count == 0 {
                    sectionArray.append((dict["category"]) as! String)
                }
                else {
                    if !sectionArray.contains((dict["category"]) as! String) {
                        sectionArray.append((dict["category"]) as! String)
                    }
                }
            }
        }

        // Register cell class
        self.imageCollectionView!.registerClass(ImageViewCollectionViewCell.self, forCellWithReuseIdentifier: "ImageCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionArray.count
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var numberOfItems:Int = 0
        let category = sectionArray[section]
        for dict in arrayOfImageData {
            if dict["category"] as! String == category {
                numberOfItems += 1
            }
        }
        return numberOfItems
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = imageCollectionView.dequeueReusableCellWithReuseIdentifier("ImageCell", forIndexPath: indexPath)

        
        let imageCell : ImageViewCollectionViewCell = cell as! ImageViewCollectionViewCell
        if imageCell.contentView.subviews.count != 0 {
            imageCell.contentView.subviews[0].removeFromSuperview()
        }
    
        // Configure the cell
        let section = indexPath.section
        let item = indexPath.item
        
        var itemCounter : Int = 0
        let category = sectionArray[section]
        for dict in arrayOfImageData {
            if dict["category"] as! String == category {
                if itemCounter == item {
                    let name = dict["name"] as! String
                    let category = dict["category"] as! String
                    let downloadUrl = dict["download_url"] as! String
                    let fullImageUrl = "https://share.catrob.at" + downloadUrl
                    let fullDownloadUrl = NSURL(string: fullImageUrl)!
                    let data = NSData(contentsOfURL: fullDownloadUrl)!
                
                    let image:UIImage = UIImage(data:data)!
                    let imageView = UIImageView(frame: imageCell.frame)
                    imageView.image = image
                    imageCell.contentView.addSubview(imageView)
                    
                    imageCell.name = name
                    imageCell.category = category
                    imageCell.downloadUrl = downloadUrl
                }
                itemCounter += 1
            }
        }
        return imageCell
    }

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let section = indexPath.section
        let item = indexPath.item
        
        var name : String = ""
        var image : UIImage! = nil
        
        var itemCounter : Int = 0
        let category = sectionArray[section]
        for dict in arrayOfImageData {
            if dict["category"] as! String == category {
                if itemCounter == item {
                    name = dict["name"] as! String
                    let fullImageUrl = "https://share.catrob.at" + (dict["download_url"] as! String)
                    let data = NSData(contentsOfURL: NSURL(string: fullImageUrl)!)!
                    image = UIImage(data:data)!
                }
                itemCounter += 1
            }
        }
        
        if name != "" && image != nil {
            dispatch_async(dispatch_get_main_queue(), {
                self.paintDelegate.addMediaLibraryLoadedImage(image, withName: name)})
            
            dispatch_async(dispatch_get_main_queue(), {
                self.navigationController?.popViewControllerAnimated(true)
            })
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let size = (collectionView.frame.size.width) / CGFloat(3)
        return CGSizeMake(size, size)
    }
}
