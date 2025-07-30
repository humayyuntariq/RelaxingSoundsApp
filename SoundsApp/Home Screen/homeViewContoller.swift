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
    
    //MARK: Player Controls
    @IBOutlet weak var playBtnInPlayer: UIButton!
    @IBOutlet weak var playerBar: UIVisualEffectView!
    @IBOutlet weak var endTime: UILabel!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var backwardBtn: UIButton!
    @IBOutlet weak var forwardBtn: UIButton!
    @IBOutlet weak var loopBtn: UIButton!
    @IBOutlet weak var playingSound: UILabel!
    @IBOutlet weak var progressBar: UISlider!
    @IBOutlet weak var playerImage: UIImageView!
    
    var collectionSaved: [MyCollection] = []
    var selectedCellImageView: UIImageView?
    var selectedCellLabel: UILabel?
    private var recentSounds: [MySound] = []

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
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        preloadSoundCollections(context: context)
        fetchSoundCollections(context: context)
        
        view.layoutIfNeeded()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchRecentSounds()
        NotificationCenter.default.addObserver(self, selector: #selector(updateMiniPlayer), name: .PlaybackStateDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateMiniPlayerProgress), name: .PlaybackProgressDidChange, object: nil)

        updateMiniPlayer() // Call this to restore state
    }



    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .PlaybackStateDidChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: .PlaybackProgressDidChange, object: nil)
    }

    
    
    //MARK: IBA Action functions
    @IBAction func progressBarAction(_ sender: Any) {
    }
    
    @IBAction func playBtn(_ sender: Any) {
        PlaybackState.shared.togglePlayPause()
    }
    
    //MARK: Table View Data Source and Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return recentSounds.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "recentCell", for: indexPath) as! recentCellModel
                
                let sound = recentSounds[indexPath.section]
                cell.soundName.text = sound.name
                
                // Sync with PlaybackState
                let state = PlaybackState.shared
                let isCurrentSound = (state.currentSound == sound)
                let isPlaying = state.isPlaying && isCurrentSound
                
                cell.playButton.setImage(UIImage(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill"), for: .normal)
                cell.playButton.tag = indexPath.section
                cell.playButton.addTarget(self, action: #selector(handlePlayPause(_:)), for: .touchUpInside)
        
        cell.selectionStyle = .none

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
    
    // MARK: Saving Data into CoreData
    func preloadSoundCollections(context: NSManagedObjectContext) {
        // This function will be used to preload sound collections from the database
        let alreadyAdded = UserDefaults.standard.bool(forKey: "didPreloadCollections")
            guard !alreadyAdded else { return }
        
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
        
        let water01 = MySound(context: context)
        water01.name = "Flowing Water"
        water01.fileName = "flowingWater"
        water01.collectionTo = oceanCollection
        
        let water02 = MySound(context: context)
        water02.name = "River"
        water02.fileName = "River"
        water02.collectionTo = oceanCollection
        
        let water03 = MySound(context: context)
        water03.name = "Water Stream 01"
        water03.fileName = "waterStream01"
        water03.collectionTo = oceanCollection
        
        let water04 = MySound(context: context)
        water04.name = "Water Stream 02"
        water04.fileName = "waterStream02"
        water04.collectionTo = oceanCollection
        
        
        do {
            try context.save()
       UserDefaults.standard.set(true, forKey: "didPreloadCollections")

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
    
    @objc func updateMiniPlayer() {
        let state = PlaybackState.shared

        if let sound = state.currentSound {
            playingSound.text = sound.name
        } else {
            playingSound.text = "No Sound"
        }

        playerImage.image = state.currentImage
        playBtnInPlayer.setImage(UIImage(systemName: state.isPlaying ? "pause.circle.fill" : "play.circle.fill"), for: .normal)

        if let player = state.audioPlayer {
            endTime.text = formatTime(player.duration)
            startTime.text = formatTime(player.currentTime)
            progressBar.value = Float(player.currentTime / player.duration)
        } else {
            progressBar.value = 0
            startTime.text = "0:00"
            endTime.text = "0:00"
        }
        
        tableView.visibleCells.forEach { cell in
                   if let recentCell = cell as? recentCellModel,
                      let indexPath = tableView.indexPath(for: cell) {
                       let sound = recentSounds[indexPath.section]
                       let isCurrentSound = (PlaybackState.shared.currentSound == sound)
                       let isPlaying = PlaybackState.shared.isPlaying && isCurrentSound
                       
                       recentCell.playButton.setImage(
                           UIImage(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill"),
                           for: .normal
                       )
                   }
               }
    }


    @objc func updateMiniPlayerProgress() {
        guard let player = PlaybackState.shared.audioPlayer else { return }
        startTime.text = formatTime(player.currentTime)
        progressBar.value = Float(player.currentTime / player.duration)
    }

    
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    func fetchRecentSounds() {
           let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
           let fetchRequest: NSFetchRequest<MySound> = MySound.fetchRequest()
           
           // Only fetch sounds that have been played
           fetchRequest.predicate = NSPredicate(format: "lastPlayed != nil")
           fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastPlayed", ascending: false)]
           fetchRequest.fetchLimit = 10
           
           do {
               recentSounds = try context.fetch(fetchRequest)
               tableView.reloadData()
           } catch {
               print("Failed to fetch recent sounds: \(error)")
           }
       }
    
    @objc func handlePlayPause(_ sender: UIButton) {
            let sound = recentSounds[sender.tag]
            let state = PlaybackState.shared
            
            if state.currentSound == sound {
                state.togglePlayPause()
            } else {
                // Get the collection image for this sound
                let collectionImage = UIImage(named: sound.collectionTo?.imageName ?? "")
                state.play(sound: sound, image: collectionImage)
            }
        }
    


}



