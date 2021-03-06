//
//  T13AssignToMeVC.swift
//  wishlink
//
//  Created by whj on 15/8/16.
//  Copyright (c) 2015年 edonesoft. All rights reserved.
//

import UIKit

class T13AssignToMeVC: RootVC, UITableViewDelegate,UITableViewDataSource,  T06CellFooterDelegate,T06CellDelegate,T13CellHeaderDelegate, WebRequestDelegate {
    
    let cellIdentifier = "T06Cell"
    let cellIdentifierHeader = "T13CellHeader"
    let cellIdentifierFooter = "T06CellFooter"
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet var tradeTableView: UITableView!
    @IBOutlet weak var btnGetOrder: UIButton!

    var item: ItemModel!
    var trade:TradeModel!
    //跟单列表
    var followArr:[TradeModel]! = []
    //选中的抢单列表
    var selectArr:[TradeModel]! = []
    
    
    //MARK:Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.httpObj.mydelegate = self;
        
        SVProgressHUD.showWithStatusWithBlack("请稍等...")
        
        self.tradeTableView.registerNib(UINib(nibName: cellIdentifier, bundle: NSBundle.mainBundle()), forCellReuseIdentifier: cellIdentifier)
        self.tradeTableView.registerNib(UINib(nibName: cellIdentifierHeader, bundle: NSBundle.mainBundle()), forCellReuseIdentifier: cellIdentifierHeader)
        self.tradeTableView.registerNib(UINib(nibName: cellIdentifierFooter, bundle: NSBundle.mainBundle()), forCellReuseIdentifier: cellIdentifierFooter)
        
        self.btnGetOrder.hidden = true;
        self.httpObj.httpGetApi("tradeFeeding/byItem?_id="+self.item._id, parameters: nil, tag: 60)
        self.navigationController?.navigationBarHidden = false;
        
        self.loadComNaviLeftBtn()
        self.loadComNavTitle("抢单列表")
        self.tradeTableView.separatorStyle = UITableViewCellSeparatorStyle.None;
        
        self.clearFootView(tradeTableView);
    }
    func clearFootView(tableView:UITableView)
    {
        let footView = UIView();
        tableView.tableFooterView = footView;
    }
    
    
    deinit{
        
        NSLog("T06TradeVC -->deinit")
        self.item = nil;
        self.tradeTableView = nil;
        if(self.httpObj != nil)
        {
            self.httpObj.mydelegate = nil;
        }
        
        self.dataArr = nil;
        
        self.followArr = nil;
        self.selectArr = nil;
        //        userImage = nil;
    }
    
    override func viewDidLayoutSubviews() {
        self.tradeTableView.layoutIfNeeded();
        self.view.layoutIfNeeded();
    }
    
    //MARK:UITableView Delegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        
//        let last: Int = followArr.count + 1
        
        switch indexPath.row {
        case 0:
            return 195
        default :
            return 90
        }
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return followArr.count+1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell
//        let last: Int = followArr.count;// + 2 - 1
        
        
        switch indexPath.row {
        case 0:
            let  tCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifierHeader, forIndexPath: indexPath) as! T13CellHeader
            tCell.awakeFromNib();
            tCell.myDelegate = self
            tCell.loadData(self.item,_trade: self.trade);
            
            cell = tCell;
            //        case last:
            //            let  fcell = tableView.dequeueReusableCellWithIdentifier(cellIdentifierFooter, forIndexPath: indexPath) as! T06CellFooter
            //            fcell.delegate = self
            //
            //
            //
            //            cell = fcell;
        default:
            let  tCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! T06Cell
            tCell.awakeFromNib()
            let tdata = followArr[indexPath.row - 1]
            
            tCell.loadData(tdata,item:self.item);
            tCell.selectedButton.selected = false;
            if(self.selectArr != nil && self.selectArr.count>0)
            {
                for selectItem in self.selectArr
                {
                    if(selectItem._id == tdata._id)
                    {
                        tCell.selectedButton.selected = true;
                        break;
                    }
                }
            }
            
            tCell.iv_userImg.image = nil;
            let imgUrl :String! =   tdata.owner!.objectForKey("portrait") as? String
            WebRequestHelper().renderImageView( tCell.iv_userImg, url: imgUrl, defaultName: "T03aaa")
            
            tCell.myDelegate = self;
            cell = tCell;
            
        }
        
        return cell
    }
    
    func t13CellHeaderSelectItemChange(selectTrade:TradeModel,isSelected:Bool)
    {
        if(isSelected)//insert
        {
            self.selectArr.append(selectTrade);
        }
        else//remove
        {
            if(self.selectArr.count>0)
            {
                var index = 0;
                for tradeObj in self.selectArr
                {
                    if(tradeObj._id == selectTrade._id)
                    {
                        break;
                    }
                    index+=1;
                }
                self.selectArr.removeAtIndex(index);
            }
            
        }
        
    }
    func selectItemChange(selectTrade:TradeModel,isSelected:Bool)
    {
        if(isSelected)//insert
        {
            self.selectArr.append(selectTrade);
        }
        else//remove
        {
            if(self.selectArr.count>0)
            {
                var index = 0;
                for tradeObj in self.selectArr
                {
                    if(tradeObj._id == selectTrade._id)
                    {
                        break;
                    }
                    index+=1;
                }
                if(self.selectArr.count>index)
                {
                    self.selectArr.removeAtIndex(index);
                }
            }
            
        }
    }
    //MARK: - IBAction
    @IBAction func btnGetOrderAction(sender: AnyObject) {
        self.btnGrabOrderAction((sender as? UIButton)!);
    }
    
    //抢单
    func btnGrabOrderAction(sernder:UIButton) {
        
        if(self.selectArr != nil && self.selectArr.count>0)
        {
            
            var vc:T14AssignToMeConfirm! = T14AssignToMeConfirm(nibName: "T14AssignToMeConfirm", bundle: NSBundle.mainBundle());
            
            vc.item = self.item;
            vc.followArr = self.selectArr;
            vc.selectArr = self.selectArr;
            
            vc.selectItemRemove = {[weak self](_trade) in
                
                if(self!.selectArr.count>0)
                {
                    var index = 0;
                    for tradeObj in self!.selectArr
                    {
                        if(tradeObj._id == _trade._id)
                        {
                            break;
                        }
                        index+=1;
                    }
                    self!.selectArr.removeAtIndex(index);
                }
                
            }
            vc.reSelectEvent = {() in
                
                self.tradeTableView.reloadData();
            }
            self.navigationController?.pushViewController(vc, animated: true);
//            self.presentViewController(vc, animated: true, completion: nil);
            vc = nil;
            
        }
        else
        {
            UIHEPLER.alertErrMsg("请至少选择一个订单");
        }
    }
    
    //MARK: - T06CellHeaderDelegate
    func dorpListButtonAction(sender: UIButton) {
        
    }
    //MARK: - T06CellFooterDelegate
    func grabOrderButtonAction(sender: UIButton) {
        
        SVProgressHUD.showWithStatusWithBlack("请稍后...")
        self.httpObj.httpPostApi("trade/assignToMe", tag: 61)
        
    }
    
    //MARK: - Request delegate
    func requestDataComplete(response: AnyObject, tag: Int) {
        
        SVProgressHUD.dismiss();
        if(tag == 60)
        {
            let tradesObj:NSArray! = (response as? NSDictionary)?.objectForKey("trades") as? NSArray
            print(tradesObj);
            if(tradesObj != nil && tradesObj!.count>0)
            {
                if(followArr != nil && followArr.count>0)
                {
                    self.followArr.removeAll();
                }
                for  itemObj in tradesObj!
                {
                    let tradeItem = TradeModel(dict: itemObj as! NSDictionary);
//                    if(tradeItem.item != nil && tradeItem._id == self.trade._id)//remove soma trade
//                    {
//                        //self.trade = tradeItem
//                    }
//                    else
//                    {
                        self.followArr.append(tradeItem);
//                    }
                }
                //                self.loadAllUserImage();
                self.tradeTableView.reloadData();
            }
            self.btnGetOrder.hidden = false;
            
        } else if(tag == 61) {
            
            UIHEPLER.gotoU02Page(false);
            
        } else if(tag == 62) {//跟单成功转向支付页面
            
            let dic = response as! NSDictionary;
            let tradeDic = dic.objectForKey("trade") as!  NSDictionary;
            let tradeItem = TradeModel(dict: tradeDic);
            
            var t05VC:T05PayVC! = T05PayVC(nibName: "T05PayVC", bundle: NSBundle.mainBundle());
            
            t05VC.item = self.item;
            t05VC.trade = tradeItem;
            t05VC.isNewOrder = false;
            self.navigationController?.pushViewController(t05VC, animated: true);
            t05VC = nil;
            
        }
    }
    
    func requestDataFailed(error: String,tag:Int) {
        
        SVProgressHUD.showErrorWithStatusWithBlack(error);
    }
    
}
