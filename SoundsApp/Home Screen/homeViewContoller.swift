//
//  homeViewContoller.swift
//  SoundsApp
//
//  Created by Humayun Tariq on 22/07/2025.
//

import UIKit

class homeViewContoller: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {

    
    
    //MARK: Declaring the Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setting the image as background
        let backgroundImage = UIImage(named: "background01")
        let backgroundImageView = UIImageView(frame: UIScreen.main.bounds)
        backgroundImageView.image = backgroundImage
        backgroundImageView.contentMode = .scaleAspectFill
        view.addSubview(backgroundImageView)
        view.sendSubviewToBack(backgroundImageView) //send the image to the back
        
        //collection view settings
        collectionView.delegate = self
        collectionView.dataSource = self
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        //16 padding before first cell and after last cell
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        //padding between cells
        layout.minimumLineSpacing = 20
        collectionView.collectionViewLayout = layout
        
        //table view settings
        
    }
    
    //MARK: IBA Action functions
    @IBAction func playBtn(_ sender: Any) {
    }
    
    //MARK: Table View Data Source and Delegate Methods
    
    
    
    
    
    
    //MARK: Collection View Data Source and Delegate Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homeCell", for: indexPath) as! homeCellModel
        cell.imageView.image = UIImage(named: "forest01")
        cell.imageView.layer.cornerRadius = 20
        cell.titleLabel.text = "Forest"
        
        cell.layer.cornerRadius = 20
        cell.layer.masksToBounds = true
        cell.backgroundColor = UIColor.gray.withAlphaComponent(0.5) // Adjust alpha for transparency
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                                sizeForItemAt indexPath: IndexPath) -> CGSize {
                return CGSize(width: 187, height: 145)

            }
    
    
    
}

