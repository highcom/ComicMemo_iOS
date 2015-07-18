//
//  ViewController.swift
//  ComicMemo
//
//  Created by 晃一 on 2015/07/12.
//  Copyright (c) 2015年 晃一. All rights reserved.
//

import UIKit

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
        // myItemsに追加.
        var newItem = myItemsData(ptitlename: "タイトルを入力", pnum: 0)
        myItems.addObject(newItem)

        // TableViewを再読み込み.
        tableView.reloadData()
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
        var titleText = cell.viewWithTag(1) as! UITextField
        var myItem :myItemsData = myItems[indexPath.row] as! myItemsData
        titleText.text = myItem.getTitle()
        
        // tag2を取得
        var num = cell.viewWithTag(2) as! UITextField
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

    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("detailViewSegue", sender: nil)
    }
    
    // 並べ替えをできるようにする
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func returnMenu(segue: UIStoryboardSegue) {
        
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