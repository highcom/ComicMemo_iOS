//
//  Entity.swift
//  ComicMemo
//
//  Created by 晃一 on 2015/07/22.
//  Copyright (c) 2015年 晃一. All rights reserved.
//

import Foundation
import CoreData

class Entity: NSManagedObject {

    @NSManaged var titleName: String
    @NSManaged var authorName: String
    @NSManaged var publisherName: String
    @NSManaged var numberOfBooks: NSNumber
    @NSManaged var memo: String
    
    // タイトル名を取得
    func getTitle() -> String {
        return titleName
    }
    
    // 巻数を取得
    func getNum() -> Int {
        return numberOfBooks.integerValue
    }
    
    // メモを取得
    func getMemo() -> String {
        return memo
    }
    
    // 巻数を追加
    func addNum() {
        var num: NSNumber = numberOfBooks.integerValue + 1
        numberOfBooks = num
    }
}
