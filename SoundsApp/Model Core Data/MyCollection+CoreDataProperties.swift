//
//  MyCollection+CoreDataProperties.swift
//  SoundsApp
//
//  Created by Humayun Tariq on 24/07/2025.
//
//

import Foundation
import CoreData


extension MyCollection {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MyCollection> {
        return NSFetchRequest<MyCollection>(entityName: "MyCollection")
    }

    @NSManaged public var name: String?
    @NSManaged public var imageName: String?
    @NSManaged public var sounds: MySound?

}

extension MyCollection : Identifiable {

}
