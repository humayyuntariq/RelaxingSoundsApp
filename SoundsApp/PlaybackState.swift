//
//  PlaybackState.swift
//  SoundsApp
//
//  Created by Humayun Tariq on 25/07/2025.
//

import Foundation
import AVFoundation
import UIKit

class PlaybackState {
    static let shared = PlaybackState()
    
    private(set) var currentSound: MySound?
    private(set) var currentImage: UIImage?
    private(set) var isPlaying = false
    private(set) var audioPlayer: AVAudioPlayer?
    private var progressTimer: Timer?
    
    private init() {}
    
    func play(sound: MySound, image: UIImage?) {
        guard let fileName = sound.fileName,
              let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else {
            print("Could not find sound file")
            return
        }

        do {
            if currentSound?.fileName != sound.fileName {
                audioPlayer?.stop()
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                currentSound = sound
                currentImage = image
                
                // Update lastPlayed date
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                sound.lastPlayed = Date()
                try context.save()
            }

            audioPlayer?.play()
            isPlaying = true
            startProgressTimer()
            notifyStateChange()
        } catch {
            print("Playback error: \(error)")
        }
    }
    func togglePlayPause() {
        if isPlaying {
            audioPlayer?.pause()
            isPlaying = false
        } else {
            audioPlayer?.play()
            isPlaying = true
        }
        notifyStateChange()
    }
    
    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        currentSound = nil
        currentImage = nil
        isPlaying = false
        stopProgressTimer()
        notifyStateChange()
    }
    
    private func startProgressTimer() {
        stopProgressTimer()
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            NotificationCenter.default.post(name: .PlaybackProgressDidChange, object: nil)
        }
    }
    
    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
    
    private func notifyStateChange() {
        NotificationCenter.default.post(name: .PlaybackStateDidChange, object: nil)
    }
}

extension Notification.Name {
    static let PlaybackStateDidChange = Notification.Name("PlaybackStateDidChange")
    static let PlaybackProgressDidChange = Notification.Name("PlaybackProgressDidChange")
}

extension MySound {
    var identifier: String {
        return name ?? UUID().uuidString // or use actual UUID from CoreData
    }
}


