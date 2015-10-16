//
//  WebRequestHelper.swift
//  landi-app
//
//  Created by Andy Chen on 6/24/15.
//  Copyright (c) 2015 edonesoft. All rights reserved.
//
import Foundation
@objc protocol WebRequestDelegate  {
    
    func requestDataComplete(response:AnyObject,tag:Int)
    func requestDataFailed(error:String)
    optional func complateImgDownload(tag:Int,downloadImg:UIImage)
}

import UIKit

let SERVICE_ROOT_PATH = "http://121.41.162.102/services/"

class WebRequestHelper:NSObject {
    
     weak var mydelegate:WebRequestDelegate?
    
    let headers = [
        "Content-Type": "application/json;charset=utf-8",
//        "Cookie": APPCONFIG.cookieStr
    ];
    
    /*
    执行一个Post方式的Http请求
    */
    func httpPostApi(apiName:String,parameters: [String: AnyObject]? = nil,tag:Int) {
        
        let apiurl = SERVICE_ROOT_PATH + apiName
        NSLog(" request(POST) url: %@", apiurl)
        
        request(.POST, apiurl, parameters: parameters, encoding: .JSON, headers: self.headers)
            .responseJSON{ request, Response, result in
                debugPrint(result)
                
                switch result {
                case .Success:
                    self.handleHttpResponse(result.value!, tag: tag)
                case .Failure(_, let error):
                    self.mydelegate?.requestDataFailed("网络不给力哦");
                    print(error)
                }
        }
    }
    
    func httpGetApi(apiName:String,parameters: [String: AnyObject]? = nil,tag:Int) {
        
        let apiurl = SERVICE_ROOT_PATH + apiName
        NSLog("request url: %@", apiurl)
        
            request(.GET, apiurl, parameters: parameters, encoding: .URL, headers: self.headers)
                .responseJSON{ _, respore, result in
                switch result {
                case .Success:
                    self.handleHttpResponse(result.value!, tag: tag)
                case .Failure(_, let error):
                    self.mydelegate?.requestDataFailed("网络不给力哦");
                    print(error)
                }
        }
    }
    
    /*
    请求成功后，解析结果JSON公共部分
    
    */
    func handleHttpResponse(body:AnyObject,tag:Int) {

        let dataDir:NSDictionary = body as! NSDictionary
        
        if( dataDir.objectForKey("data") != nil)
        {
            self.mydelegate?.requestDataComplete(dataDir.objectForKey("data")!, tag: tag);
            
        }
        else
        {
            //解析metadata
            var errorMsg = "返回数据无效";
            let metaDic = dataDir.objectForKey("metadata")  as! NSDictionary
            if(metaDic.count>0)
            {
//                var errCode = metaDic.objectForKey("error");
                let errDic = metaDic.objectForKey("devInfo") as! NSDictionary;
                if(errDic.count>0)
                {
                    let errCode =  errDic.objectForKey("errorCode") as! Int;
                    let errDesc =  errDic.objectForKey("description") as! String;
                    errorMsg = "ErrorCode:\(errCode) \(errDesc)";
                }
                self.mydelegate?.requestDataFailed(errorMsg)
            }else {
                self.mydelegate?.requestDataComplete(dataDir, tag: tag)
            }
            
        }
    }
    
    
    /*
    下载网络图片并加载ImageView中，
    仅第一次下载，第二次开始读区缓存
    
    参数：
    iv:显示下载后图片的UIimageView
    url:图片的url
    defaultName：如果下载失败，则所加载的默认图片名称
    
    */
    func renderImageView(iv:UIImageView,url:String,defaultName:String)
    {
        if(url != "" && url.trim().length>0)
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                
                autoreleasepool({ () -> () in
                    
                    
                    let  encodeName = url.stringByReplacingOccurrencesOfString("/", withString: "_", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
                    //判断文件路径是否存在，不存在则创建
                    var imagepath:String = UIHEPLER.getCachedFilePath("cachedimages");
                    
                    let fm:NSFileManager = NSFileManager.defaultManager();
                    if(!fm.fileExistsAtPath(imagepath))
                    {
                        do {
                            try fm.createDirectoryAtPath(imagepath, withIntermediateDirectories: true, attributes: nil)
                        } catch _ {
                        }
                    }
                    //检测本读是否有该图片缓存
                    
                    imagepath = imagepath+"/"+encodeName
                    
                    if(fm.fileExistsAtPath(imagepath))
                    {
                        
                        let imageData:NSData = NSData(contentsOfFile: imagepath)!
                        let image = UIImage(data: imageData);
                        if (image != nil) {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                iv.image = image;
                            })
                            return;
                        }
                        
                    }                    
                    request(.GET, url).response(){
                        
                        (_, _, data, error) in
                        
                        if(error == nil)
                        {
                            let image = UIImage(data: data! as NSData)
                            NSLog("Write to file:%@", imagepath);
                            data!.writeToFile(imagepath, atomically: true);
                            //显示图片
                            if (image != nil) {
                                iv.image = image;
                            } else {
                                iv.image = UIHEPLER.getBundledImage(defaultName)
                            }
                            
                        }
                        else
                        {
                            iv.image = UIImage(named: defaultName)
                            print(error)
                        }
                        
                        
                    }
                    
                })
            })
        }
    }
}
