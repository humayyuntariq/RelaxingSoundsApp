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
    
    var headingPassed: String?
    var selectedImage: UIImage?
    //MARK: viewDidload function
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setting the imag as background
    
        imageHeader.image = selectedImage
        updateLabelColorBasedOnImage(selectedImage!, label: heading)
        
        //table view settings
        tableView.delegate = self
        tableView.dataSource = self
        
        //back btn
        backbtnBackground.layer.cornerRadius = 20
        backbtnBackground.clipsToBounds = true
        
        playerBar.layer.cornerRadius = 20
        playerBar.clipsToBounds = true
        
        //setting the heading
        heading.text = headingPassed ?? ""

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animateFromTop(views: [tableView, playerBar])


    }
    
    
    
    
    @IBAction func backBtn(_ sender: Any) {
        //go to home screen
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "homeScreen") as! homeViewContoller
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true, completion: nil)
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
        updateLabelColorBasedOnImage(selectedImage!, label: cell.soundName)
        
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
    
    func updateLabelColorBasedOnImage(_ image: UIImage, label: UILabel) {
        // Convert label frame to image coordinates
        guard let window = label.window else { return }
        let labelFrameInWindow = label.convert(label.bounds, to: window)
        let scale = image.scale
        
        let imageRect = CGRect(
            x: labelFrameInWindow.origin.x * scale,
            y: labelFrameInWindow.origin.y * scale,
            width: labelFrameInWindow.width * scale,
            height: labelFrameInWindow.height * scale
        )

        if let avgColor = image.averageColor(in: imageRect) {
            label.textColor = avgColor.isDarkColor ? .white : .black
        }
    }

    func animateFromTop(views: [UIView], baseDelay: Double = 0.2, duration: Double = 0.3) {
        for (index, view) in views.enumerated() {
            view.transform = CGAffineTransform(translationX: 0, y: -50)
            view.alpha = 0

            UIView.animate(withDuration: duration, delay: Double(index) * baseDelay, options: [.curveEaseOut], animations: {
                view.transform = .identity
                view.alpha = 1
            })
        }
    }

    
}


extension UIImage {
    func averageColor(in rect: CGRect) -> UIColor? {
        guard let cgImage = self.cgImage?.cropping(to: rect) else { return nil }

        let ciImage = CIImage(cgImage: cgImage)
        let extentVector = CIVector(x: 0, y: 0, z: rect.width, w: rect.height)
        
        let filter = CIFilter(name: "CIAreaAverage", parameters: [
            kCIInputImageKey: ciImage,
            kCIInputExtentKey: extentVector
        ])
        
        guard let outputImage = filter?.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext()

        context.render(outputImage,
                       toBitmap: &bitmap,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8,
                       colorSpace: CGColorSpaceCreateDeviceRGB())

        return UIColor(red: CGFloat(bitmap[0]) / 255,
                       green: CGFloat(bitmap[1]) / 255,
                       blue: CGFloat(bitmap[2]) / 255,
                       alpha: 1)
    }
}

extension UIColor {
    var isDarkColor: Bool {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let brightness = (r * 299 + g * 587 + b * 114) / 1000
        return brightness < 0.5
    }
}



