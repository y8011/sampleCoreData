//
//  ViewController.swift
//  sampleCoreData
//
//  Created by yuka on 2018/06/11.
//  Copyright © 2018年 yuka. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // sqliteファイルを見るためにプリント
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        print(urls[urls.count-1] as URL)
        

        createSweetMemory(place: "オスロブ")
        
        readSweetMemory()
        
    }

    func createSweetMemory(place:String) {
        // Create処理
        // AppDelegateのインスタンス化
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let manageContext = appDelegate.persistentContainer.viewContext
        
        // エンティティ
        let sweetMemory = NSEntityDescription.entity(forEntityName: "SweetMemory", in:manageContext)
        
        // contextに１レコード追加
        let newRecord = NSManagedObject(entity: sweetMemory!, insertInto: manageContext)
        
        // レコードに値の設定
        newRecord.setValue(place, forKey: "place")
        newRecord.setValue(Date(), forKey: "date")
        
        do {
            try manageContext.save()  // throw はdocatchとセットで使う
        } catch  {
            // errorが出たらこちらに来る
            print("error:",error)
            
        }
        
    }
    
    func readSweetMemory() {
        // Read処理
        // AppDelegateのインスタンス化
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let manageContext = appDelegate.persistentContainer.viewContext

        // フェッチして取り出し（リクエストの準備）
        let fetchRequest:NSFetchRequest<SweetMemory> = SweetMemory.fetchRequest()
        
        // 絞り込み
//        let predicate = NSPredicate(format: "place = %@", "Cebu")
//        fetchRequest.predicate = predicate
        
        // 並び替え
        let sortDescripter = NSSortDescriptor(key: "date", ascending: false) // true:昇順　false 降順
        
        fetchRequest.sortDescriptors = [sortDescripter]
        
        do {
            
            // データ取得 配列で取得される
            let fetchResults = try manageContext.fetch(fetchRequest)
            
            for result in fetchResults {
                // １件ずつ取り出し
                let place:String? = result.value(forKey: "place") as? String
                let date:Date? = result.value(forKey: "date") as? Date
                
                print("place:\(place)","date:\(date)")
            }
        } catch  {
            print("read error:",error)
        }
        
        
        
    }
    
    
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

