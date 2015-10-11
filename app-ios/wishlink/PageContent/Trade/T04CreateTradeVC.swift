//
//  T04CreateTradeVC.swift
//  wishlink
//
//  Created by whj on 15/8/19.
//  Copyright (c) 2015年 edonesoft. All rights reserved.
//

import UIKit

class T04CreateTradeVC: RootVC,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate,UITextFieldDelegate,UIScrollViewDelegate, CSActionSheetDelegate,WebRequestDelegate,T11SearchSuggestionDelegate {

    @IBOutlet weak var sv: UIScrollView!
    @IBOutlet weak var txtCategory: UITextField!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtPrice: UITextField!
    @IBOutlet weak var txtRemark: UITextView!
    @IBOutlet weak var txtCount: UITextField!
    @IBOutlet weak var txtSize: UITextField!
    @IBOutlet weak var txtBuyArea: UITextField!
    
    @IBOutlet weak var iv0: UIImageView!
    @IBOutlet weak var iv1: UIImageView!
    @IBOutlet weak var iv2: UIImageView!
    @IBOutlet weak var iv3: UIImageView!

    //顶部标题View的高度约束
    @IBOutlet weak var constraint_topViewHieght: NSLayoutConstraint!
    //通用View高度约束
    @IBOutlet weak var constraint_viewHeight: NSLayoutConstraint!

    var actionSheet: CSActionSheet!
    
    var item:ItemModel!
    
    //上传的图像列表
    var imagrArr:[UIImage] = [];
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.sv.delegate = self;
        
        self.txtCategory.delegate = self;
        self.txtName.delegate = self;
        self.txtPrice.delegate = self;
        self.txtRemark.delegate = self;
        self.txtCount.delegate = self;
        self.txtSize.delegate = self;
        self.txtBuyArea.delegate = self;
        self.httpObj.mydelegate = self;
        
  
        self.sv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKeyboard"));
        
        csActionSheet()
    }

    
    override func viewWillAppear(animated: Bool) {
        
        self.constraint_viewHeight.constant = UIHEPLER.resizeHeight(60.0);
        self.constraint_topViewHieght.constant=UIHEPLER.resizeHeight(75);
       
        self.navigationController?.navigationBarHidden = false;
        
         self.item = nil;
        
        let titleLabel: UILabel = UILabel(frame: CGRectMake(0, 0, 80, 20))
        titleLabel.text = "发布新订单"
        titleLabel.textColor = UIHEPLER.mainColor;
        titleLabel.font =  UIHEPLER.mainChineseFont15
        titleLabel.textAlignment = NSTextAlignment.Center
        
        
        let txtRemark: UILabel = UILabel(frame: CGRectMake(0, 20, 80, 20))
        txtRemark.text = "(*为必填项)"
        txtRemark.textColor = UIColor.redColor();
        txtRemark.font = UIHEPLER.getCustomFont(true, fontSsize: 11);
        txtRemark.textAlignment = NSTextAlignment.Center
  
        
        
        var titleView = UIView(frame: CGRectMake(0, 0, 50, 40))
        titleView.addSubview(titleLabel);
        titleView.addSubview(txtRemark);
        self.navigationItem.titleView = titleView;
        
        self.navigationController?.navigationBarHidden = false;
        
        
    }

    func csActionSheet() {
        
        var titles: Array<String> = ["取消", "从手机相册中选择", "拍照"]
        actionSheet = CSActionSheet.sharedInstance
        actionSheet.bindWithData(titles, delegate: self)
    }
    
    @IBAction func btnAction(sender: UIButton) {
    
        var tag = sender.tag;
        if(tag==11)//确认发布
        {
            var errmsg =  checkInput();
            if(errmsg != "")
            {
                UIHEPLER.alertErrMsg(errmsg);
            }
            else
            {
                
//                
//                var para:[String:String] = ["name":txtName.text.trim(),
//                    "brand":txtCategory.text.trim(),
//                    "country":txtBuyArea.text.trim(),
//                    "price":txtPrice.text.trim(),
//                    "spec":txtSize.text.trim(),
//                    "comment":txtRemark.text.trim()
////                    "file_a":(self.imagrArr.count>0?self.imagrArr[0]:"")
//                ]
                
  
                
                SVProgressHUD.showWithStatusWithBlack("请稍后...")
            
              var apiurl = SERVICE_ROOT_PATH + "item/create"
                
                
                   upload(
                        .POST,
                        URLString: apiurl,
                        multipartFormData: {
                            multipartFormData in
                            
                            multipartFormData.appendBodyPart(data: self.txtName.text.trim().dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "name")
                            multipartFormData.appendBodyPart(data: self.txtCategory.text.trim().dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "brand")
                            multipartFormData.appendBodyPart(data: self.txtBuyArea.text.trim().dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "country")
                            multipartFormData.appendBodyPart(data: self.txtPrice.text.trim().dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "price")
                            multipartFormData.appendBodyPart(data: self.txtSize.text.trim().dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "spec")
                            multipartFormData.appendBodyPart(data: self.txtRemark.text.trim().dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "comment")
                            if(self.imagrArr.count>0)
                            {
                                var imgName = "item_a.jpg"
                                var imgInfo = UIHEPLER.readImageFromLocalByName(imgName);
                                
                                var imageData = UIHEPLER.compressionImageToDate(imgInfo.img);
                                
                                var imgStream  = NSInputStream(data: imageData);
                                var len =   UInt64(imageData.length)
                                
                                multipartFormData.appendBodyPart(stream:imgStream, length:len, name: imgName, fileName: imgName, mimeType: "image/jpeg")
                            }
                            if(self.imagrArr.count>1)
                            {
                                
                                var imgName = "item_b.jpg"
                                var imgInfo = UIHEPLER.readImageFromLocalByName(imgName);
                                
                                var imageData = UIHEPLER.compressionImageToDate(imgInfo.img);
                                
                                var imgStream  = NSInputStream(data: imageData);
                                var len =   UInt64(imageData.length)
                                
                                multipartFormData.appendBodyPart(stream:imgStream, length:len, name: imgName, fileName: imgName, mimeType: "image/jpeg")
                            }
                            if(self.imagrArr.count>2)
                            {
                                var imgName = "item_c.jpg"
                                var imgInfo = UIHEPLER.readImageFromLocalByName(imgName);
                                
                                var imageData = UIHEPLER.compressionImageToDate(imgInfo.img);
                                
                                var imgStream  = NSInputStream(data: imageData);
                                var len =   UInt64(imageData.length)
                                
                                multipartFormData.appendBodyPart(stream:imgStream, length:len, name: imgName, fileName: imgName, mimeType: "image/jpeg")
                            }
                            if(self.imagrArr.count>3)
                            {
                                var imgName = "item_d.jpg"
                                var imgInfo = UIHEPLER.readImageFromLocalByName(imgName);
                                
                                var imageData = UIHEPLER.compressionImageToDate(imgInfo.img);
                                
                                var imgStream  = NSInputStream(data: imageData);
                                var len =   UInt64(imageData.length)
                                
                                multipartFormData.appendBodyPart(stream:imgStream, length:len, name: imgName, fileName: imgName, mimeType: "image/jpeg")
                            }
                            
                        },
                        encodingCompletion: {
                            encodingResult in
                            switch encodingResult {
                                
                            case .Success(let _upload, _, _ ):
                                
                                _upload.responseJSON {
                                    request, response, JSON, error in
                                    
                                    if(error == nil)
                                    {
                                        NSLog("Success:")
                                        
                                        var itemdic = JSON as! NSDictionary;
                                        var itemData =  itemdic.objectForKey("data") as! NSDictionary
                                        if(itemData.objectForKey("item") != nil)
                                        {
                                            var itemObj =  itemData.objectForKey("item") as! NSDictionary
                                            var item = ItemModel(dict: itemObj);
                                            self.item = item;
                                            print(item);
                                            if(item._id.length>0)
                                            {
                                                
                                                var para  = ["itemRef":item._id,
                                                    "quantity":self.txtCount.text.trim()];
                                                self.httpObj.httpPostApi("trade/create", parameters: para, tag: 12);
                                            }
                                        }
                                        else
                                        {
                                            
                                            
                                            SVProgressHUD.showErrorWithStatusWithBlack("提交数据失败！");
                                            NSLog("Fail:")
                                            
                                        }

                                    }
                                    else
                                    {
                                        
                                        
                                        SVProgressHUD.showErrorWithStatusWithBlack("提交数据失败！");
                                        NSLog("Fail:")
                                        
                                    }
                                    println(JSON)
                                    
                                }
                            case .Failure(let encodingError):
                                println("Failure")
                                println(encodingError)
                            }
                        }
                )
                
            }
        }
        else
        {
            actionSheet.show(true)
        }

    }
    
      func checkInput()->String{
        
        var result = "";
        
        var category = txtCategory.text.trim();
        if(category.length == 0)
        {
            return "品牌不能为空"
        }
        var name = txtName.text.trim();
        if(name.length == 0)
        {
            return "品名不能为空"
        }
        var country = txtBuyArea.text.trim();
        if(country.length == 0)
        {
            return "购买地不能为空"
        }
        var price = txtPrice.text.trim();
        if(price.length == 0)
        {
            return "出价不能为空"
        }
        var spec = txtSize.text.trim();
        if(spec.length == 0)
        {
            return "规格不能为空"
        }
        
        var count = txtCount.text.trim();
        if(count.length == 0)
        {
            return "数量不能为空"
        }
        if(self.imagrArr.count == 0)
        {
            return "请至少上传一张图片"
            
        }
        return result;
        
    }
    
    //MARK:弹出图片上传选择框
    func imgHeadChange(index: Int) {
        
        if index == 1001 {
            
            var imagePicker = UIImagePickerController()
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            imagePicker.delegate = self;
            self.presentViewController(imagePicker, animated: true, completion: nil);
        } else if index == 1002 {
            
            var imagePicker = UIImagePickerController()
            if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
                imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
                imagePicker.delegate = self;
                self.presentViewController(imagePicker, animated: true, completion: nil);
            }
        }
    }
    
    //MARK: UIImagePickerController delegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        var icount = self.imagrArr.count;
        let gotImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        picker.dismissViewControllerAnimated(true, completion: {
            () -> Void in
        
            if(self.imagrArr.count<4)
            {
                
                self.imagrArr.append(gotImage);
                
            }
            
            if(self.imagrArr.count>0 && icount == 0)
            {
                
                
                UIHEPLER.saveImageToLocal(self.imagrArr[0], strName: "item_a.jpg")
                self.iv0.image = self.imagrArr[0];
            }
            
            if(self.imagrArr.count>1 && icount == 1)
            {
                UIHEPLER.saveImageToLocal(self.imagrArr[1], strName: "item_b.jpg")
                self.iv1.image = self.imagrArr[1];
            }
            if(self.imagrArr.count>2 && icount == 2)
            {
                UIHEPLER.saveImageToLocal(self.imagrArr[2], strName: "item_c.jpg")
                self.iv2.image = self.imagrArr[2];
            }
            if(self.imagrArr.count>3 && icount == 3)
            {
                UIHEPLER.saveImageToLocal(self.imagrArr[3], strName: "item_d.jpg")
                self.iv3.image = self.imagrArr[3];
            }
            
//            var imgData = UIImageJPEGRepresentation(gotImage, 1.0)
        })
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func dismissKeyboard()
    {
        self.txtCategory.resignFirstResponder();
        self.txtName.resignFirstResponder();
        self.txtPrice.resignFirstResponder();
        self.txtRemark.resignFirstResponder();
        self.txtCount.resignFirstResponder();
        self.txtSize.resignFirstResponder();
        self.txtBuyArea.resignFirstResponder();
        
    }
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
        self.dismissKeyboard();
    }
    
    //MARK: - CSActionSheetDelegate
    
    func csActionSheetAction(view: CSActionSheet, selectedIndex index: Int) {
        
        imgHeadChange(index)
    }
    
    //MARK:UItextFiledDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        self.dismissKeyboard();
        return true;
    }
    var lastSelectTextFiledTag = -1;
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        if(textField.tag>3 || textField.tag == 0)
        {
            return true;
        }
        else
        {
            self.lastSelectTextFiledTag = textField.tag;
            var vc =  T11SearchSuggestionVC(nibName: "T11SearchSuggestionVC", bundle: NSBundle.mainBundle())
            vc.myDelegate = self;
            if(textField.tag == 1)
            {
                vc.searchType = .brand;
            }
            else if(textField.tag == 2)
            {
                vc.searchType = .name;
            }
            else if(textField.tag == 3)
            {
                vc.searchType = .country;
            }
            self.presentViewController(vc, animated: true, completion: nil);
            return false;
        }
    }

    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n")
        {
            
            self.txtRemark.resignFirstResponder();
            
            return false;
        }
        
        return true;
    }

    //MAEK: WebrequestDelegate
    func requestDataComplete(response: AnyObject, tag: Int) {
     if(tag == 12)//trade创建成功,准备页面跳转
        {
            
            SVProgressHUD.dismiss();
            var dic = response as! NSDictionary;
            var tradeDic = dic.objectForKey("trade") as!  NSDictionary;
            var tradeItem = TradeModel(dict: tradeDic);
            
            var vc = T05PayVC(nibName: "T05PayVC", bundle: NSBundle.mainBundle());
            vc.item = self.item;
            vc.trade = tradeItem;
            self.navigationController?.pushViewController(vc, animated: true);
            
        }
    }
    func requestDataFailed(error: String) {
        
        SVProgressHUD.dismiss();
        UIHEPLER.alertErrMsg(error);
        
    }
    
    //T11SelectSuggestionDelegate
    func GetSelectValue(inputValue: String) {
        if(self.lastSelectTextFiledTag == 1)
        {
            txtCategory.text = inputValue;
        }
        else if(self.lastSelectTextFiledTag == 2)
        {
            txtName.text =  inputValue;
        }
        else if(self.lastSelectTextFiledTag == 3)
        {
            txtBuyArea.text = inputValue;
        }
        
        self.lastSelectTextFiledTag = -1;
    }
    
}
