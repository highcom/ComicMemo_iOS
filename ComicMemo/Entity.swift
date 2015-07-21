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

}
