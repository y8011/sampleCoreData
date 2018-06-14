//
//  ViewController.swift
//  sampleCoreData
//
//  Created by yuka on 2018/06/11.
//  Copyright © 2018年 yuka. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController
,UITableViewDataSource
,UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sweetMemoryList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        let dic = sweetMemoryList[indexPath.row]
        print(#function,sweetMemoryList[indexPath.row])
        cell.textLabel?.text = dic["place"] as! String
        
        return cell
    }
    
    // スワイプして一行削除
    // 実行する順番に注意！
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let dic = sweetMemoryList[indexPath.row]
            let place = dic["place"] as! String
            
            // CoreDataから削除
            deleteSweetMemory(place: place)

            // 表示用の配列の削除
            sweetMemoryList.remove(at: indexPath.row)
            
            // 行が消える
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
    }
    
    
    @IBOutlet weak var myTextField: UITextField!
    @IBOutlet weak var myTableView: UITableView!
    
    var sweetMemoryList:[NSDictionary] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        myTableView.delegate = self
        myTableView.dataSource = self
        
        // sqliteファイルを見るためにプリント
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        print(urls[urls.count-1] as URL)
        
        
        createSweetMemory(place: "204")
        
        readSweetMemory()
        print("sweetMemoryList:", sweetMemoryList)
        let dic = sweetMemoryList[0]
        print("みつい:",dic["place"] as! String)
        
        
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
                
                let dic = ["place":place , "date":date] as [String : Any]
                let dica = [place,date] as [Any]
                //  dica[0] がString(place), dica[1]がDate型(date)
                print(dic)
                sweetMemoryList.append(dic as NSDictionary)
            }
        } catch  {
            print("read error:",error)
        }
        
        
        
    }
    
    // readをコピーして作成
    // 引数に絞り込む用のStringを入れる
    func deleteSweetMemory(place:String) {
        // Read処理
        // AppDelegateのインスタンス化
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let manageContext = appDelegate.persistentContainer.viewContext
        
        // フェッチして取り出し（リクエストの準備）
        let fetchRequest:NSFetchRequest<SweetMemory> = SweetMemory.fetchRequest()
        
        // 絞り込み
        let predicate = NSPredicate(format: "place = %@", place)
        fetchRequest.predicate = predicate
        
        // 並び替え
//        let sortDescripter = NSSortDescriptor(key: "date", ascending: false) // true:昇順　false 降順
        
//        fetchRequest.sortDescriptors = [sortDescripter]
        
        do {
            
            // データ取得 配列で取得される
            let fetchResults = try manageContext.fetch(fetchRequest)
            
//            manageContext.delete(fetchResults.first!) 一行だけ削除するなら、この書き方でも良い
            
            for result in fetchResults {
                // １件ずつ取り出し
                let place:String? = result.value(forKey: "place") as? String
                let date:Date? = result.value(forKey: "date") as? Date
                
                print("place:\(place)","date:\(date)")
                
                manageContext.delete(result)  // 絞り込んだレコードを削除
                
//                 read処理で必要だった処理をコメントアウト
//                let dic = ["place":place , "date":date] as [String : Any]
//                let dica = [place,date] as [Any]
//                //  dica[0] がString(place), dica[1]がDate型(date)
//                print(dic)
//                sweetMemoryList.append(dic as NSDictionary)
                
            }
            try manageContext.save()  // 削除した状態を保存
            
        } catch  {
            print("read error:",error)
        }
        
        
        
    }
    
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

