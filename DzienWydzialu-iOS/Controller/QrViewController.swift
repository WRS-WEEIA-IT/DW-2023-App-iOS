//
//  QrViewController.swift
//  DzienWydzialu-iOS
//
//  Created by Bartek Chadryś on 28/02/2023.
//

import UIKit
import AVFoundation

class QrViewController: UIViewController {
    
    var avCaptureSession: AVCaptureSession!
    var avPreviewLayer: AVCaptureVideoPreviewLayer!

    @IBOutlet weak var squareFrame: UIImageView!
    
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

            let frameSize = CGSize(width: 200, height: 200)
            UIGraphicsBeginImageContextWithOptions(frameSize, false, 0)

            let context = UIGraphicsGetCurrentContext()

            context?.setStrokeColor(UIColor.white.cgColor)
            context?.setLineWidth(5.0)

            let roundedRectPath = UIBezierPath(roundedRect: CGRect(origin: CGPoint.zero, size: frameSize), cornerRadius: 20.0)
            roundedRectPath.stroke()
            let frameImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            let layer = CALayer()
            
            let imageView =  frameImage
            layer.contents = imageView?.cgImage
            layer.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
            layer.position = CGPoint(x: self.view.layer.bounds.midX, y: self.view.layer.bounds.midY)
            
            self.view.layer.addSublayer(layer)

            // Create a text layer
            let textLayer = CATextLayer()

            // Set the text layer's font
            textLayer.font = UIFont.systemFont(ofSize: 15).fontName as CFTypeRef

            // Set the text layer's font size
            textLayer.fontSize = 15.0

            // Set the text layer's text
            textLayer.string = "Swipe down to exit scanner!"
            textLayer.contentsScale = UIScreen.main.scale
            
            // Calculate the size of the text
            let textSize = (textLayer.string as? NSString)?.size(withAttributes: [.font: UIFont.systemFont(ofSize: 15)])

            // Center the text layer horizontally
            textLayer.frame = CGRect(x: ((self.view.layer.bounds.width - textSize!.width) / 2.0), y: 15, width: textSize!.width, height: textSize!.height)

            // Add the text layer to the sublayer
            self.view.layer.addSublayer(textLayer)
            
            self.avCaptureSession.startRunning()
        }
    }
    
    
    func failed() {
        let ac = UIAlertController(title: "Scanner not supported", message: "Please use a device with a camera. Because this device does not support scanning a code", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        avCaptureSession = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (avCaptureSession?.isRunning == false) {
            avCaptureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (avCaptureSession?.isRunning == true) {
            avCaptureSession.stopRunning()
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
        avCaptureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
        
        dismiss(animated: true)
    }
    
    func found(code: String) {
        print(code)
    }
}
