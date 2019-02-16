//
//  CameraController.swift
//  Camera
//
//  Created by Mohamed Shaat on 1/24/19.
//  Copyright © 2019 Mohamed Shaat. All rights reserved.
//

import AVFoundation
import UIKit

enum cameraType {
    case video
    case photo
}

public enum cameraPosition {
    case front
    case back
}

public enum flashType {
    case auto
    case on
}

class CameraController: NSObject {
    
    var previewView:UIView?
    var photoOutput = AVCapturePhotoOutput()
    var previewLayer:AVCaptureVideoPreviewLayer!
    var videoOutput = AVCaptureMovieFileOutput()
    var captureDevice : AVCaptureDevice!
    let session = AVCaptureSession()
     var flashType: flashType = .on
    var pinchGesture = UIPinchGestureRecognizer()
    var photoCaptureCompletionBlock: ((UIImage?, Error?) -> Void)?
    var videoCaptureCompletionBlock: ((URL?, Error?) -> Void)?
    var mximumVideoCatureLimit:Int?
    
     init(previewView:UIView) {
       self.previewView = previewView
    }
    
}

extension CameraController {

    func setupAVCapture(cameratype: cameraType,position: cameraPosition){
        session.sessionPreset = AVCaptureSession.Preset.high
        var cameraPosition: AVCaptureDevice.Position = .back
        if position == .front {
            cameraPosition = .front
        }
        guard let device = AVCaptureDevice
            .default(AVCaptureDevice.DeviceType.builtInWideAngleCamera,
                     for: .video,
                     position: cameraPosition) else {
                        return
        }
        captureDevice = device
        beginSession(cameratype: cameratype)
    }
    
    func beginSession(cameratype:cameraType){
        var deviceInput: AVCaptureDeviceInput!
        
        do {
            deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            guard deviceInput != nil else {
                print("error: cant get deviceInput")
                return
            }
            
            if self.session.canAddInput(deviceInput){
                self.session.addInput(deviceInput)
            }
            let audioInput = AVCaptureDevice.default(for: AVMediaType.audio)
            if let audioInput = audioInput {
            try self.session.addInput(AVCaptureDeviceInput(device: audioInput))
            }
            if cameratype == .photo {
            try configurePhotoOutput()
            } else {
             try  configureVideo()
            }
        } catch let error as NSError {
            deviceInput = nil
            print("error: \(error.localizedDescription)")
        }
    }
    
    func configurePhotoOutput() throws {
        if session.canAddOutput(photoOutput) {
            photoOutput.isHighResolutionCaptureEnabled = true
            session.addOutput(photoOutput)
            setupPreview()
            session.startRunning()
        }
       
    }
    
    func setupPreview() {
        previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        let rootLayer :CALayer = (self.previewView?.layer)!
        rootLayer.masksToBounds=true
        previewLayer.frame = rootLayer.bounds
        rootLayer.addSublayer(self.previewLayer)
        session.startRunning()
    }
    
    func captureImage(completion: @escaping (UIImage?, Error?) -> Void) {
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                             kCVPixelBufferWidthKey as String: 160,
                             kCVPixelBufferHeightKey as String: 160]
        settings.previewPhotoFormat = previewFormat
        if flashType == .auto {
         settings.flashMode = .auto
        } else {
         settings.flashMode = .on
        }
        self.photoOutput.capturePhoto(with: settings, delegate: self)
        self.photoCaptureCompletionBlock = completion
    }
    
    func configureVideo() throws {
        
        videoOutput = AVCaptureMovieFileOutput()
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
            setupPreview()
            session.startRunning()
        }
    }
    
     func captureVideo(completion: @escaping (URL?, Error?) -> Void) {
            let outputPath = "\(NSTemporaryDirectory())output.mov"
            let outputURL = URL(fileURLWithPath: outputPath)
            
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: outputPath) {
                do {
                    try fileManager.removeItem(atPath: outputPath)
                } catch {
                    print("error removing item at path: \(outputPath)")
                    return
                }
            }
            self.videoCaptureCompletionBlock = completion
            videoOutput.startRecording(to: outputURL, recordingDelegate: self)
    }
    
    func stopRecording(){
        videoOutput.stopRecording()
    }
    
    func setFlashType(flashType: flashType ) {
     self.flashType = flashType
    }

}

extension CameraController: AVCapturePhotoCaptureDelegate {
    public func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?,
                            resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Swift.Error?) {
        if let error = error { self.photoCaptureCompletionBlock?(nil, error) }
            
        else if let buffer = photoSampleBuffer,let photoPreviewBuffer = previewPhotoSampleBuffer, let data = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: buffer, previewPhotoSampleBuffer: photoPreviewBuffer),
            let image = UIImage(data: data) {
            self.photoCaptureCompletionBlock?(image, nil)
        }
            
    }
}

extension CameraController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        self.videoCaptureCompletionBlock?(outputFileURL,nil)
    }
}
