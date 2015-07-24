//
//  DetailViewController.swift
//  ComicMemo
//
//  Created by 晃一 on 2015/07/18.
//  Copyright (c) 2015年 晃一. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var authorField: UITextField!
    @IBOutlet weak var publisherField: UITextField!
    @IBOutlet weak var numberOfBooksField: UITextField!
    @IBOutlet weak var memoTextView: PlaceHolderTextView!
    
    var titleName: String = ""
    var authorName: String = ""
    var publisherName: String = ""
    var numberOfBooks: Int = 0
    var memo: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        memoTextView.layer.borderWidth = 0.5
        memoTextView.layer.borderColor = UIColor.lightGrayColor().CGColor
        memoTextView.layer.cornerRadius = 5
        memoTextView.placeHolder = "メモを入力"
        // 編集の場合は前の画面から値が渡されている
        titleField.text = titleName
        authorField.text = authorName
        publisherField.text = publisherName
        numberOfBooksField.text = numberOfBooks.description
        memoTextView.text = memo
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
