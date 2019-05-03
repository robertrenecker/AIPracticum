//
//  SavedImagesViewController.swift
//  ImageClassifier
//
//  Created by Sam Henry on 5/3/19.
//  Copyright © 2019 Practice. All rights reserved.
//

import UIKit
import Firebase

class SavedImagesViewController: UIViewController, UICollectionViewDataSource {

    var images = [imagePost]()

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var identifierHolder = ""
        var confidenceHolder = 0

        let DBRef = Database.database().reference().child("Images")
        DBRef.observe(.childAdded, with: {
            snapshot in

            let snapObject = snapshot.value as! NSDictionary

            for item in snapObject {
//                print("ITEM", item)

                let key = item.key as! String

                if key == "indentifier" {
                    let indetifier = item.value as! String
                    identifierHolder = indetifier
                }

                if key == "confidence" {
                    let confidence = item.value as! Int
                    confidenceHolder = confidence
                }

                if key == "downloadURL" {
//                    print(item.value)
                    let downloadLink = item.value as! String
                    let imageStorageRef = Storage.storage().reference(forURL: downloadLink)
                    imageStorageRef.downloadURL(completion: {
                        (url, error) in

                        if error != nil {
                            print("error with download", error!)
                        }else{
                            do {
                                let data = try Data(contentsOf: url!)
                                let image = UIImage(data: data as Data)

                                print("image", image, "confidence", confidenceHolder, "identifier", identifierHolder)
                                
                                self.images.append(imagePost(image: image!, confidence: confidenceHolder, identifier: identifierHolder))
                                
                                DispatchQueue.main.async {
                                    
                                    self.collectionView.reloadData()
                                }
                                
                            }
                            catch {
                                print("Error with header photo")
                            }
                        }
                    })
                }
            }
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("count", images.count)
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "uploadCell", for: indexPath) as! UploadedCollectionViewCell
        
        let confidenceString = String(images[indexPath.row].confidence)
        
//        print("ID", images[indexPath.row].identifier)
        
        cell.cellImage.image = images[indexPath.row].image
        cell.cellConfLabel.text = "\(confidenceString) %"
        cell.cellIdentLabel.text = images[indexPath.row].identifier
        
        return cell
    }
}

class imagePost {
    let image: UIImage
    let confidence: Int
    let identifier: String
    
    init(image: UIImage, confidence: Int, identifier: String) {
        self.image = image
        self.confidence = confidence
        self.identifier = identifier
    }
}

