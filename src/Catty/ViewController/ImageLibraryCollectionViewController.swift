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

class ImageLibraryCollectionViewController: UICollectionViewController {
    
    @IBOutlet var imageCollectionView: UICollectionView!
    
    var imageType: NSString?
    var paintDelegate: PaintDelegate! = nil
    var arrayOfImageData: Array<Dictionary<String, AnyObject> > = []
    var sectionArray:Array<String> = []
    var imageArray = [[UIImage]]()
    var cellWidth:CGFloat = 0.0
    
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
            url = NSURL(string: kTestImageBaseUrl + kBackgroundExtension)!
        }
            
        else if (imageType == "looks") {
            url = NSURL(string: kTestImageBaseUrl + kLooksExtension)!
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
                print("Fatal Error: JsonObject cannot be created")
            }
        } catch {
            print("Fatal Error: Json Data not fetchable (check if website is reachable)")
            return;
        }
        
        if jsonObject.count != 0 {
            arrayOfImageData = jsonObject as! Array<Dictionary<String, AnyObject>>
            
            for dict in arrayOfImageData {
                if !sectionArray.contains((dict["category"]) as! String) {
                    sectionArray.append((dict["category"]) as! String)
                }
            }
        }
        imageArray = Array(count: sectionArray.count, repeatedValue: [UIImage]())
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
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
        let cell = imageCollectionView.dequeueReusableCellWithReuseIdentifier("imageCell", forIndexPath: indexPath)

        if let imageCell = cell as? ImageViewCollectionViewCell {
            let section = indexPath.section
            let item = indexPath.item
            let category = sectionArray[section]
            var itemCounter: Int = 0
            
            for dict in arrayOfImageData {
                if dict["category"] as! String == category {
                    if itemCounter == indexPath.item {
                        let downloadUrl = dict["download_url"] as! String
                        let fullImageUrl = kTestImageBaseUrl + downloadUrl
                        
                        if(self.imageArray[section].count > item){
                            imageCell.imageView.image = self.imageArray[section][item]
                        }
                        else {
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                                if let url = NSURL(string: fullImageUrl) {
                                    if let data = NSData(contentsOfURL: url) {

                                        dispatch_async(dispatch_get_main_queue(), {
                                            let image: UIImage = UIImage(data: data)!
                                            self.imageArray[section].append(image)
                                            imageCell.imageView.image = image
                                        })
                                    }
                                }
                            })
                        }
                    }
                    itemCounter += 1
                }
            }
        }
        return cell
    }

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        var name : String = ""
        var image : UIImage! = nil
        
        let category = sectionArray[indexPath.section]
        for dict in arrayOfImageData {
            if dict["category"] as! String == category {
                let fullImageUrl = kTestImageBaseUrl + (dict["download_url"] as! String)
                let data = NSData(contentsOfURL: NSURL(string: fullImageUrl)!)!
                
                let img = UIImage(data: data)!
                let imgPng: NSData = UIImagePNGRepresentation(img)!
                
                let arrayImageData: NSData = UIImagePNGRepresentation(imageArray[indexPath.section][indexPath.item])!
                if imgPng.isEqualToData(arrayImageData) {
                    name = dict["name"] as! String
                    image = UIImage(data:data)!
                    break
                }
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
        // The with of a cell is the frame size minus the space between the cells divided by
        // the number of cells which should be in one row.
        cellWidth = (collectionView.frame.size.width - (4 * 30)) / CGFloat(3)
        return CGSizeMake(cellWidth, cellWidth)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
         return CGSizeMake(collectionView.frame.width, 70)
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader {
            if let sectionHeader = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "sectionHeader", forIndexPath: indexPath) as? SectionHeaderCollectionReusableView {
                
                //Section Title
                sectionHeader.sectionHeaderLabel.text = sectionArray[indexPath.section].uppercaseString
                sectionHeader.sectionHeaderLabel.textColor = UIColor.navBarColor()
                sectionHeader.sectionHeaderLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 35.0)
                
                //Separation Line
                sectionHeader.seperationLine.backgroundColor = UIColor.navBarColor()
                return sectionHeader
            }
        }
        else {
            print("No Section Header found")
        }
        return UICollectionReusableView()
    }
}
