//
//  MySound+CoreDataProperties.swift
//  SoundsApp
//
//  Created by Humayun Tariq on 25/07/2025.
//
//

import Foundation
import CoreData


extension MySound {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MySound> {
        return NSFetchRequest<MySound>(entityName: "MySound")
    }

    @NSManaged public var fileName: String?
    @NSManaged public var lastPlayed: Date?
    @NSManaged public var name: String?
    @NSManaged public var collectionTo: MyCollection?

}

extension MySound : Identifiable {

}
