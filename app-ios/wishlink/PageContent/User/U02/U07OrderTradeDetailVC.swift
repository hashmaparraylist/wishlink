//
//  U07OrderTradeDetailVC.swift
//  wishlink
//
//  Created by whj on 15/10/27.
//  Copyright © 2015年 edonesoft. All rights reserved.
//

import UIKit

enum U07Role{
    case buyyer, seller
}
class U07OrderTradeDetailVC: RootVC, WebRequestDelegate {

    @IBOutlet weak var tradeIdLabel: UILabel!
    @IBOutlet weak var goodImageView: UIImageView!
    @IBOutlet weak var goodName: UILabel!
    @IBOutlet weak var goodFrom: UILabel!
    @IBOutlet weak var goodFormat: UILabel!
    @IBOutlet weak var goodPrice: UILabel!
    @IBOutlet weak var goodNumber: UILabel!
    @IBOutlet weak var goodTotal: UILabel!
    
    @IBOutlet weak var linkTitle: UILabel!
    @IBOutlet weak var avterImageView: UIImageView!
    @IBOutlet weak var personName: UILabel!
    @IBOutlet weak var orderTime: UILabel!
    @IBOutlet weak var linkButton: UIButton!
    
    @IBOutlet weak var reveicerName: UILabel!
    @IBOutlet weak var reveicerPhone: UILabel!
    @IBOutlet weak var reveicerAddress: UILabel!
    
    @IBOutlet weak var orderState: UILabel!
    @IBOutlet weak var orderReveicedTime: UILabel!
    @IBOutlet weak var revokeButton: UIButton!
    
    var role: U07Role!
    var trade: TradeModel!
    var receiver: ReceiverModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupData()
        self.setupView()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController!.navigationBar.hidden = false
    }
    
    func setupData() {
    
        self.httpObj.mydelegate = self
        self.httpObj.httpGetApi("trade/query", parameters: ["_id" : self.trade._id], tag: 700)
         SVProgressHUD.showWithStatusWithBlack("请稍等...")
        
        self.loadComNavTitle("订单详情")
        self.loadComNaviLeftBtn()
        self.loadSpecNaviRightTextBtn("投诉", _selecotr: "navigationRightButtonAction:")
    }
    
    func setupView() {
    
        self.avterImageView.layer.masksToBounds = true
        self.avterImageView.layer.cornerRadius = self.avterImageView.frame.size.height / 2
    }
    
    func initViewData() {
        
        let item = self.trade.item
        if (item.images != nil && item.images.count > 0) {
            self.goodImageView.image = UIImage(data: NSData(contentsOfURL: NSURL(string: self.trade.item.images[0])!)!)
        }
        self.tradeIdLabel.text = "订单号：\(item._id)"
        self.goodName.text = "品名：\(item.name)"
        self.goodFrom.text = "购买地：\(item.country)"
        self.goodFormat.text = "规格：\(item.spec)"
        self.goodPrice.text = "价格：￥\(item.price)/件"
        self.goodNumber.text = "数量：\(item.numTrades)"
        self.goodTotal.text = "合计：\(item.price * Float(self.trade.quantity))"
        
        self.linkTitle.text = self.role == .buyyer ? "买家信息" : "卖家信息"
        self.avterImageView.image = UIImage(data: NSData(contentsOfURL: NSURL(string: UserModel.shared.portrait)!)!)
        self.personName.text = "\(UserModel.shared.nickname)"
        self.orderTime.text = "接单：\(UserModel.shared.create)"
        
        if self.receiver != nil {
            self.reveicerName.text = "收货人：\(self.receiver.name)"
            self.reveicerPhone.text = "\(self.receiver.phone)"
            self.reveicerAddress.text = "收货地址：\(self.receiver.province + self.receiver.address)"
        }
        self.orderState.text = "\(self.trade.statusOrder)"
        self.orderReveicedTime.text = "接单时间：\(UserModel.shared.update)"
        
        self.revokeButton.setTitle("我要撤单", forState: UIControlState.Normal)
    }
    
    // MARK: - Action
    
    func navigationRightButtonAction(sender: UIButton) {
    
        let vc = T08ComplaintVC(nibName: "T08ComplaintVC", bundle: NSBundle.mainBundle())
        vc.tradeid = self.trade._id;
        self.presentViewController(vc, animated: true, completion: nil);
    }
    
    @IBAction func linkPersonButtonAction(sender: UIButton) {
        
        let vc = T09ComplaintStatusVC(nibName: "T09ComplaintStatusVC", bundle: NSBundle.mainBundle())
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    @IBAction func revokeButtonAction(sender: UIButton) {
    
        var url: String = ""
        var tag: Int = 700
        if self.role == .buyyer {
            if self.trade.statusOrder == .a0 {
                
                url = "trade/cancel"
                tag = 701
            } else if self.trade.statusOrder == .b0 {
                
                url = "trade/receipt"
                tag = 702
            } else if self.trade.statusOrder == .c0 {
            } else if self.trade.statusOrder == .d0 {
            }
        } else {
            if self.trade.statusOrder == .a0 {
                
                url = "trade/unassign"
                tag = 705
            } else if self.trade.statusOrder == .b0 {
            } else if self.trade.statusOrder == .c0 {
            } else if self.trade.statusOrder == .d0 {
            }
        }
        self.httpObj.httpGetApi(url, parameters: ["_id" : self.trade._id], tag: tag)
        SVProgressHUD.showWithStatusWithBlack("请稍等...")
        
    }
    
    // MARK: - WebRequestDelegate
    
    func requestDataComplete(response: AnyObject, tag: Int) {
        
        if (tag == 700) {
            let tradeData = (response as! NSDictionary).objectForKey("trade")
            if tradeData != nil {
                self.trade = TradeModel(dict: tradeData as! NSDictionary)
                
                let assigneeRef = (tradeData as! NSDictionary).objectForKey("assigneeRef")
                if assigneeRef != nil {
                    let result = UserModel.shared.receiversArray.filter{itemObj -> Bool in
                        return (itemObj as ReceiverModel).isDefault == true;
                    }
                    
                    if(result.count>0) {
                        
                        self.receiver = result[0] as ReceiverModel
                    }
                }
            }
            self.initViewData()
        } else {
        
            self.navigationController?.popViewControllerAnimated(true)
        }
        
        SVProgressHUD.dismiss();
    }
    
    func requestDataFailed(error: String) {
     
        SVProgressHUD.showErrorWithStatusWithBlack(error);
    }

}