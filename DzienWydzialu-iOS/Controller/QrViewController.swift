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
            
            let frameSize = CGSize(width: K.qrFrameWidth, height: K.qrFrameHeight)
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
            layer.frame = CGRect(x: 0, y: 0, width: K.qrFrameWidth, height: K.qrFrameHeight)
            layer.position = CGPoint(x: self.view.layer.bounds.midX, y: self.view.layer.bounds.midY)
            
            self.view.layer.addSublayer(layer)
            
            //MARK: - Exit from scanner
            
            let crossShapeLayer = CAShapeLayer()

            let crossSize = 20.0
            let xPos = 35.0
            let yPos = 65.0
            
            let crossPath = UIBezierPath()
            crossPath.move(to: CGPoint(x: 0, y: 0))
            crossPath.addLine(to: CGPoint(x: crossSize, y: crossSize))
            crossPath.move(to: CGPoint(x: crossSize, y: 0))
            crossPath.addLine(to: CGPoint(x: 0, y: crossSize))

            crossShapeLayer.path = crossPath.cgPath
            crossShapeLayer.lineWidth = 2.0
            crossShapeLayer.strokeColor = UIColor.white.cgColor
            crossShapeLayer.fillColor = UIColor.clear.cgColor
            crossShapeLayer.frame = CGRect(x: 0, y: 0, width: crossSize, height: crossSize)
            crossShapeLayer.position = CGPoint(x: self.view.layer.bounds.minX+xPos, y: self.view.layer.bounds.minY+yPos)

            self.view.layer.addSublayer(crossShapeLayer)

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissViewController))
            self.view.addGestureRecognizer(tapGesture)
            
            DispatchQueue.global(qos: .background).async {
                    self.avCaptureSession.startRunning()
                }
        }
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanner not supported", message: "Please use a device with a camera. Because this device does not support scanning a code", preferredStyle: .alert)
        DispatchQueue.main.async {
            let action = UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.dismissViewController()
            })
            ac.addAction(action)
            self.present(ac, animated: true)
            self.avCaptureSession = nil
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = true
        if (avCaptureSession?.isRunning == false) {
            DispatchQueue.global(qos: .background).async {
                self.avCaptureSession.startRunning()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tabBarController?.tabBar.isHidden = false
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
    
    @objc func dismissViewController() {
        dismiss(animated: true, completion: nil)
        self.tabBarController?.selectedIndex = K.TabBarIndex.tasks
        self.tabBarController?.selectedViewController?.viewDidLoad()
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
            self.dismissViewController()
        }
    }
    
    func manageCode(codeString: String) {
        var codeArray: [String] = []
        if let currentCodeArray = K.defaults.sharedUserDefaults.stringArray(forKey: K.defaults.codeArray) {
            if currentCodeArray.contains(codeString) {
                DispatchQueue.main.async {
                    self.errorVibration()
                    let alert = AlertViewController()
                    alert.parentVC = self
                    alert.isWrong = false
                    alert.homeAlert = false
                    alert.appear(sender: self)
                    return
                }
                return
            } else {
                codeArray = currentCodeArray
            }
        }
        
        var taskFound = false
        
        DispatchQueue.main.async {
            self.db.collection("tasks").getDocuments { snapshot, error in
                if error != nil { return }
                guard let snapshotDocuments = snapshot?.documents else { return }
                
                for document in snapshotDocuments {
                    let documentData = document.data()
                    guard let newTask = TaskCreator.createTask(documentData: documentData) else { continue }
                    
                    if newTask.qrCode == codeString {
                        taskFound = true
                        codeArray.append(codeString)
                        K.defaults.sharedUserDefaults.set(codeArray, forKey: K.defaults.codeArray)
                        self.foundVibration()
                        
                        self.updatePoints(newPoints: newTask.points)
                        
                        let alert = TaskAlert()
                        alert.parentVC = self
                        alert.task = newTask
                        alert.appear(sender: self)
                        break
                    }
                }
                if !taskFound {
                    self.errorVibration()
                    let alert = AlertViewController()
                    alert.parentVC = self
                    alert.isWrong = true
                    alert.homeAlert = false
                    alert.appear(sender: self)
                    return
                }
            }
        }
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
    
    func foundVibration() {
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    func updatePoints(newPoints: Int) {
        DispatchQueue.main.async {
            var points = K.defaults.sharedUserDefaults.integer(forKey: K.defaults.points)
            points += newPoints
            K.defaults.sharedUserDefaults.set(points, forKey: K.defaults.points)
            if let id = K.defaults.sharedUserDefaults.string(forKey: K.defaults.codeId) {
                self.db.collection("users").document(id).updateData(["points" : points, "time" : Timestamp.init()])
            }
        }
    }
}
