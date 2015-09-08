//
//  U02ItemCell.swift
//  wishlink
//
//  Created by Yue Huang on 8/18/15.
//  Copyright (c) 2015 edonesoft. All rights reserved.
//

import UIKit

enum ItemCellType {
    case Recommand, Favorite
}

enum ItemCellButtonClickType {
    case Favorite, Delete
}


protocol U02ItemCellDelegate: NSObjectProtocol {
    func itemCell(cell: U02ItemCell, clickType: ItemCellButtonClickType)
}

class U02ItemCell: UICollectionViewCell {

    @IBOutlet weak var favoriteBtn: UIButton!
    
    var indexPath: NSIndexPath!
    
    var closure: ((ItemCellButtonClickType, NSIndexPath) -> ())?
    
    var cellType: ItemCellType = .Recommand {
        didSet {
            if cellType == .Recommand {
                favoriteBtn.hidden = false
            }
            else {
                favoriteBtn.hidden = true
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.layer.borderWidth = 1
    }
    @IBAction func favoriteBtnAction(sender: AnyObject) {
        var btn = sender as! UIButton
        btn.selected = !btn.selected
        if let c = self.closure {
            c(ItemCellButtonClickType.Favorite, self.indexPath)
//            c(self.indexPath, ItemCellType.Favorite)
        }
    }
    @IBAction func deleteBtnAction(sender: AnyObject) {
        if let c = self.closure {
            c(ItemCellButtonClickType.Delete, self.indexPath)
            //            c(self.indexPath, ItemCellType.Favorite)
        }
    }
    
    
    
    
}
