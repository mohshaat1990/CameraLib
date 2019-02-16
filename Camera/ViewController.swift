//
//  ExtensionUINavigationBar.swift
//  Camera
//
//  Created by Mohamed Shaat on 1/24/19.
//  Copyright © 2019 Mohamed Shaat. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func cameraAction(_ sender: Any) {
        let cameraViewController = cameraEngine()
        cameraViewController.delegate = self
        cameraViewController.maximumVideoDurationLimit = 60
        cameraViewController.cameraPosition = .back
        cameraViewController.flashType = .on
        showCameraEngine(cameraEngineViewController: cameraViewController)
    }
    
}
extension ViewController: cameraEngineDelegate {
    func didSelect(videoUrl: URL, thumbnail: UIImage?) {
      
    }
    
    
    func didSelect(originalImage: UIImage, filteredImage: UIImage) {
        
    }
}
