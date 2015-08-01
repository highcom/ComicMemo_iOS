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
    @IBOutlet weak var changeEditButton: UIBarButtonItem!
    var myItems: NSMutableArray = []
    var editRow: Int = 0
    var tableSearchText: String = ""
    var searchItems: NSMutableArray = []
    
    // 画面遷移時の状態
    var state = STATE.ST_NONE
    enum STATE {
        case ST_NONE
        case ST_ADD
        case ST_EDIT
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // データ読み込み
        readMemoData()
    }
    
    // テーブルを追加する
    @IBAction func tapAdd(sender: AnyObject) {
        // ステートを追加状態にする
        state = STATE.ST_ADD
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
        var item = getItems(row!)
        item.addNum()
        
        // 現在の状態を保存する
        saveMemoData()

        // TableViewを再読み込み.
        tableView.reloadData()
    }
    
    // 行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var tableCount = 0
        // 検索中か
        if tableSearchText == "" {
            tableCount = myItems.count
        } else {
            tableCount = searchItems.count
        }
        // データが1件以上ある場合には編集ボタンを有効化する
        if tableCount > 0 {
            changeEditButton.enabled = true
        } else {
            changeEditButton.enabled = false
        }
        
        return tableCount
    }
    
    // セルの設定
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("memoCell") as! UITableViewCell
        var myItem = getItems(indexPath.row)
        
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
            
            // CoreDataからレコードをを削除する
            deleteMemoData(myItems[indexPath.row] as! NSManagedObject)
            
            // 指定されたセルのオブジェクトをmyItemsから削除する.
            myItems.removeObjectAtIndex(indexPath.row)
 
            // TableViewを再読み込み.
            tableView.reloadData()
        }
    }

    // infoボタンイベント
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        // ステートを編集にする
        state = STATE.ST_EDIT
        // 選択されたinfoボタンの行を設定
        editRow = indexPath.row
        // 詳細画面へ遷移する
        self.performSegueWithIdentifier("detailViewSegue", sender: nil)
    }
    
    // 画面遷移時に呼ばれる
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // 編集時にテーブルのデータを詳細画面に渡す
        if segue.identifier == "detailViewSegue" && state == STATE.ST_EDIT {
            // 選択したテーブルのデータを詳細画面に渡す
            var editData = getItems(editRow)
            var newVC = segue.destinationViewController as! DetailViewController
            newVC.titleName = editData.titleName
            newVC.numberOfBooks = editData.numberOfBooks.integerValue
            newVC.memo = editData.memo
        }
    }

    // 並べ替えをできるようにする
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        // 並べ替えたら、その順番でCoreDataに保存する
        var srcIndex = sourceIndexPath.row
        var desIndex = destinationIndexPath.row
        var minIndex = 0
        var maxIndex = 0
        var isMoveDir = false
        
        if srcIndex == desIndex {
            return
        } else if srcIndex < desIndex {
            minIndex = srcIndex
            maxIndex = desIndex
            isMoveDir = true
        } else {
            minIndex = desIndex
            maxIndex = srcIndex
            isMoveDir = false
        }
        
        for var i = minIndex; i <= maxIndex; i++ {
            var newOrder = 0
            if i == srcIndex {
                newOrder = desIndex
            } else if isMoveDir {
                let buffItem = myItems[i] as! Entity
                newOrder = buffItem.getDisplayOrder() - 1
            } else {
                let buffItem = myItems[i] as! Entity
                newOrder = buffItem.getDisplayOrder() + 1
            }
            myItems[i].setValue(newOrder, forKey: "displayOrder")
        }
        // 現在の状態を保存する
        saveMemoData()
        // 順番が変わったのでデータを再読込する
        readMemoData()
    }
    
    // 検索状態に応じてtableViewを並べ替え可能・不可能を設定
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // 検索中でない場合は並べ替えを可能とする
        if tableSearchText == "" {
            return true
        } else {
            return false
        }
    }
    
    // セルを長押しされた時の処理
    @IBAction func tableCellLongPressed(sender: UILongPressGestureRecognizer) {
        // 押された位置でcellのPathを取得
        let point = sender.locationInView(tableView)
        let indexPath = tableView.indexPathForRowAtPoint(point)
        
        if indexPath == nil {
            // 長押し位置に対する行数が取得できなければ何もしない
        } else if sender.state == UIGestureRecognizerState.Began  {
            // 長押しされた場合の処理
            var selectItems = getItems(indexPath!.row) as ComicMemo.Entity
            let alertController = UIAlertController()
            let firstAction = UIAlertAction(title: "コピー", style: .Default) {
                // 選択行の文字列をコピーする
                action in self.copyPasteBoard(selectItems.titleName)
            }
            let secondAction = UIAlertAction(title: "Safariで検索", style: .Default) {
                // 選択行の文字列をSafariで検索する
                action in self.searchSafari(selectItems.titleName)
            }
            let cancelAction = UIAlertAction(title: "キャンセル", style: .Cancel) {
                action in self.alertCancel()
            }
            
            alertController.addAction(firstAction)
            alertController.addAction(secondAction)
            alertController.addAction(cancelAction)
            
            //For ipad And Univarsal Device
            alertController.popoverPresentationController?.sourceView = tableView.superview
            alertController.popoverPresentationController?.sourceRect = CGRect(x: (tableView.superview!.frame.width/2), y: tableView.superview!.frame.height, width: 0, height: 0)
            alertController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.Up
            
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    // [アラート]ペーストボードに文字列をコピーする
    func copyPasteBoard(text: String) {
        var pasteBoard = UIPasteboard.generalPasteboard()
        pasteBoard.string = text
    }
    
    // [アラート]Safariで文字列を検索する
    func searchSafari(text: String) {
        let encodeText = text.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        var searchText = "https://www.google.co.jp/#q=" + encodeText!
        let url = NSURL(string: searchText)
        if UIApplication.sharedApplication().canOpenURL(url!){
            UIApplication.sharedApplication().openURL(url!)
        }
    }
    
    // [アラート]キャンセルボタン
    func alertCancel() {
        // キャンセル選択時は何もしない
    }
    
    // 検索バー入力イベント
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        // TODO: 検索バーで入力された文字列をCoreDataから検索
        // テキストが変更される毎に呼ばれる
        tableSearchText = searchText
        // CoreDataから検索する
        searchMemoData()
        // TableViewを再読み込み.
        tableView.reloadData()
    }
    
    // 検索ボタンが押下された場合
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        // キーボードをしまう
        self.view.endEditing(true)
        // CoreDataから検索する
        searchMemoData()
        // TableViewを再読み込み.
        tableView.reloadData()
    }

    // キャンセルボタンが押下された場合
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        // キーボードをしまう
        self.view.endEditing(true)
        // 文字列を初期化する
        tableSearchText = ""
        searchBar.text = ""
        // TableViewを再読み込み.
        tableView.reloadData()
    }
    
    // 検索状態に応じてテーブルを返却する
    func getItems(row: Int) -> ComicMemo.Entity {
        if tableSearchText == "" {
            return myItems[row] as! ComicMemo.Entity
        } else {
            return searchItems[row] as! ComicMemo.Entity
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 詳細画面のキャンセルボタン
    @IBAction func cancelButton(segue: UIStoryboardSegue) {
        // ステートを初期状態に戻す
        state = STATE.ST_NONE
    }
    
    // 詳細画面の完了ボタン
    @IBAction func doneButton(segue: UIStoryboardSegue) {
        let detailData = segue.sourceViewController as! DetailViewController
        // 詳細画面の入力データを受け取る
        var titleName = detailData.titleField.text
        var numberOfBooks = 0;
        if detailData.numberOfBooksField.text != "" {
            numberOfBooks = detailData.numberOfBooksField.text.toInt()!
        }
        var memo = detailData.memoTextView.text
        
        // infoボタンを押されて編集の場合はレコードを更新にするよう処理を分ける
        if state == STATE.ST_ADD {
            // 詳細画面で入力したデータを追加
            writeMemoData(myItems.count, title: titleName, number: numberOfBooks, memo: memo)
        } else if state == STATE.ST_EDIT {
            // 詳細画面で入力したデータで更新
            updateMemoData(titleName, number: numberOfBooks, memo: memo)
        } else {
            NSLog("state err!")
        }
        
        // ステートを初期状態に戻す
        state = STATE.ST_NONE
        // データの再読込
        readMemoData()
        // TableViewを再読み込み.
        tableView.reloadData()
    }
    
    // CoreDataへレコードの書き込み
    func writeMemoData(order: Int, title: String, number: Int, memo: String) {
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let myContext: NSManagedObjectContext = appDel.managedObjectContext!
        
        let myEntity: NSEntityDescription! = NSEntityDescription.entityForName("Entity", inManagedObjectContext: myContext)
        
        // オブジェクトを新規作成
        var newData = Entity(entity: myEntity, insertIntoManagedObjectContext: myContext)
        newData.displayOrder = order
        newData.titleName = title
        newData.numberOfBooks = number
        newData.memo = memo

        // 作成したオブジェクトを保存
        var error: NSError? = nil
        if !myContext.save(&error) {
            NSLog("writeMemoData err![\(error)]")
            abort()
        }
    }
    
    // CoreDataからレコードの読み込み
    func readMemoData() {
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let myContext: NSManagedObjectContext = appDel.managedObjectContext!
        
        let myRequest: NSFetchRequest = NSFetchRequest(entityName: "Entity")
        myRequest.returnsObjectsAsFaults = false
        
        var myResults: NSArray! = myContext.executeFetchRequest(myRequest, error: nil)
        
        myItems = []
        for myData in myResults {
            myItems.addObject(myData)
        }
        
        // displayOrderの順番で表示
        let sort_descriptor:NSSortDescriptor = NSSortDescriptor(key:"displayOrder", ascending:true)
        myItems.sortUsingDescriptors([sort_descriptor])
    }
    
    // CoreDataのレコードを更新
    func updateMemoData(title: String, number: Int, memo: String) {
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let myContext: NSManagedObjectContext = appDel.managedObjectContext!
        
        var editData = getItems(editRow)
        editData.titleName = title
        editData.numberOfBooks = number
        editData.memo = memo

        // 作成したオブジェクトを保存
        var error: NSError? = nil
        if !myContext.save(&error) {
            NSLog("updateMemoData err![\(error)]")
            abort()
        }
    }
    
    // CoreDataのレコードから部分一致検索
    func searchMemoData() {
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let myContext: NSManagedObjectContext = appDel.managedObjectContext!

        let myRequest: NSFetchRequest = NSFetchRequest(entityName: "Entity")
        // 検索条件を設定
        let predicate = NSPredicate(format: "%K contains %@", "titleName", tableSearchText)
        myRequest.predicate = predicate
        
        var error: NSError? = nil;
        // フェッチリクエストの実行
        searchItems = []
        if var results = myContext.executeFetchRequest(myRequest, error: &error) {
            for managedObject in results {
                searchItems.addObject(managedObject as! ComicMemo.Entity)
            }
            // displayOrderの順番で表示
            let sort_descriptor:NSSortDescriptor = NSSortDescriptor(key:"displayOrder", ascending:true)
            searchItems.sortUsingDescriptors([sort_descriptor])
        } else {
            NSLog("searchMemoData err![\(error)]")
            abort()
        }
    }
    
    // CoreDataの現在の状態を保存
    func saveMemoData() {
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let myContext: NSManagedObjectContext = appDel.managedObjectContext!

        // 作成したオブジェクトを保存
        var error: NSError? = nil
        if !myContext.save(&error) {
            NSLog("updateMemoData err![\(error)]")
            abort()
        }
    }
    
    // CoreDataのレコードの削除
    func deleteMemoData(object: NSManagedObject) {
        // CoreDataの読み込み処理
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let myContext: NSManagedObjectContext = appDel.managedObjectContext!
        
        myContext.deleteObject(object)

        // 作成したオブジェクトを保存
        var error: NSError? = nil
        if !myContext.save(&error) {
            NSLog("deleteMemoData err![\(error)]")
            abort()
        }
    }
}
