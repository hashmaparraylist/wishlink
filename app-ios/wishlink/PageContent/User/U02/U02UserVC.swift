//
//  U02UserVC.swift
//  wishlink
//
//  Created by Yue Huang on 8/17/15.
//  Copyright (c) 2015 edonesoft. All rights reserved.
//

import UIKit

class U02UserVC: RootVC, WebRequestDelegate, UIScrollViewDelegate {

    @IBOutlet weak var orderBtn:        UIButton!
    @IBOutlet weak var recommendBtn:    UIButton!
    @IBOutlet weak var collectionBtn:   UIButton!
    @IBOutlet weak var settingBtn:      UIButton!
    
    @IBOutlet weak var subVCView: UIView!
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var contryLabel: UILabel!
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var v_TopView: UIView!
    @IBOutlet weak var v_baseInfo: UIView!
    
    
    var selectedBtn: UIButton!
    var userModel: UserModel = UserModel.shared
    
    var orderTradeVC: U02OrderTradeVC!
    var recommendVC: U02RecommendVC!
    var favoriteVC: U02FavoriteVC!
    var settingVC: U03SettingVC!
    
    var orderListDefaultModel:BuyerSellerType!;
    
//    lazy var loginVC: U01LoginVC = {
//        let vc = U01LoginVC(nibName: "U01LoginVC", bundle: MainBundle)
//        vc.hideSkipBtn = true
//        return vc
//    }()
    
    
    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.prepareData()
        self.prepareUI()

        self.getUser()
        NSNotificationCenter.defaultCenter().addObserverForName(LoginSuccessNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (noti) -> Void in
            self.fillDataForUI()
        }
        self.loadComNavTitle("我的wishlink");

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
       self.navigationController!.navigationBar.hidden = true;

        if self.userModel.isLogin == false {//弹出登陆窗体
            self.view.hidden = true;
            UIHEPLER.showLoginPage(self, isToHomePage: true);
            
        }
        else
        {
            self.view.hidden = false;
            self.view.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight)
            self.fillDataForUI()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.adjustUI()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func prepareUI() {
        
        self.prepareSubVC()
        
        self.selectedBtn = self.orderBtn
        self.orderBtnAction(self.orderBtn)
    }
    
    // MARK: - delegate
    func requestDataComplete(response: AnyObject, tag: Int) {
        if tag == 10 {
            if let userDic = response["user"] as? [String: AnyObject] {
                self.userModel.userDic = userDic
                
                if(self.userModel.isLogin)
                {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.fillDataForUI()
                    })
                }
                else
                {
                    
                }
            }
        }
    }
    
    func requestDataFailed(error: String,tag:Int) {
        if(tag == 10)
        {
            httpObj.httpGetApi("user/loginAsGuest", tag: 10);
        }
    }
    
    // MARK: - response event
    
    @IBAction func orderBtnAction(sender: AnyObject) {
        
        self.selectedBtn.selected = false
        self.selectedBtn = sender as! UIButton
        self.selectedBtn.selected = true;
    
        self.orderTradeVC.resetConditionView()
   
        self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    @IBAction func recommendBtnAction(sender: AnyObject) {
        
        self.selectedBtn.selected = false;
        self.selectedBtn = sender as! UIButton
        self.selectedBtn.selected = true;
        self.orderTradeVC.resetConditionView()
        self.scrollView.setContentOffset(CGPoint(x: ScreenWidth * 1, y: 0), animated: true)

        self.recommendVC.getRecommendation()
    }
    
    @IBAction func collectionBtnAction(sender: AnyObject) {
        
        self.selectedBtn.selected = false;
        self.selectedBtn = sender as! UIButton
        self.selectedBtn.selected = true;
        self.orderTradeVC.resetConditionView()
        self.scrollView.setContentOffset(CGPoint(x: ScreenWidth * 2, y: 0), animated: true)
        self.favoriteVC.getFavoriteList()
    }
    
    @IBAction func settingBtnAction(sender: AnyObject) {
        
        self.selectedBtn.selected = false;
        self.selectedBtn = sender as! UIButton
        self.selectedBtn.selected = true;
        self.orderTradeVC.resetConditionView()
        self.settingVC.fillDataForUI()
        self.scrollView.setContentOffset(CGPoint(x: ScreenWidth * 3, y: 0), animated: true)
        self.settingVC.gettingSet()
    }
    
//    @IBAction func settingBtnAction(sender: AnyObject) {
//        let vc = U03SettingVC(nibName: "U03SettingVC", bundle: NSBundle.mainBundle())
//        self.navigationController!.pushViewController(vc, animated: true)
//    }
    
    // MARK: - prive method
    
    func getUser() {
        if self.userModel.isLogin == true {
            return
        }
//        var registrationId = ""
//        var rid = APService.registrationID()
//        if rid.length != 0 {
//            registrationId = rid;
//        }
        self.httpObj.httpGetApi("user/get", parameters: nil, tag: 10)
    }
    
    func prepareData() {
        
        self.httpObj.mydelegate = self
        self.scrollView.delegate = self;
    }
    
    // 根据用户数据填充界面
    func fillDataForUI() {
        if userModel.isLogin == true {
            self.nicknameLabel.text = self.userModel.nickname;
            
            self.httpObj.renderImageView(self.headImageView, url: userModel.portrait, defaultName: "")
            self.httpObj.renderImageView(self.bgImageView, url: userModel.background, defaultName: "")
            if(self.userModel.receiversArray != nil && self.userModel.receiversArray.count>0)
            {
                let result = UserModel.shared.receiversArray.filter{itemObj -> Bool in
                    return (itemObj as ReceiverModel).isDefault == true;
                }
                if(result.count>0)
                {
                    self.contryLabel.text = result[0].province;
                }
                else
                {
                    self.contryLabel.text = self.userModel.receiversArray[0].province;
                }
            }
            else
            {
                self.contryLabel.text = "--"
            }
        }
    }
    
    func adjustUI() {
        self.orderTradeVC.view.frame = self.subVCView.frame
        self.recommendVC.view.frame = self.subVCView.frame
        self.favoriteVC.view.frame = self.subVCView.frame
        self.settingVC.view.frame = self.subVCView.frame
        
        self.headImageView.layer.cornerRadius = self.headImageView.w * 0.5
        self.headImageView.layer.masksToBounds = true
        self.headImageView.layer.borderColor = UIColor.whiteColor().CGColor
        self.headImageView.layer.borderWidth = 2.0
        
        var center = CGPoint(x: CGRectGetWidth(self.scrollView.frame) * 0.5, y: CGRectGetHeight(self.scrollView.frame) * 0.5)
        self.orderTradeVC.view.center = center
        
        center.x += ScreenWidth
        self.recommendVC.view.center = center
        
        center.x += ScreenWidth
        self.favoriteVC.view.center = center
        
        center.x += ScreenWidth
        self.settingVC.view.center = center

        self.scrollView.contentSize = CGSize(width: CGRectGetWidth(self.scrollView.frame) * 4, height: 0)
        

        self.orderTradeVC.scrolling = {
            
            [weak self](changePoint: CGPoint) in self?.topViewScrollerChangePoint(changePoint)
        }
        
        self.recommendVC.scrolling = {
            
            [weak self](changePoint: CGPoint) in self?.topViewScrollerChangePoint(changePoint)
        }
        
        self.favoriteVC.scrolling = {
            
            [weak self](changePoint: CGPoint) in self?.topViewScrollerChangePoint(changePoint)
        }
        
        self.settingVC.scrolling = {
            
            [weak self](changePoint: CGPoint) in self?.topViewScrollerChangePoint(changePoint)
        }
        
        
        self.orderTradeVC.resetScrollPoint = {
            
            [weak self](point: CGPoint) in self?.resetScrollerChangePoint(point)
        }
        
        self.recommendVC.resetScrollPoint = {
            
            [weak self](point: CGPoint) in self?.resetScrollerChangePoint(point)
        }
        
        self.favoriteVC.resetScrollPoint = {
            
            [weak self](point: CGPoint) in self?.resetScrollerChangePoint(point)
        }
        
        self.settingVC.resetScrollPoint = {
            
            [weak self](point: CGPoint) in self?.resetScrollerChangePoint(point)
        }
    }
    
    func prepareSubVC() {
        
        self.orderTradeVC = U02OrderTradeVC(nibName: "U02OrderTradeVC", bundle: NSBundle.mainBundle())
        self.orderTradeVC.userVC = self
        if(orderListDefaultModel != nil)
        {
            orderTradeVC.currType = self.orderListDefaultModel;
        }

        self.orderTradeVC.view.frame = self.scrollView.bounds
        self.scrollView.addSubview(self.orderTradeVC.view)

        self.recommendVC = U02RecommendVC(nibName: "U02RecommendVC", bundle: NSBundle.mainBundle())
        self.recommendVC.userVC = self
        self.scrollView.addSubview(self.recommendVC.view)
        
        self.favoriteVC = U02FavoriteVC(nibName: "U02FavoriteVC", bundle: NSBundle.mainBundle())
        self.favoriteVC.userVC = self
        self.scrollView.addSubview(self.favoriteVC.view)

        self.settingVC = U03SettingVC(nibName: "U03SettingVC", bundle: NSBundle.mainBundle())
        
        self.settingVC.userVC = self
        self.scrollView.addSubview(self.settingVC.view)
        
        self.adjustUI()
    }
    
    func topViewScrollerChangePoint(point: CGPoint) {
//        print("===>>:\(point.y + 300)")
        
        var changeY = point.y + 300
        if self.selectedBtn.tag == 500 { // order
            changeY += 75
        } else if self.selectedBtn.tag == 503 { // setting
            changeY += 5
        }
        
        var rect: CGRect = self.v_TopView.frame
        
        if changeY > 0 {
            
            rect.origin.y = -changeY
        } else {
        
            rect.origin.y = 0
        }
        self.v_TopView.frame = rect
    }
    
    func resetScrollerChangePoint(point: CGPoint) {
        
        var rect: CGRect = self.v_TopView.frame
        rect.origin.y = 0
        self.v_TopView.frame = rect
    }
}









