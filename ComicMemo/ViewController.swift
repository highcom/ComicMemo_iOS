//
//  ViewController.swift
//  ComicMemo
//
//  Created by 晃一 on 2015/07/12.
//  Copyright (c) 2015年 晃一. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var one = myItemsData(ptitlename: "ワンピース", pnum: 78)
    var two = myItemsData(ptitlename: "BREACH", pnum: 33)
    var three = myItemsData(ptitlename: "鋼の錬金術師", pnum: 9)
    var myItems: NSMutableArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        myItems.addObject(one)
        myItems.addObject(two)
        myItems.addObject(three)
    }
    
    // テーブルを追加する
    @IBAction func tapAdd(sender: AnyObject) {
        // データ入力のため詳細画面へ遷移する
        self.performSegueWithIdentifier("detailViewSegue", sender: nil)
    }
    
    // 編集モードにする
    @IBAction func tapEdit(sender: AnyObject) {
        if editing {
            super.setEditing(false, animated: true)
            tableView.setEditing(false, animated: true)
        } else {
            super.setEditing(true, animated: true)
            tableView.setEditing(true, animated: true)
        }

        // TODO:データ追加処理（仮）
        readData()
    }
    
    // 巻数追加ボタン
    @IBAction func tapNumAdd(sender: AnyObject) {
        // タップされたボタンのtableviewの選択行を取得
        var btn = sender as! UIButton
        var cell = btn.superview?.superview as! UITableViewCell
        var row = tableView.indexPathForCell(cell)?.row

        // 選択行に対するデータを取得
        var item :myItemsData = myItems[row!] as! myItemsData
        item.addNum()
        
        // TableViewを再読み込み.
        tableView.reloadData()
    }
    
    // 行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myItems.count
    }
    
    // セルの設定
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("memoCell") as! UITableViewCell
        
        // tag1を取得
        var titleText = cell.viewWithTag(1) as! UILabel
        var myItem :myItemsData = myItems[indexPath.row] as! myItemsData
        titleText.text = myItem.getTitle()
        
        // tag2を取得
        var num = cell.viewWithTag(3) as! UILabel
        num.text = myItem.getNum().description
        
        return cell
    }

    // Cellを挿入または削除しようとした際に呼び出される
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        // 削除のとき.
        if editingStyle == UITableViewCellEditingStyle.Delete {
            // 指定されたセルのオブジェクトをmyItemsから削除する.
            myItems.removeObjectAtIndex(indexPath.row)
            
            // TableViewを再読み込み.
            tableView.reloadData()
        }
    }

    // 詳細画面へ遷移する
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("detailViewSegue", sender: nil)
    }
    
    // 並べ替えをできるようにする
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        
    }
    
    // テキストが変更される毎に呼ばれる
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        println(searchText)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 詳細画面のキャンセルボタン
    @IBAction func cancelButton(segue: UIStoryboardSegue) {
        
    }
    
    // 詳細画面の完了ボタン
    @IBAction func doneButton(segue: UIStoryboardSegue) {
        let detailData = segue.sourceViewController as! DetailViewController
        // 詳細画面の入力データを受け取る
        var titleName = detailData.titleField.text
        var authorName = detailData.authorField.text
        var publisherName = detailData.publisherField.text
        var numberOfBooks = detailData.numberOfBooksField.text.toInt()!
        var memo = detailData.memoTextView.text
        
        // myItemsに追加.
        var newItem = myItemsData(ptitlename: "タイトルを入力", pnum: 0)
        myItems.addObject(newItem)
        
        // TableViewを再読み込み.
        tableView.reloadData()
        
        // TODO:データ追加処理（仮）
        writeData(titleName, author: authorName, publisher: publisherName, number: numberOfBooks, memo: memo)

    }
    
    // TODO:CoreDataの書き込み
    func writeData(title: String, author: String, publisher: String, number: Int, memo: String){
        // CoreDataへの書き込み処理.
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let myContext: NSManagedObjectContext = appDel.managedObjectContext!
        
        let myEntity: NSEntityDescription! = NSEntityDescription.entityForName("Entity", inManagedObjectContext: myContext)
        
        var newData = Entity(entity: myEntity, insertIntoManagedObjectContext: myContext)
        newData.titleName = title
        newData.authorName = author
        newData.publisherName = publisher
        newData.numberOfBooks = number
        newData.memo = memo
        
        myContext.save(nil)
    }
    
    // TODO:CoreDataからの読み込み
    func readData(){
        // CoreDataの読み込み処理.
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let myContext: NSManagedObjectContext = appDel.managedObjectContext!
        
        let myRequest: NSFetchRequest = NSFetchRequest(entityName: "Entity")
        myRequest.returnsObjectsAsFaults = false
        
        var myResults: NSArray! = myContext.executeFetchRequest(myRequest, error: nil)
        
        var _myItems: NSMutableArray = []
        
        for myData in myResults {
            _myItems.addObject(myData)
        }
//        データを読み込んだらリロード
//        myTableView.reloadData()
    }
}

// タイトル名と巻数を保持するクラス
class myItemsData {
    private var titlename:String
    private var num:Int
    
    // コンストラクタ
    init(ptitlename:String, pnum:Int)
    {
        titlename = ptitlename
        num = pnum
    }
    
    // タイトル名を取得
    func getTitle() -> String {
        return titlename
    }
    
    // 巻数を取得
    func getNum() -> Int {
        return num
    }
    
    // 巻数を追加
    func addNum() {
        num++
    }
}