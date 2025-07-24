//
//  homeViewContoller.swift
//  SoundsApp
//
//  Created by Humayun Tariq on 22/07/2025.
//

import UIKit
import CoreData


class homeViewContoller: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate {
    
    
    //MARK: Declaring the Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var playBtnInPlayer: UIButton!
    @IBOutlet weak var playerBar: UIVisualEffectView!
    @IBOutlet weak var endTime: UILabel!
    @IBOutlet weak var startTime: UILabel!
    
    //MARK: Player Controls
    @IBOutlet weak var backwardBtn: UIButton!
    @IBOutlet weak var forwardBtn: UIButton!
    @IBOutlet weak var loopBtn: UIButton!
    @IBOutlet weak var playingSound: UILabel!
    @IBOutlet weak var playerImage: UIImageView!
    
    var collectionSaved: [MyCollection] = []
    var selectedCellImageView: UIImageView?
    var selectedCellLabel: UILabel?

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
        tableView.delegate = self
        tableView.delegate = self
        
        //player bar settings
        playerBar.layer.cornerRadius = 20
        playerBar.clipsToBounds = true
        playerBar.layer.borderWidth = 1
        playerBar.layer.borderColor = UIColor.white.withAlphaComponent(1).cgColor
        
        playerBar.backgroundColor = .clear
        playerImage.layer.cornerRadius = 5
        
        resetCoreDataStore()
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        preloadSoundCollections(context: context)
        fetchSoundCollections(context: context)
        
        view.layoutIfNeeded()

        
    }
    
    //MARK: IBA Action functions
    @IBAction func playBtn(_ sender: Any) {
    }
    
    @IBAction func progressBarAction(_ sender: Any) {
    }
    
    
    //MARK: Table View Data Source and Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 10
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "recentCell", for: indexPath) as! recentCellModel
        
        cell.soundName.text = "Rain and Thunder"
        
        //cell settings
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor // Adjust alpha for transparency
        cell.backgroundColor = .clear

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
           return 12 // spacing
       }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let spacer = UIView()
        spacer.backgroundColor = .clear // or your background color
        return spacer
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 49 // or whatever height you want
    }
    
    
    
    
    
    //MARK: Collection View Data Source and Delegate Methods
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                                sizeForItemAt indexPath: IndexPath) -> CGSize {
                return CGSize(width: 145, height: 145)

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
    
    func preloadSoundCollections(context: NSManagedObjectContext) {
        // This function will be used to preload sound collections from the database
//        let alreadyAdded = UserDefaults.standard.bool(forKey: "didPreloadCollections")
//            guard !alreadyAdded else { return }
        
        let rainCollection = MyCollection(context: context)
        rainCollection.name = "Rain & Thunder"
        rainCollection.imageName = "rain"
        
        let forestCollection = MyCollection(context: context)
        forestCollection.name = "Forest & Nature"
        forestCollection.imageName = "forest"
        
        let oceanCollection = MyCollection(context: context)
        oceanCollection.name = "Ocean & Water"
        oceanCollection.imageName = "ocean"
        
        let cityCollection = MyCollection(context: context)
        cityCollection.name = "City and Urban"
        cityCollection.imageName = "urban"
        
        let meditationCollection = MyCollection(context: context)
        meditationCollection.name = "Mindfulness"
        meditationCollection.imageName = "mediation"
        
        let sleepCollection = MyCollection(context: context)
        sleepCollection.name = "Sleep & Calm"
        sleepCollection.imageName = "sleep"
        
        let focusCollection = MyCollection(context: context)
        focusCollection.name = "Focus & Study"
        focusCollection.imageName = "study"
        
        let fireCollection = MyCollection(context: context)
        fireCollection.name = "Fire & Warmth"
        fireCollection.imageName = "fire"
        
        let whiteNoiseCollection = MyCollection(context: context)
        whiteNoiseCollection.name = "White Noise"
        whiteNoiseCollection.imageName = "whiteNoise"
        
        
        do {
            try context.save()
//            UserDefaults.standard.set(true, forKey: "didPreloadCollections")

        } catch {
            print("Error saving built-in sounds: \(error)")
        }
        
        
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

    func resetCoreDataStore() {
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        let storeCoordinator = container.persistentStoreCoordinator

        for store in storeCoordinator.persistentStores {
            do {
                try storeCoordinator.destroyPersistentStore(at: store.url!, ofType: store.type, options: nil)
            } catch {
                print("Error destroying store:", error)
            }
        }

        container.loadPersistentStores { _, error in
            if let error = error {
                print("Error reloading store:", error)
            }
        }
    }


    
}

