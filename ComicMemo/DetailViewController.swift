//
//  DetailViewController.swift
//  ComicMemo
//
//  Created by 晃一 on 2015/07/18.
//  Copyright (c) 2015年 晃一. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var numberOfBooksField: UITextField!
    @IBOutlet weak var memoTextView: PlaceHolderTextView!
    
    var titleName: String = ""
    var numberOfBooks: Int = 0
    var memo: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        memoTextView.layer.borderWidth = 0.5
        memoTextView.layer.borderColor = UIColor.lightGrayColor().CGColor
        memoTextView.layer.cornerRadius = 5
        
        numberOfBooksField.delegate = self
        
        // 編集の場合は前の画面から値が渡されている
        titleField.text = titleName
        // 巻数が0の場合には表示しない
        if numberOfBooks > 0 {
            numberOfBooksField.text = numberOfBooks.description
        } else {
            numberOfBooksField.text = ""
        }
        
        // メモが何も入力されていない場合はプレースホルダーを表示
        memoTextView.text = memo
        if count(memoTextView.text) == 0 {
            memoTextView.placeHolder = "メモを入力"
        }
    }
    
    // 巻数は３桁まで入力可能
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        // 文字数最大
        let maxLength: Int = 4
        // 入力済みの文字と入力された文字を合わせて取得
        var str = textField.text + string

        // 文字数がmaxLength以下かつ数値ならtrueを返す
        if count("\(str)") < maxLength {
            if str.toInt() != nil {
                return true
            }
        }
        return false
    }

    // タイトル入力でReturnされた場合
    @IBAction func titleTextFieldReturn(sender: UITextField) {
        // 巻数入力エリアに移る
        self.numberOfBooksField.becomeFirstResponder()
    }

    // TextField以外の場所をタップされた場合
    @IBAction func tapScreen(sender: AnyObject) {
        // キーボードをしまう
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
