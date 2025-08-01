//
//  collectionViewController.swift
//  SoundsApp
//
//  Created by Humayun Tariq on 01/08/2025.
//

import UIKit
import CoreData

class collectionViewContoller: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIViewControllerTransitioningDelegate {

    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var collectionSaved: [MyCollection] = []
    var selectedCellImageView: UIImageView?
    var selectedCellLabel: UILabel?
    
    
    
    override func viewDidLoad() {
            super.viewDidLoad()
        let backgroundImage = UIImage(named: "background01")
        let backgroundImageView = UIImageView(frame: UIScreen.main.bounds)
        backgroundImageView.image = backgroundImage
        backgroundImageView.contentMode = .scaleAspectFill
        view.addSubview(backgroundImageView)
        view.sendSubviewToBack(backgroundImageView) //send the image to the back
        
        collectionView.delegate = self
        collectionView.dataSource = self
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        //16 padding before first cell and after last cell
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        //padding between cells
        layout.minimumLineSpacing = 20
        collectionView.collectionViewLayout = layout
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        fetchSoundCollections(context: context)
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionSaved.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homeCell", for: indexPath) as! homeCellModel
        
        let collection = collectionSaved[indexPath.item]
        cell.titleLabel.text = collection.name
            if let imageName = collection.imageName {
                cell.imageView.image = UIImage(named: imageName)
            }
        
        cell.layer.cornerRadius = 20
        cell.layer.masksToBounds = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 16
        let spacing: CGFloat = 20
        let totalWidth = collectionView.bounds.width
        let availableWidth = totalWidth - (2 * padding) - spacing
        let cellWidth = availableWidth / 2
        // Return a square cell (width == height)
        return CGSize(width: cellWidth, height: cellWidth)
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! homeCellModel
               selectedCellImageView = cell.imageView
               selectedCellLabel = cell.titleLabel

               let storyboard = UIStoryboard(name: "Main", bundle: nil)
               let vc = storyboard.instantiateViewController(withIdentifier: "collectionScreen") as! collectionSoundsViewContoller
               vc.modalPresentationStyle = .fullScreen
               vc.transitioningDelegate = self
               vc.headingPassed = cell.titleLabel.text
               vc.selectedImage = cell.imageView.image
            let selectedCollection = collectionSaved[indexPath.item] // ← Your array of `MyCollection`
            vc.collectionObject = selectedCollection
               present(vc, animated: true, completion: nil)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            guard let vc = presented as? collectionSoundsViewContoller else { return nil }

            let animator = CollectionTransitionAnimator()
            animator.originImageView = selectedCellImageView
            animator.originLabel = selectedCellLabel
            animator.destinationImageView = vc.imageHeader
            animator.destinationLabel = vc.heading

            return animator
        }
    
    func fetchSoundCollections(context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<MyCollection> = MyCollection.fetchRequest()

        do {
            collectionSaved = try context.fetch(fetchRequest)
            collectionView.reloadData()
        } catch {
            print("Failed to fetch collections: \(error)")
        }
    }
    
}

