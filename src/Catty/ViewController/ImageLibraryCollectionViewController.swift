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
    
    
    @IBOutlet weak var imageType: NSString?
    var arrayOfImageData: Array<Dictionary<String, AnyObject> > = []
    var sectionArray:Array<String> = []
    
    
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
        
        if(collectionView == nil)
        {
            fatalError("collectionView is nil")
        }
        

        /*let indexPath = NSIndexPath(forItem: 0, inSection: 0)
        
        
        
        let cell = self.collectionView?.dequeueReusableCellWithReuseIdentifier("ImageCell", forIndexPath: indexPath)*/
        
        var url = NSURL()
        
        if(imageType == "backgrounds") {
            url = NSURL(string: "https://web-test.catrob.at/pocketcode/api/media/package/Backgrounds/json")!
        }
        else if (imageType == "sounds") {
            url = NSURL(string: "https://web-test.catrob.at/pocketcode/api/media/package/Sounds/json")!
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
                print("Fatal Error")
            }
        } catch {
            print("Fatal Error")
            return;
        }
        
    
        if jsonObject.count != 0 {
            /*if let imageCell = cell as? ImageViewCollectionViewCell {
                imageCell.imageView.image = UIImage(data: data!)
            }
            if let array = category as? [AnyObject] {
                numberOfSections = NSSet(array: array).count
            }*/
            
            //loop for the other objects
            
            //change the following lines to fit with ne next line
            //arrayOfImageData = jsonObject as! Array<Dictionary<String, AnyObject>>
            
            //for testing... so only one object is here
            arrayOfImageData = jsonObject[0] as! Array<Dictionary<String, AnyObject>>
            
            
            /*let dict = jsonObject[0] as! Dictionary<String, AnyObject>
            let names = dict["name"] as! String
            let category = dict["category"] as! String
            let downloadUrl = dict["download_url"] as! String
            
            let fullImageUrl = ("https://web-test.catrob.at" + (downloadUrl as? String)!) as! String
            let fullDownloadUrl = NSURL(string: fullImageUrl)!
            let data = NSData(contentsOfURL: fullDownloadUrl) for downloading*/
            }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.registerClass(ImageViewCollectionViewCell.self, forCellWithReuseIdentifier: "ImageCell")

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    /*override*/ func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        
        for dict in arrayOfImageData {
            if sectionArray.count != 0 || !sectionArray.contains((dict["category"]) as! String) {
            sectionArray.append((dict["category"]) as! String)
            }
        }
        return sectionArray.count
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        var numberOfItems:Int = 0
        let category = sectionArray[section]
        for dict in arrayOfImageData {
            if dict["category"] as! String == category {
                numberOfItems += 1
            }
        }
        return numberOfItems
    }

    /*override func collectionView(collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
    
        return cell
    }*/

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
