//
//  coreDataRequest.swift
//  ImageMachine
//
//  Created by Fereizqo Sulaiman on 27/04/20.
//  Copyright © 2020 Fereizqo Sulaiman. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class coreDataRequest {
    static let shared = coreDataRequest()
    private init() {}
    
    // MARK: - Create new machine object data
    func create(content: [String]) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Machine", in: managedContext)!
        let machine = NSManagedObject(entity: entity, insertInto: managedContext)
        
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.medium
        formatter.timeStyle = DateFormatter.Style.none
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        let date = formatter.date(from: content[4])
        
        machine.setValue(content[0], forKeyPath: "id")
        machine.setValue(content[1], forKeyPath: "name")
        machine.setValue(content[2], forKeyPath: "type")
        machine.setValue(Int(content[3]), forKeyPath: "qrCode")
        machine.setValue(date, forKeyPath: "dateMaintenance")
        
        do {
            try managedContext.save()
            print("save succes: \(machine)")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    // MARK: - Retrieve machine data
    
    // Retrieve all saved machine data
    func retrieve() -> [Machines] {
        var machinesArray: [Machines] = []
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Machine")
        
        do {
          let machines = try managedContext.fetch(fetchRequest)
            
            machines.forEach { machine in
                machinesArray.append(
                    Machines(id: machine.value(forKey: "id") as! String,
                             name: machine.value(forKey: "name") as! String,
                             type: machine.value(forKey: "type") as! String,
                             qrCode: machine.value(forKey: "qrCode") as! Int,
                             maintenanceDate: machine.value(forKey: "dateMaintenance") as! Date)
                )
                
            }
        } catch let error as NSError {
          print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return machinesArray
    }
    
    // Retrieve all saved machine data in sorted
    func retrieveSort(SortBy: String) -> [Machines] {
        var machinesArray: [Machines] = []
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Machine")
        let sort = NSSortDescriptor(key: SortBy, ascending: true)
        fetchRequest.sortDescriptors = [sort]
        
        do {
          let machines = try managedContext.fetch(fetchRequest)
            
            machines.forEach { machine in
                machinesArray.append(
                    Machines(id: machine.value(forKey: "id") as! String,
                             name: machine.value(forKey: "name") as! String,
                             type: machine.value(forKey: "type") as! String,
                             qrCode: machine.value(forKey: "qrCode") as! Int,
                             maintenanceDate: machine.value(forKey: "dateMaintenance") as! Date)
                )
                
            }
        } catch let error as NSError {
          print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return machinesArray
    }
    
    // Retrieve detail of certain machine data
    func retrieveCertainMachine(id: String) -> [String] {
        
        var certainMachinesArray: [String] = []
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Machine")
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
        
        managedContext.performAndWait {
            do {
                let fetch = try managedContext.fetch(fetchRequest)
                
                let dataToRead = fetch[0] as! NSManagedObject
                
                let id = dataToRead.value(forKey: "id") as! String
                let name = dataToRead.value(forKey: "name") as! String
                let type = dataToRead.value(forKey: "type") as! String
                let qrCode = dataToRead.value(forKey: "qrCode") as! Int
                let maintenanceDate = dataToRead.value(forKey: "dateMaintenance") as! Date
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = DateFormatter.Style.medium
                dateFormatter.timeStyle = DateFormatter.Style.none
                dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                let date = dateFormatter.string(from: maintenanceDate)
                
                certainMachinesArray.append(contentsOf: [id,name,type,String(qrCode),date] )
                
            } catch let error as NSError {
              print("Could not fetch. \(error), \(error.userInfo)")
            }
        }
        
        return certainMachinesArray
    }
    
    // MARK: - Update certain machine data
    func update(id: String, content: [String]){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Machine")
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
        
        managedContext.performAndWait {
             do{
                 let fetch = try managedContext.fetch(fetchRequest)
                 let dataToUpdate = fetch[0] as! NSManagedObject

                 let formatter = DateFormatter()
                 formatter.dateStyle = DateFormatter.Style.medium
                 formatter.timeStyle = DateFormatter.Style.none
                 formatter.timeZone = TimeZone(secondsFromGMT: 0)
                 let date = formatter.date(from: content[4])

                 dataToUpdate.setValue(content[0], forKeyPath: "id")
                 dataToUpdate.setValue(content[1], forKeyPath: "name")
                 dataToUpdate.setValue(content[2], forKeyPath: "type")
                 dataToUpdate.setValue(Int(content[3]), forKeyPath: "qrCode")
                 dataToUpdate.setValue(date, forKeyPath: "dateMaintenance")
                 
                 try managedContext.save()
             }catch let err{
                 print(err)
             }
         }

    }
    
    // MARK: - Delete certain machine data
    func delete(id: String){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Machine")
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
        
        do{
            let dataToDelete = try managedContext.fetch(fetchRequest)[0] as! NSManagedObject
            managedContext.delete(dataToDelete)
            
            try managedContext.save()
        }catch let err{
            print(err)
        }
        
    }
    
}
