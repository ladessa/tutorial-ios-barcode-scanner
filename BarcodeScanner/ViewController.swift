//
//  ViewController.swift
//  BarcodeScanner
//
//  Created by Mujtaba Hassanpur on 10/12/15.
//  Copyright © 2015 Mujtaba Hassanpur. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession: AVCaptureSession!
    var captureDevice: AVCaptureDevice!
    var captureDeviceInput: AVCaptureDeviceInput!
    var captureDeviceOutput: AVCaptureMetadataOutput!
    var capturePreviewLayer: AVCaptureVideoPreviewLayer!
    var alertController: UIAlertController!
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    func initializeScanner() {
        captureSession = AVCaptureSession()
        
        do {
            // get the default device and use auto settings
            captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
            try captureDevice.lockForConfiguration()
            captureDevice.exposureMode = AVCaptureExposureMode.ContinuousAutoExposure
            captureDevice.whiteBalanceMode = AVCaptureWhiteBalanceMode.ContinuousAutoWhiteBalance
            captureDevice.focusMode = AVCaptureFocusMode.ContinuousAutoFocus
            if captureDevice.hasTorch {
                captureDevice.torchMode = AVCaptureTorchMode.Auto
            }
            captureDevice.unlockForConfiguration()
            
            // add the input/output devices
            captureSession.beginConfiguration()
            captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
            if captureSession.canAddInput(captureDeviceInput) {
                captureSession.addInput(captureDeviceInput)
            }
            
            // AVCaptureMetadataOutput is how we can determine
            captureDeviceOutput = AVCaptureMetadataOutput()
            captureDeviceOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
            if captureSession.canAddOutput(captureDeviceOutput) {
                captureSession.addOutput(captureDeviceOutput)
                captureDeviceOutput.metadataObjectTypes = captureDeviceOutput.availableMetadataObjectTypes
            }
            captureSession.commitConfiguration()
        }
        catch {
            displayAlert("Error", message: "Unable to set up the capture device.")
        }
        
        capturePreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        capturePreviewLayer.frame = self.view.layer.bounds
        
        //Show Bounding area - create a clearColor rectangle with red border - use your barcode`s size
        let rectangle: UIBezierPath = UIBezierPath(rect: CGRectMake(20, UIScreen.mainScreen().bounds.size.height/2 - 20, UIScreen.mainScreen().bounds.size.width-40, 35))
        rectangle.lineWidth = 1
        rectangle.stroke()
        
        
        // UIBezierPath to Layer
        let boundingLayer: CAShapeLayer = CAShapeLayer.init()
        boundingLayer.path = rectangle.CGPath
        boundingLayer.fillColor = UIColor.clearColor().CGColor
        boundingLayer.strokeColor = UIColor.redColor().CGColor
        
        //add your bounding area rectangle on screen
        capturePreviewLayer.addSublayer(boundingLayer)

        
        //write a info text in preview layer
        let label: CATextLayer = CATextLayer()
        let boundingAreaY : CGFloat = UIScreen.mainScreen().bounds.size.height/2 - 20;
        label.font = "Helvetica-Bold"
        label.fontSize = 12
        label.frame =  CGRectMake(0, boundingAreaY + 60, UIScreen.mainScreen().bounds.size.width, 21)
        label.string = "Position the barcode within the red lines"
        label.alignmentMode = kCAAlignmentCenter
        label.foregroundColor = UIColor.whiteColor().CGColor
        capturePreviewLayer.addSublayer(label)

        
        
        capturePreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.view.layer.addSublayer(capturePreviewLayer)
    }
    
    func startScanner() {
        if captureSession != nil {
            captureSession.startRunning()
        }
    }
    
    func stopScanner() {
        if captureSession != nil {
            captureSession.stopRunning()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.initializeScanner()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        startScanner()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        stopScanner()
    }
    
    func displayAlert(title: String, message: String) {
        alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let dismissAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
            self.alertController = nil
        })
        alertController.addAction(dismissAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    /* AVCaptureMetadataOutputObjectsDelegate */
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        if alertController != nil {
            return
        }
        
        if metadataObjects != nil && metadataObjects.count > 0 {
            if let machineReadableCode = metadataObjects[0] as? AVMetadataMachineReadableCodeObject {
                // get the barcode string
                let type = machineReadableCode.type
                let barcode = machineReadableCode.stringValue
                
                // display the barcode in an alert
                let title = "Barcode"
                let message = "Type: \(type)\nBarcode: \(barcode)"
                displayAlert(title, message: message)
            }
        }
        
    }
    
}

