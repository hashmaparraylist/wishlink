//
//  TradeTableViewCellHeader.swift
//  wishlink
//
//  Created by whj on 15/8/19.
//  Copyright (c) 2015年 edonesoft. All rights reserved.
//

import UIKit

protocol T06CellHeaderDelegate: NSObjectProtocol {

    func dorpListButtonAction(sender: UIButton)
    func btnFollowAction(sender: UIButton)
}

class T06CellHeader: UITableViewCell, CSDorpListViewDelegate {

    @IBOutlet weak var lbTotalCount: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productTotalLabel: UILabel!
    @IBOutlet weak var productNumberLabel: UILabel!
    @IBOutlet weak var productFormatLabel: UILabel!
    @IBOutlet weak var productMessageLabel: UILabel!
    @IBOutlet weak var iv_notes: UIImageView!
    
    @IBOutlet weak var btnDorp: UIButton!
    @IBOutlet weak var btnFlow: UIButton!
    @IBOutlet weak var imageRollView: CSImageRollView!
    
    var dorpListView: CSDorpListView!
    
    weak var delegate: T06CellHeaderDelegate?
    var item: ItemModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let titles: NSArray = ["选择同城0","选择同城1","选择同城2"]
        dorpListView = CSDorpListView.sharedInstance
        dorpListView.bindWithList(titles, delegate: self)

        // clear
        self.titleLabel.text  = ""
        self.productNameLabel.text  = ""
        self.productPriceLabel.text  = ""
        self.productTotalLabel.text  = ""
        self.productNumberLabel.text  = ""
        self.productFormatLabel.text  = ""
        self.productMessageLabel.text  = ""
    }
    deinit{
        
        NSLog("T06CellHeader -->deinit")
        if( self.imageRollView != nil)
        {
            self.imageRollView.removeFromSuperview();
            self.imageRollView = nil;
        }
        if( self.dorpListView != nil)
        {
//            CSDorpListView.sharedInstance.removeFromSuperview();
            self.dorpListView.removeFromSuperview();
            self.dorpListView = nil;
        }
        if(self.delegate != nil )
        {
            self.delegate = nil;
        }
        if(self.item != nil )
        {
            self.item = nil;
        }
        
    }
    
    func initImageRollView(images:[UIImage]) {

        imageRollView.initWithImages(images)
        imageRollView.setcurrentPageIndicatorTintColor(UIColor.grayColor())
        imageRollView.setpageIndicatorTintColor(UIColor(red: 124.0 / 255.0, green: 0, blue: 90.0 / 255.0, alpha: 1))
    }
    
    func initData(item: ItemModel) {
        self.item = item;
        self.titleLabel.text  = item.brand
        self.productNameLabel.text  = "品名：" + item.name
        self.productPriceLabel.text  = "\(item.price)"
        var totalPrice:Float = item.price
        if(item.numTrades != nil && item.numTrades>0)
        {
            totalPrice = item.price * Float(item.numTrades)
        }
        self.productTotalLabel.text = totalPrice.format(".2")
        self.productNumberLabel.text  = "\(item.numTrades)件"
        self.productFormatLabel.text  = item.spec
        self.productMessageLabel.text  = item.notes
        if(self.productMessageLabel.text?.trim().length>0)
        {
            self.iv_notes.hidden = false;
        }
        else
        {
            self.iv_notes.hidden = true;
        }
        
        self.lbTotalCount.text = "\(item.numTrades)件"
        if (item.images == nil) {return}
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            var images: [UIImage] = [UIImage]()
            for imageUrl in item.images {
                let url: NSURL = NSURL(string: imageUrl)!
                let image: UIImage = UIImage(data: NSData(contentsOfURL: url)!)!
                images.append(image)
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.initImageRollView(images)
            })
        })
    }
    
    //MARK: - Action
    
    @IBAction func btnFollowAction(sender: UIButton) {
        delegate?.btnFollowAction(sender)
    }
    
    @IBAction func dorpListButtonAction(sender: UIButton) {
        
//        delegate?.dorpListButtonAction(sender)
    
        dorpListView.show(sender)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: - CSDorpListViewDelegate
    
    func dorpListButtonItemAction(sender: UIButton!) {
        
        btnDorp.setTitle(sender.titleLabel?.text, forState: UIControlState.Normal)
    }
}
