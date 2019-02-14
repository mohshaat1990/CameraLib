//
//  extension UIViewController.swift
//  Camera
//
//  Created by Mohamed Shaat on 1/24/19.
//  Copyright © 2019 Mohamed Shaat. All rights reserved.
//

import UIKit

extension UIViewController {
    
    public func cameraEngine()-> CameraEngineViewController  {
       let bundle = Bundle(for: CameraEngineViewController.classForCoder())
       let cameraViewController = CameraEngineViewController(nibName: "CameraEngineViewController", bundle: bundle)
       return cameraViewController
    }
    
    public func showCameraEngine(cameraEngineViewController: CameraEngineViewController) {
        let navigationController = UINavigationController(rootViewController: cameraEngineViewController)
        self.present(navigationController, animated: true, completion: nil)
    }
}
