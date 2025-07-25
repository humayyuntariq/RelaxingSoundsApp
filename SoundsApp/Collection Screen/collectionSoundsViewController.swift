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
        
        animateFromTop(views: [tableView,playerBar])


    }

    @IBAction func playBtn(_ sender: Any) {
        guard let player = audioPlayer else { return }
        if player.isPlaying {
            player.pause()
            playBtnInPlayer.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
            stopPlaybackTimer()
        } else {
            player.play()
            playBtnInPlayer.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
            startPlaybackTimer()
        }
        
    }
    
    
    
    @IBAction func backBtn(_ sender: Any) {
        //go to home screen
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "homeScreen") as! homeViewContoller
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func progressBarAction(_ sender: UISlider) {
        if let player = audioPlayer {
                let newTime = TimeInterval(sender.value) * player.duration
                player.currentTime = newTime
            }
        
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
        
        cell.playButton.tag = indexPath.section
        cell.playButton.setImage(UIImage(systemName: indexPath == currentlyPlayingIndex && audioPlayer?.isPlaying == true ? "pause.circle.fill" : "play.circle.fill"), for: .normal)
        cell.playButton.addTarget(self, action: #selector(handlePlayPause(_:)), for: .touchUpInside)


        // cell design
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
    
    @objc func handlePlayPause(_ sender: UIButton) {
        let section = sender.tag
        let indexPath = IndexPath(row: 0, section: section)
        let sound = sounds[section]

        if indexPath == currentlyPlayingIndex, let player = audioPlayer {
            if player.isPlaying {
                player.pause()
                sender.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
                playBtnInPlayer.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
                stopPlaybackTimer()
            } else {
                player.play()
                sender.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
                playBtnInPlayer.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
                startPlaybackTimer()
            }
            return
        }

        // If a different sound is selected
        audioPlayer?.stop()
        stopPlaybackTimer()

        guard let fileName = sound.fileName,
              let url = Bundle.main.url(forResource: fileName.replacingOccurrences(of: ".mp3", with: ""), withExtension: "mp3") else {
            print("❌ File not found:", sound.fileName ?? "nil")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            currentlyPlayingIndex = indexPath

            updatePlayerBar(for: sound)
            playBtnInPlayer.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
            startPlaybackTimer()

            tableView.reloadData()

        } catch {
            print("Error playing sound: \(error.localizedDescription)")
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


    
  
}





