//
//  TodayViewController.swift
//  TemperatureMAp
//
//  Created by Jim on 2018/7/31.
//  Copyright © 2018年 Jim. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var mainImageView: UIImageView!
    
    
    @IBAction func launchBtPressed(_ sender: UIButton) {
        
                                            // 送參數 到要開的url 主程式（其他app也可）
        guard let url = URL(string: "cp105Map://banana") else {
            assertionFailure("Invalid URL Schme")
            return  }
        
        self.extensionContext?.open(url, completionHandler: { (result) in //只能回傳 1/0
            //...
        })
        
    }
    
    @IBAction func refreshBtPressed(_ sender: UIButton) {
        
        doRefresh(completionHandler: nil)
    }
    
    func doRefresh(completionHandler:  ( (NCUpdateResult) -> Void)? )  {
        
        let urlString = "https://www.cwb.gov.tw/V7/observe/temperature/Data/temp.jpg"
        
        guard let url = URL(string: urlString) else {
            assertionFailure("Invalid url")
            completionHandler?(.failed)     //？如果是nil 整串會回傳nil
            //如果是nil 不回傳    不是就回傳一個  failed
            return  }
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: url) { (data, respone, error) in
            //..
            if let error = error{
                print("Download fail \(error)")
                completionHandler?(.failed)
            }
            guard let data = data else{
                assertionFailure("data is nil")
                completionHandler?(.failed)
                return
            }
            let image = UIImage(data: data)
            DispatchQueue.main.async {
                self.mainImageView.image = image
            }
            completionHandler?(.newData)        // 加密ＭＤ5
        }
        task.resume()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //extensionContext 專門給app ex.. 用的app delegate
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        
        if activeDisplayMode == .compact {
            self.preferredContentSize = CGSize.zero //這邊很怪 有設置就能正常 不管設定多小
        } else {//.expended
            self.preferredContentSize = CGSize(width: 320, height: 320)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //這邊可以放置內容刷新的程式碼        要放置舊的 但不希望太舊 背景會刷新 至最新的
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        //本質是機器學習 來看更新資料的頻率
        
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        doRefresh(completionHandler: completionHandler)
        
//        completionHandler(NCUpdateResult.newData)//回報更新內容
    }
    
}
