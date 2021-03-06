//
//  ScanVC.swift
//  wishlink
//
//  Created by Andy Chen on 9/21/15.
//  Copyright (c) 2015 edonesoft. All rights reserved.
//


import UIKit
import AVFoundation
import Foundation

protocol scanDelegate
{
    func scanCodeResult(code:String);
}


class ScanVC: RootVC,AVCaptureMetadataOutputObjectsDelegate  {
    
    @IBOutlet weak var scan_input: UIImageView!
    //    @IBOutlet weak var imageVIew_Mask: UIImageView!
    var device:AVCaptureDevice!;
    var input:AVCaptureDeviceInput!;
    var session:AVCaptureSession!;
    var output:AVCaptureMetadataOutput!;
    var preview:AVCaptureVideoPreviewLayer!;
    var stillImageOutput:AVCaptureStillImageOutput!
    var scaleNum:CGFloat = 1;
    var notiKey = "kScanPhoto";
    
    var myDelegate:scanDelegate!
    //MARK:Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupCamera();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnActionTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    @IBAction func btnBackAction(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        self.navigationController?.navigationBar.hidden = true
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        self.navigationController?.navigationBar.hidden = true
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: false)
    }
    

    override func  viewDidAppear(animated: Bool) {
        
        //        self.clearScanArea();
    }
    
    //MARK:Private
    func setupCamera()
    {
        if(!UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera))
        {
            UIAlertView(title: "", message: "设备不支持拍照功能!", delegate: nil, cancelButtonTitle: "确定").show();
            print("设备不支持拍照功能!", terminator: "");
            //            SVProgressHUD.showErrorWithStatusWithBlack("设备不支持拍照功能!")
            return;
        }
        device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        input = try? AVCaptureDeviceInput(device: self.device)
        output = AVCaptureMetadataOutput();
        output.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        
        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPresetHigh
        
        if(session.canAddInput(self.input))
        {
            session.addInput(self.input)
        }
        if(session.canAddOutput(self.output))
        {
            session.addOutput(self.output)
        }
        output.metadataObjectTypes =  [AVMetadataObjectTypeQRCode,AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code, AVMetadataObjectTypeCode128Code,AVMetadataObjectTypeCode93Code];
        
        preview =  AVCaptureVideoPreviewLayer(session: self.session)
        preview.videoGravity = AVLayerVideoGravityResizeAspectFill
        preview.frame = CGRectMake(0,0,self.view.frame.width,self.view.frame.height);
        self.view.layer.insertSublayer(self.preview, atIndex:0);
        self.view.awakeFromNib();
        session.startRunning();
    }
    
    
    //MARK AVCaptureMetadataOutputObjectsDelegate
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        var strValue:String!
        if(metadataObjects.count > 0)
        {
            let metadataObject:AVMetadataMachineReadableCodeObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject;
            strValue = metadataObject.stringValue
            print(strValue);
            
            if(self.myDelegate != nil)
            {
                self.myDelegate.scanCodeResult(strValue);
            }
            session.stopRunning()
            self.navigationController?.popViewControllerAnimated(true);
        }
        
    }
    
    
}


