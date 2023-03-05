//
//  QrViewController.swift
//  DzienWydzialu-iOS
//
//  Created by Bartek Chadryś on 28/02/2023.
//

import UIKit
import AVFoundation
import FirebaseFirestore

class QrViewController: UIViewController {
    
    var avCaptureSession: AVCaptureSession!
    var avPreviewLayer: AVCaptureVideoPreviewLayer!
            
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        avCaptureSession = AVCaptureSession()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
                self.failed()
                return
            }
            let avVideoInput: AVCaptureDeviceInput
            
            do {
                avVideoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            } catch {
                self.failed()
                return
            }
            
            if (self.avCaptureSession.canAddInput(avVideoInput)) {
                self.avCaptureSession.addInput(avVideoInput)
            } else {
                self.failed()
                return
            }
            
            let metadataOutput = AVCaptureMetadataOutput()
            
            if (self.avCaptureSession.canAddOutput(metadataOutput)) {
                self.avCaptureSession.addOutput(metadataOutput)
                
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417, .qr]
            } else {
                self.failed()
                return
            }
                                  
            self.avPreviewLayer = AVCaptureVideoPreviewLayer(session: self.avCaptureSession)
            self.avPreviewLayer.frame = self.view.layer.bounds
            self.avPreviewLayer.videoGravity = .resizeAspectFill
            self.view.layer.addSublayer(self.avPreviewLayer)

            //MARK: - Frame square
            
            let frameSize = CGSize(width: K.frameWidth, height: K.frameHeight)
            UIGraphicsBeginImageContextWithOptions(frameSize, false, 0)

            let context = UIGraphicsGetCurrentContext()

            context?.setStrokeColor(UIColor.white.cgColor)
            context?.setLineWidth(5.0)

            let roundedRectPath = UIBezierPath(roundedRect: CGRect(origin: CGPoint.zero, size: frameSize), cornerRadius: 15.0)
            roundedRectPath.stroke()
            let frameImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            let layer = CALayer()
            
            let imageView = frameImage
            layer.contents = imageView?.cgImage
            layer.frame = CGRect(x: 0, y: 0, width: K.frameWidth, height: K.frameHeight)
            layer.position = CGPoint(x: self.view.layer.bounds.midX, y: self.view.layer.bounds.midY)
            
            self.view.layer.addSublayer(layer)

            //MARK: - Top text
            
            let textLayer = CATextLayer()
            textLayer.font = UIFont(name: "Montserrat-SemiBold", size: K.qrTextSize) as CFTypeRef
            textLayer.fontSize = K.qrTextSize
            textLayer.string = "Swipe down to exit scanner!"
            textLayer.contentsScale = UIScreen.main.scale
            
            let textSize = (textLayer.string as? NSString)?.size(withAttributes: [.font: UIFont(name: "Montserrat-SemiBold", size: K.qrTextSize) as Any])

            textLayer.frame = CGRect(x: ((self.view.layer.bounds.width - textSize!.width) / 2.0), y: K.qrTextYDistance, width: textSize!.width, height: textSize!.height)

            textLayer.shadowColor = UIColor.black.cgColor
            textLayer.shadowOffset = CGSize(width: 0, height: 2)
            textLayer.shadowOpacity = 0.5
            textLayer.shadowRadius = 2
            
            self.view.layer.addSublayer(textLayer)
            
            DispatchQueue.global(qos: .background).async {
                    self.avCaptureSession.startRunning()
                }
        }
    }
    
    
    func failed() {
        let ac = UIAlertController(title: "Scanner not supported", message: "Please use a device with a camera. Because this device does not support scanning a code", preferredStyle: .alert)
        DispatchQueue.global(qos: .background).async {
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
            self.avCaptureSession = nil
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (avCaptureSession?.isRunning == false) {
            DispatchQueue.global(qos: .background).async {
                self.avCaptureSession.startRunning()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DispatchQueue.global(qos: .background).async {
            if (self.avCaptureSession?.isRunning == true) {
                self.avCaptureSession.stopRunning()
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
}
extension QrViewController : AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        DispatchQueue.global(qos: .background).async {
            self.avCaptureSession.stopRunning()
        }
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            manageCode(codeString: stringValue)
        }
                
        dismiss(animated: true)
    }
    
    func manageCode(codeString: String) {
        var codeArray: [String] = []
        if let currentCodeArray: [String] = K.defaults.sharedUserDefaults.stringArray(forKey: K.defaults.codeArray) {
            if currentCodeArray.contains(codeString) {
                self.errorVibration()
                return
            } else {
                codeArray = currentCodeArray
            }
        }
        
        db.collection("tasks").addSnapshotListener { snapshot, error in
            if error != nil {
                print("Error fetching data from Firebase!")
            } else {
                if let snapshotDocuments = snapshot?.documents {
                    for document in snapshotDocuments {
                        let documentData = document.data()
                        if let taskQrCode = documentData[K.tasks.qrCode] as? String {
                            if codeString == taskQrCode {
                                codeArray.append(codeString)
                                K.defaults.sharedUserDefaults.set(codeArray, forKey: K.defaults.codeArray)
                                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                                return
                            }
                        } else {
                            print("Failed to fetch task's qrCode")
                        }
                    }
                }
            }
        }
        
        self.errorVibration()
        K.defaults.sharedUserDefaults.set(codeArray, forKey: K.defaults.codeArray)
    }
    
    func errorVibration() {
        let errorVibrate = UIImpactFeedbackGenerator(style: .heavy)
        errorVibrate.prepare()
        errorVibrate.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            errorVibrate.impactOccurred()
        }
    }
}
