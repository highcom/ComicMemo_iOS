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
    var myItems: NSMutableArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // データ読み込み
        readMemoData()
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
    }
    
    // 巻数追加ボタン
    @IBAction func tapNumAdd(sender: AnyObject) {
        // タップされたボタンのtableviewの選択行を取得
        var btn = sender as! UIButton
        var cell = btn.superview?.superview as! UITableViewCell
        var row = tableView.indexPathForCell(cell)?.row

        // 選択行に対するデータを取得
        var item = myItems[row!] as! ComicMemo.Entity
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
        var myItem = myItems[indexPath.row] as! ComicMemo.Entity
        
        // tag1(タイトル)を取得
        var titleText = cell.viewWithTag(1) as! UILabel
        titleText.text = myItem.getTitle()
        
        // tag2(メモ)を取得
        var memoText = cell.viewWithTag(2) as! UILabel
        memoText.text = myItem.getMemo()
        
        // tag3(巻数)を取得
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
            
            // TODO: CoreDataからもデータを削除する
            
            // TableViewを再読み込み.
            tableView.reloadData()
        }
    }

    // infoボタンイベント
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        // TODO: 入力されているデータを渡す
        // 詳細画面へ遷移する
        self.performSegueWithIdentifier("detailViewSegue", sender: nil)
    }
    
    // 並べ替えをできるようにする
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        // TODO: 並べ替えたら、その順番でCoreDataに保存する処理
    }
    
    // 検索バー入力イベント
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        // TODO: 検索バーで入力された文字列をCoreDataから検索
        // テキストが変更される毎に呼ばれる
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
        
        // 詳細画面で入力したデータを追加
        writeMemoData(titleName, author: authorName, publisher: publisherName, number: numberOfBooks, memo: memo)

        // データの再読込
        readMemoData()
        // TableViewを再読み込み.
        tableView.reloadData()
    }
    
    // CoreDataのへの書き込み
    func writeMemoData(title: String, author: String, publisher: String, number: Int, memo: String){
        // CoreDataへの書き込み処理
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
    
    // CoreDataからの読み込み
    func readMemoData(){
        // CoreDataの読み込み処理
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let myContext: NSManagedObjectContext = appDel.managedObjectContext!
        
        let myRequest: NSFetchRequest = NSFetchRequest(entityName: "Entity")
        myRequest.returnsObjectsAsFaults = false
        
        var myResults: NSArray! = myContext.executeFetchRequest(myRequest, error: nil)
        
        myItems = []
        for myData in myResults {
            myItems.addObject(myData)
        }
    }
}
