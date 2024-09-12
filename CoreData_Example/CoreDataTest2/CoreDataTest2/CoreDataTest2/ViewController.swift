//
//  ViewController.swift
//  CoreDataTest2
//
//  Created by haams on 9/4/24.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    var persistentContainer: NSPersistentContainer? {
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        createUser()
    }
    
    func createUser(){
        guard let context = persistentContainer?.viewContext else { return }
        let newUser = AppUser(context: context)
        newUser.id = UUID()
        newUser.name = "abc"
        try? context.save()
        
        readUser()
    }
    
    func readUser(){
        guard let context = persistentContainer?.viewContext else { return }
        let request = AppUser.fetchRequest()
        let User = try? context.fetch(request)
        
        print(User?.first?.id)
        print(User?.first?.name)
    }
    
    func removeUser(){
        guard let context = persistentContainer?.viewContext else { return }
        let request = AppUser.fetchRequest()
        let User = try? context.fetch(request)
        
        let filteredUser = User?.filter({ $0.name == "abc" })
        
        for user in filteredUser {
            context.delete(user)
        }
        
        context.save()
    }
}

