//
//  CameraEngineViewController.swift
//  Camera
//
//  Created by Mohamed Shaat on 1/24/19.
//  Copyright © 2019 Mohamed Shaat. All rights reserved.
//

import UIKit
import MediaPlayer

public protocol cameraEngineDelegate {
   func didSelect(originalImage: UIImage,filteredImage: UIImage)
    func didSelect(videoUrl: URL , thumbnail: UIImage?)
}
public class CameraEngineViewController: UIViewController {
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var labelCounting: UILabel!
    @IBOutlet weak var flipImageView: UIImageView!
    @IBOutlet weak var flipButton: UIButton!
    @IBOutlet weak var flashImage: UIImageView!
    var cameraController: CameraController?
    public var cameraPosition: cameraPosition = .back
    var currentCameraType:cameraType = .photo
    public var delegate: cameraEngineDelegate?
    public var alllowCaptureImage = true
    public var allowCaptureVideo =  true
    public var flashType: flashType = .on
    public var minimumZoom: CGFloat = 1.0
    public var maximumZoom: CGFloat = 3.0
    public var maximumVideoDurationLimit:Int?
    var lastZoomFactor: CGFloat = 1.0
    private var timer: Timer?
    private var count = 0
    var pinchGesture = UIPinchGestureRecognizer()
    fileprivate var isRecording = false
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        previewView.frame = CGRect(x: 0, y: 0, width:  UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        setupButtonAction()
        setupPinchGesture()
        self.startCamera(cameraType: .photo)
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        setupNavigation()
        isRecording = false
        labelCounting.isHidden = true
        addObserverForVolumeButton()
        setupFlash()
    }
    func setupNavigation(){
        self.title = ""
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
      
    }

    func setupButtonAction() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector (photoCapture))
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector (videoCapture))
        tapGesture.numberOfTapsRequired = 1
        captureButton.addGestureRecognizer(tapGesture)
        captureButton.addGestureRecognizer(longGesture)
    }
    
    @IBAction func dismissAction(_ sender: Any) {
     
        self.dismiss(animated: true, completion: nil)
           cameraController?.session.stopRunning()
    }
    
    func addObserverForVolumeButton() {
        let volumeView = MPVolumeView(frame: CGRect(x: -200, y: -200, width: 300, height: 30))
        self.view.addSubview(volumeView)
        NotificationCenter.default.addObserver(self, selector: #selector(volumeChanged(notification:)),
                                               name: NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"),
                                               object: nil)
    }
    
    @objc func volumeChanged(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            if let volumeChangeType = userInfo["AVSystemController_AudioVolumeChangeReasonNotificationParameter"] as? String {
                if volumeChangeType == "ExplicitVolumeChange" {
                   photoCapture()
                }
            }
        }
    }
    
    @IBAction func flipAction(_ sender: Any) {
        if cameraPosition == .back {
            cameraPosition = .front
        } else {
            cameraPosition = .back
        }
        startCamera(cameraType: currentCameraType)
    }
    
    @IBAction func flashAction(_ sender: Any) {
        if flashType == .on {
          flashType = .auto
        } else {
          flashType = .on
        }
        setupFlash()
    }
    
    func setupFlash(){
        let bundle = Bundle(for: CameraEngineViewController.classForCoder())
        if flashType == .on {
         flashImage.image = UIImage(named:"ic_flash_on", in: bundle,compatibleWith: nil)
        } else {
          flashImage.image = UIImage(named:"ic_flash_off", in: bundle,compatibleWith: nil)
        }
        cameraController?.flashType = flashType
    }
    
    func startCamera(cameraType: cameraType){
        currentCameraType = cameraType
        cameraController = CameraController(previewView: previewView)
        cameraController?.setupAVCapture(cameratype: cameraType, position: cameraPosition)
    }
    
    @objc func photoCapture() {
        if isRecording == false && alllowCaptureImage == true {
        //startCamera(cameraType:.photo)
        cameraController?.captureImage {(image, error) in
            guard let image = image else {
                print(error ?? "Image capture error")
                return
            }
              self.startCamera(cameraType: .photo)
            let bundle = Bundle(for: CameraEngineViewController.classForCoder())
            let photoVideoCapturedViewController = PhotoVideoCapturedViewController(nibName: "PhotoVideoCapturedViewController", bundle: bundle)
            photoVideoCapturedViewController.image = image
            photoVideoCapturedViewController.previewType = .photo
            photoVideoCapturedViewController.delegate = self
           self.navigationController?.pushViewController(photoVideoCapturedViewController, animated: true)
        }
        } else {
            stopRecording()
        }
    }
    
    
    
    @objc func videoCapture(sender : UIGestureRecognizer) {
        if isRecording == false && sender.state != .ended && allowCaptureVideo == true{
         startSessionTimer()
         isRecording = true
         startCamera(cameraType:.video)
        cameraController?.captureVideo{(url, error) in
            guard let url = url else {
                print(error ?? "url error")
                return
            }
            let bundle = Bundle(for: CameraEngineViewController.classForCoder())
              self.startCamera(cameraType: .photo)
            let photoVideoCapturedViewController = PhotoVideoCapturedViewController(nibName: "PhotoVideoCapturedViewController", bundle: bundle)
            photoVideoCapturedViewController.videoURl = url
             photoVideoCapturedViewController.delegate = self
            photoVideoCapturedViewController.previewType = .video
            self.navigationController?.pushViewController(photoVideoCapturedViewController, animated:true )
        }
        } else if sender.state == .began{
            stopRecording()
        }
    }
    
  
    func stopRecording() {
        isRecording = false
        cameraController?.stopRecording()
        self.timer?.invalidate()
        labelCounting.text = ""
        count = 0
        labelCounting.isHidden = true
    }
    
    func startSessionTimer(){
        labelCounting.isHidden = false
        self.timer?.invalidate()
        self.timer = nil
        count = 0
        self.labelCounting.text = ""
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        if let mximumVideoCatureLimit = maximumVideoDurationLimit , mximumVideoCatureLimit < (count + 1) {
            stopRecording()
        } else if(count >= 0){
            let hours  = count / 3600
            let minutes = (count % 3600) / 60
            let seconds = (count % 3600) % 60
            labelCounting.text = String(format: "%02d:%02d:%02d",hours,minutes, seconds)
            count = count + 1
        } else {
            
        }
    }

}

extension CameraEngineViewController: cameraEngineDelegate {
    public func didSelect(videoUrl: URL, thumbnail: UIImage?) {
         self.dismiss(animated: true, completion: nil)
        self.delegate?.didSelect(videoUrl: videoUrl, thumbnail: thumbnail)
    }
    
    public func didSelect(originalImage: UIImage, filteredImage: UIImage) {
     self.dismiss(animated: true, completion: nil)
     self.delegate?.didSelect(originalImage:originalImage, filteredImage: filteredImage)
    }

}
