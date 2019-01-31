//
//  ReallySimpleNoteCoreDataHelper.swift
//  rsnt-really-simple-note-taking-ios
//
//  Created by Németh László Harri on 2019. 01. 25..
//  Copyright © 2019. Németh László Harri. All rights reserved.
//

import Foundation
import CoreData

class ReallySimpleNoteCoreDataHelper {
    
    private(set) static var count: Int = 0
    
    static func createNoteInCoreData(
        noteToBeCreated:          ReallySimpleNote,
        intoManagedObjectContext: NSManagedObjectContext) {
        
        // Let’s create an entity and new note record
        let noteEntity = NSEntityDescription.entity(
            forEntityName: "Note",
            in:            intoManagedObjectContext)!
        
        let newNoteToBeCreated = NSManagedObject(
            entity:     noteEntity,
            insertInto: intoManagedObjectContext)

        newNoteToBeCreated.setValue(
            noteToBeCreated.noteId,
            forKey: "noteId")
        
        newNoteToBeCreated.setValue(
            noteToBeCreated.noteTitle,
            forKey: "noteTitle")
        
        newNoteToBeCreated.setValue(
            noteToBeCreated.noteText,
            forKey: "noteText")
        
        newNoteToBeCreated.setValue(
            noteToBeCreated.noteTimeStamp,
            forKey: "noteTimeStamp")
        
        do {
            try intoManagedObjectContext.save()
        } catch let error as NSError {
            // TODO error handling
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    static func readNotesFromCoreData(fromManagedObjectContext: NSManagedObjectContext) -> [ReallySimpleNote] {

        var returnedNotes = [ReallySimpleNote]()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        fetchRequest.predicate = nil
        
        do {
            let fetchedNotesFromCoreData = try fromManagedObjectContext.fetch(fetchRequest)
            fetchedNotesFromCoreData.forEach { (fetchRequestResult) in
                let noteManagedObjectRead = fetchRequestResult as! NSManagedObject
                returnedNotes.append(ReallySimpleNote.init(
                    noteId:        noteManagedObjectRead.value(forKey: "noteId") as! UUID,
                    noteTitle:     noteManagedObjectRead.value(forKey: "noteTitle") as! String,
                    noteText:      noteManagedObjectRead.value(forKey: "noteText")  as! String,
                    noteTimeStamp: noteManagedObjectRead.value(forKey: "noteTimeStamp") as! Int64))
            }
        } catch let error as NSError {
            // TODO error handling
            print("Could not read. \(error), \(error.userInfo)")
        }
        
        // set note count
        self.count = returnedNotes.count
        
        return returnedNotes
    }
    
    static func readNoteFromCoreData(
        noteToBeRead:             ReallySimpleNote,
        fromManagedObjectContext: NSManagedObjectContext) -> ReallySimpleNote? {

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        
        let noteTitlePredicate = NSPredicate(format: "noteTitle = %@", noteToBeRead.noteTitle)
        
        let noteTextPredicate = NSPredicate(format: "noteText = %@", noteToBeRead.noteText)
        
        fetchRequest.predicate = NSCompoundPredicate(
            andPredicateWithSubpredicates: [noteTitlePredicate,
                                            noteTextPredicate])
        do {
            let fetchedNotesFromCoreData = try fromManagedObjectContext.fetch(fetchRequest)
            let noteManagedObjectToBeRead = fetchedNotesFromCoreData[0] as! NSManagedObject
            return ReallySimpleNote.init(
                noteId:        noteManagedObjectToBeRead.value(forKey: "noteId")        as! UUID,
                noteTitle:     noteManagedObjectToBeRead.value(forKey: "noteTitle")     as! String,
                noteText:      noteManagedObjectToBeRead.value(forKey: "noteText")      as! String,
                noteTimeStamp: noteManagedObjectToBeRead.value(forKey: "noteTimeStamp") as! Int64)
        } catch let error as NSError {
            // TODO error handling
            print("Could not read. \(error), \(error.userInfo)")
            return nil
        }
    }

    static func readNoteFromCoreData(
        noteIdToBeRead:           UUID,
        fromManagedObjectContext: NSManagedObjectContext) -> ReallySimpleNote? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        
        let noteIdPredicate = NSPredicate(format: "noteId = %@", noteIdToBeRead as CVarArg)
        
        fetchRequest.predicate = noteIdPredicate
        
        do {
            let fetchedNotesFromCoreData = try fromManagedObjectContext.fetch(fetchRequest)
            let noteManagedObjectToBeRead = fetchedNotesFromCoreData[0] as! NSManagedObject
            return ReallySimpleNote.init(
                noteId:        noteManagedObjectToBeRead.value(forKey: "noteId")        as! UUID,
                noteTitle:     noteManagedObjectToBeRead.value(forKey: "noteTitle")     as! String,
                noteText:      noteManagedObjectToBeRead.value(forKey: "noteText")      as! String,
                noteTimeStamp: noteManagedObjectToBeRead.value(forKey: "noteTimeStamp") as! Int64)
        } catch let error as NSError {
            // TODO error handling
            print("Could not read. \(error), \(error.userInfo)")
            return nil
        }
    }

    static func deleteNoteFromCoreData(
        noteToBeDeleted:          ReallySimpleNote,
        fromManagedObjectContext: NSManagedObjectContext) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        
        let noteTitlePredicate = NSPredicate(format: "noteTitle = %@", noteToBeDeleted.noteTitle)
        
        let noteTextPredicate = NSPredicate(format: "noteText = %@", noteToBeDeleted.noteText)
        
        fetchRequest.predicate = NSCompoundPredicate(
            andPredicateWithSubpredicates: [noteTitlePredicate,
                                            noteTextPredicate])
        
        do {
            let fetchedNotesFromCoreData = try fromManagedObjectContext.fetch(fetchRequest)
            let noteManagedObjectToBeDeleted = fetchedNotesFromCoreData[0] as! NSManagedObject
            fromManagedObjectContext.delete(noteManagedObjectToBeDeleted)
            
            do {
                try fromManagedObjectContext.save()
            } catch let error as NSError {
                // TODO error handling
                print("Could not save. \(error), \(error.userInfo)")
            }
        } catch let error as NSError {
            // TODO error handling
            print("Could not delete. \(error), \(error.userInfo)")
        }
        
    }

    static func deleteNoteFromCoreData(
        noteIdToBeDeleted:        UUID,
        fromManagedObjectContext: NSManagedObjectContext) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        
        let noteIdAsCVarArg: CVarArg = noteIdToBeDeleted as CVarArg
        let noteIdPredicate = NSPredicate(format: "noteId == %@", noteIdAsCVarArg)
        
        fetchRequest.predicate = noteIdPredicate
        
        do {
            let fetchedNotesFromCoreData = try fromManagedObjectContext.fetch(fetchRequest)
            let noteManagedObjectToBeDeleted = fetchedNotesFromCoreData[0] as! NSManagedObject
            fromManagedObjectContext.delete(noteManagedObjectToBeDeleted)
            
            do {
                try fromManagedObjectContext.save()
            } catch let error as NSError {
                // TODO error handling
                print("Could not save. \(error), \(error.userInfo)")
            }
        } catch let error as NSError {
            // TODO error handling
            print("Could not delete. \(error), \(error.userInfo)")
        }
        
    }

}
