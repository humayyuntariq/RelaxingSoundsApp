//
//  MyCollection+CoreDataProperties.swift
//  SoundsApp
//
//  Created by Humayun Tariq on 25/07/2025.
//
//

import Foundation
import CoreData


extension MyCollection {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MyCollection> {
        return NSFetchRequest<MyCollection>(entityName: "MyCollection")
    }

    @NSManaged public var imageName: String?
    @NSManaged public var name: String?
    @NSManaged public var sounds: NSSet?

}

// MARK: Generated accessors for sounds
extension MyCollection {

    @objc(addSoundsObject:)
    @NSManaged public func addToSounds(_ value: MySound)

    @objc(removeSoundsObject:)
    @NSManaged public func removeFromSounds(_ value: MySound)

    @objc(addSounds:)
    @NSManaged public func addToSounds(_ values: NSSet)

    @objc(removeSounds:)
    @NSManaged public func removeFromSounds(_ values: NSSet)

}

extension MyCollection : Identifiable {

}
