//
//  TradeTableViewCell.swift
//  wishlink
//
//  Created by whj on 15/8/19.
//  Copyright (c) 2015年 edonesoft. All rights reserved.
//

import UIKit

@objc protocol T06CellDelegate
{
    //选中项发生更改的时候
    func selectItemChange(trade:TradeModel,isSelected:Bool);
}

class T06Cell: UITableViewCell {

    @IBOutlet weak var selectedButton: UIButton!
    
    @IBOutlet weak var lbCount: UILabel!
    @IBOutlet weak var lbCountry: UILabel!
    
    @IBOutlet weak var iv_userImg: UIImageView!
    @IBOutlet weak var lbUserName: UILabel!
    @IBOutlet weak var lbTotalFree: UILabel!
    
    var myDelegate:T06CellDelegate!
    var trade:TradeModel!
    var item:ItemModel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func selectedButtonAction(sender: UIButton) {
        
        sender.selected = !sender.selected
        
        if(self.myDelegate != nil)
        {
            self.myDelegate!.selectItemChange(self.trade, isSelected: sender.selected);
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    //TODO:缺少用户信息绑定
    func loadData(trade:TradeModel! , item:ItemModel)
    {
        self.trade = trade;
        self.item = item;
        self.lbCount.text = item.price.format(".2") + " * " + String(trade.quantity)
        self.lbCountry.text = item.country;
        
        
        var totalPrice:Float = item.price
        if(item.numTrades != nil && item.numTrades>0)
        {
            totalPrice = item.price * Float(trade.quantity)
        }
        self.lbTotalFree.text = totalPrice.format(".2")
        if(self.trade != nil)
        {
            let dic:NSDictionary! = self.trade.ownerRef
            if(dic != nil && dic.count>0)
            {
                self.lbUserName.text = ""
                self.iv_userImg.image = nil;
                let name:String! = dic.objectForKey("nickname") as? String
                let imgUrl:String! = dic.objectForKey("portrait") as? String
                if(name != nil)
                {
                    self.lbUserName.text = name;
                }
                if(imgUrl != nil && imgUrl.trim().length>1)
                {
                    WebRequestHelper().renderImageView(self.iv_userImg, url: imgUrl, defaultName: "T03aaa")
                    UIHEPLER.buildImageViewWithRadius(self.iv_userImg, borderColor: UIHEPLER.mainColor, borderWidth: 1);
                    
                }
            }
        }

        
    }
    deinit
    {
        trade = nil;
        item = nil;
    }
    
}
