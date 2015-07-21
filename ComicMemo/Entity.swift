//
//  Entity.swift
//  
//
//  Created by 晃一 on 2015/07/21.
//
//

import Foundation
import CoreData

class Entity: NSManagedObject {

    @NSManaged var memo: String
    @NSManaged var titleName: String
    @NSManaged var authorName: String
    @NSManaged var publisherName: String
    @NSManaged var numberOfBooks: NSNumber

}
