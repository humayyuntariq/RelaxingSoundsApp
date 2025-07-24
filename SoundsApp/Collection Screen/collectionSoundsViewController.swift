//
//  collectionSoundsViewController.swift
//  SoundsApp
//
//  Created by Humayun Tariq on 24/07/2025.
//

import UIKit

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
    
    //MARK: viewDidload function
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setting the imag as background
        let backgroundImage = UIImage(named: "background01")
        let backgroundImageView = UIImageView(frame: UIScreen.main.bounds)
        backgroundImageView.image = backgroundImage
        backgroundImageView.contentMode = .scaleAspectFill
        view.addSubview(backgroundImageView)
        view.sendSubviewToBack(backgroundImageView)
        
        //table view settings
        tableView.delegate = self
        tableView.dataSource = self
        
        //back btn
        backbtnBackground.layer.cornerRadius = 20
        backbtnBackground.clipsToBounds = true
        
        playerBar.layer.cornerRadius = 20
        playerBar.clipsToBounds = true

        
    }
    
    
    
    
    @IBAction func backBtn(_ sender: Any) {
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
    
}
