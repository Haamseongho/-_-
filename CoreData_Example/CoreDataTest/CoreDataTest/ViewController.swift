//
//  ViewController.swift
//  CoreDataTest
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
    }
    
    @IBAction func btnSaveDataClicked(_ sender: UIButton) {
        createData()
    }
    func createData() {
        guard let context = self.persistentContainer?.viewContext else { return }
        let newJob = Job2(context: context)
        
        newJob.id = UUID()
        newJob.name = "Developer"
        
        try? context.save()
    }
    
    @IBAction func btnLoadDataClicked(_ sender: UIButton) {
        getData()
        updateData()
    }
    
    func getData() {
        guard let context = self.persistentContainer?.viewContext else { return }
        let request = Job2.fetchRequest()
        let jobs = try? context.fetch(request)
        
        print(jobs?.first?.id)
        print(jobs?.first?.name)
        
    }
    
    func updateData(){
        guard let context = self.persistentContainer?.viewContext else { return }
        let request = Job2.fetchRequest()
        guard let jobs = try? context.fetch(request) else { return }
        let filterJobs = jobs.filter( { $0.name == "Developer" })
        
        for job in filterJobs {
            job.name = "Developer Leader"
        }
        
        try? context.save()
        
        print(jobs.first?.name)
    }
    
    @IBAction func btnRemoveData(_ sender: UIButton) {
        removeData()
    }
    
    func removeData(){
        guard let context = self.persistentContainer?.viewContext else { return }
        let request = Job2.fetchRequest()
        guard let jobs = try? context.fetch(request) else { return }
        let filterJobs = jobs.filter( { $0.name == "Developer Leader" })
        for job in filterJobs {
            context.delete(job)
        }
        
        try? context.save()
        
        print(jobs)
    }
}

