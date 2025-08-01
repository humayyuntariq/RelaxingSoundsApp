//
//  collectionSoundsViewController.swift
//  SoundsApp
//
//  Created by Humayun Tariq on 24/07/2025.
//

import UIKit
import CoreData
import AVFoundation

class collectionSoundsViewContoller: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: Declaring the Outlets
    @IBOutlet weak var backbtnBackground: UIVisualEffectView!
    @IBOutlet weak var imageHeader: UIImageView!
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
    
    @IBOutlet weak var progressBar: UISlider!
    @IBOutlet weak var heading: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var headingPassed: String?
    var selectedImage: UIImage?
    
    var collectionObject: MyCollection?
    var sounds: [MySound] = []

    var audioPlayer: AVAudioPlayer?
    var currentlyPlayingIndex: IndexPath?
    var playbackTimer: Timer?

    
    //MARK: viewDidload function
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setting the imag as background
    
        imageHeader.image = selectedImage
        
        //table view settings
        tableView.delegate = self
        tableView.dataSource = self
        
        //back btn
        backbtnBackground.layer.cornerRadius = 20
        backbtnBackground.clipsToBounds = true
        
        playerBar.layer.cornerRadius = 20
        playerBar.clipsToBounds = true
        playerBar.layer.borderWidth = 1
        playerBar.layer.borderColor = UIColor.white.cgColor
        
        playerImage.layer.cornerRadius = 5
        playerImage.clipsToBounds = true
        
        //setting the heading
        heading.text = headingPassed ?? ""

        if let collection = collectionObject {

            if let soundSet = collection.sounds {
                if let soundArray = soundSet.allObjects as? [MySound] {
                    sounds = soundArray.sorted { $0.name ?? "" < $1.name ?? "" }
                }
            }
        }


    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animateFromTop(views: [tableView])


    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(updateMiniPlayer), name: .PlaybackStateDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateMiniPlayerProgress), name: .PlaybackProgressDidChange, object: nil)
        updateMiniPlayer()
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .PlaybackStateDidChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: .PlaybackProgressDidChange, object: nil)
    }


    @IBAction func playBtn(_ sender: Any) {
        PlaybackState.shared.togglePlayPause()
    }
    
    
    
    @IBAction func backBtn(_ sender: Any) {
        //go to home screen
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "home") 
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func progressBarAction(_ sender: UISlider) {
        guard let player = PlaybackState.shared.audioPlayer else { return }
            let newTime = TimeInterval(sender.value) * player.duration
            PlaybackState.shared.seek(to: newTime)
        
    }
    
    
    
    
    //MARK: Table View Data Source and Delegate Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return sounds.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recentCell", for: indexPath) as! recentCellModel

        let sound = sounds[indexPath.section]
        cell.soundName.text = sound.name ?? "Unnamed"
        
        // Sync with shared player
        let isCurrent = (PlaybackState.shared.currentSound == sound)
        let isPlaying = PlaybackState.shared.isPlaying && isCurrent
        let iconName = isPlaying ? "pause.circle.fill" : "play.circle.fill"
        cell.playButton.setImage(UIImage(systemName: iconName), for: .normal)
        cell.selectionStyle = .none
        
        cell.playButton.tag = indexPath.section
        cell.playButton.removeTarget(nil, action: nil, for: .allEvents) // Avoid duplication
        cell.playButton.addTarget(self, action: #selector(handlePlayPause(_:)), for: .touchUpInside)

        // Cell UI
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
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

    func animateFromTop(views: [UIView], baseDelay: Double = 0.2, duration: Double = 0.1) {
        for (index, view) in views.enumerated() {
            view.transform = CGAffineTransform(translationX: 0, y: -50)
            view.alpha = 0

            UIView.animate(withDuration: duration, delay: Double(index) * baseDelay, options: [.curveEaseOut], animations: {
                view.transform = .identity
                view.alpha = 1
            })
        }
    }
    


    func updatePlayerBar(for sound: MySound) {
        playingSound.text = sound.name
        playerImage.image = selectedImage
        endTime.text = formatTime(audioPlayer?.duration ?? 0)
        startTime.text = "0:00"
        progressBar.value = 0
    }

    func startPlaybackTimer() {
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            guard let player = self.audioPlayer else { return }
            self.progressBar.value = Float(player.currentTime / player.duration)
            self.startTime.text = self.formatTime(player.currentTime)
        }
    }

    func stopPlaybackTimer() {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }

    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }


    @objc func updateMiniPlayer() {
        let state = PlaybackState.shared
        playingSound.text = state.currentSound?.name ?? "No Sound"
        playerImage.image = state.currentImage
        playBtnInPlayer.setImage(UIImage(systemName: state.isPlaying ? "pause.circle.fill" : "play.circle.fill"), for: .normal)

        if let player = state.audioPlayer {
            endTime.text = formatTime(player.duration)
            startTime.text = formatTime(player.currentTime)
            progressBar.value = Float(player.currentTime / player.duration)
        } else {
            endTime.text = "0:00"
            startTime.text = "0:00"
            progressBar.value = 0
        }
        
        // Update all visible cells
        tableView.visibleCells.forEach { cell in
            if let recentCell = cell as? recentCellModel,
               let indexPath = tableView.indexPath(for: cell) {
                let sound = sounds[indexPath.section]
                let isCurrent = (state.currentSound == sound)
                let isPlaying = state.isPlaying && isCurrent
                let iconName = isPlaying ? "pause.circle.fill" : "play.circle.fill"
                recentCell.playButton.setImage(UIImage(systemName: iconName), for: .normal)
            }
        }
    }

    @objc func handlePlayPause(_ sender: UIButton) {
        let sound = sounds[sender.tag]
        let state = PlaybackState.shared
        
        if state.currentSound == sound {
            // Toggle play/pause for current sound
            state.togglePlayPause()
        } else {
            // Play new sound
            state.play(sound: sound, image: selectedImage)
        }
        
        // Update button state immediately
        let isPlaying = (state.currentSound == sound) && state.isPlaying
        sender.setImage(UIImage(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill"), for: .normal)
    }

    @objc func updateMiniPlayerProgress() {
        guard let player = PlaybackState.shared.audioPlayer else { return }
        startTime.text = formatTime(player.currentTime)
        progressBar.value = Float(player.currentTime / player.duration)
    }


  
}





