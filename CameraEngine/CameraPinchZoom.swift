//
//  CameraEngineViewController.swift
//  Camera
//
//  Created by Mohamed Shaat on 1/24/19.
//  Copyright © 2019 Mohamed Shaat. All rights reserved.
//

import AVFoundation
import UIKit


extension CameraEngineViewController: UIGestureRecognizerDelegate {
    
    @objc func pinch(_ pinch: UIPinchGestureRecognizer) {
        
        func minMaxZoom(_ factor: CGFloat) -> CGFloat {
            return min(min(max(factor, minimumZoom), maximumZoom), (cameraController?.captureDevice.activeFormat.videoMaxZoomFactor)!)
        }
        
        func update(scale factor: CGFloat) {
            do {
                try cameraController?.captureDevice.lockForConfiguration()
                defer { cameraController?.captureDevice.unlockForConfiguration() }
                cameraController?.captureDevice.videoZoomFactor = factor
            } catch {
                print("\(error.localizedDescription)")
            }
        }
        
        let newScaleFactor = minMaxZoom(pinch.scale * lastZoomFactor)
        
        switch pinch.state {
        case .began: fallthrough
        case .changed: update(scale: newScaleFactor)
        case .ended:
            lastZoomFactor = minMaxZoom(newScaleFactor)
            update(scale: lastZoomFactor)
        default: break
        }
    }
    
    func setupPinchGesture(){
        self.pinchGesture.delegate = self
        self.pinchGesture = UIPinchGestureRecognizer(target: self, action:#selector(CameraEngineViewController.pinch(_:)))
        self.view.addGestureRecognizer(self.pinchGesture)
    }
    
}

