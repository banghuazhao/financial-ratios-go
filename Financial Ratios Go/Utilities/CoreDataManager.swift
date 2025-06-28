//
//  CoreDataManager.swift
//  Finance Ratio Calculator
//
//  Created by Banghua Zhao on 9/27/19.
//  Copyright © 2019 Banghua Zhao. All rights reserved.
//

import CoreData

struct CoreDataManager {
    static let shared = CoreDataManager() // will live forever as long as your application is still alive, it's properties will too

    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataModels")
        container.loadPersistentStores { _, err in
            if let err = err {
                fatalError("Loading of store failed: \(err)")
            }
        }
        return container
    }()

    func fetchLocalCompanies() -> [MyCompany] {
        let context = persistentContainer.viewContext

        let fetchRequest = NSFetchRequest<MyCompany>(entityName: "MyCompany")
        do {
            let myCompanies = try context.fetch(fetchRequest)
            return myCompanies
        } catch let fetchErr {
            print("Failed to fetch companies:", fetchErr)
            return []
        }
    }

    func fetchLocalFiscalPeriod(myCompany: MyCompany?) -> ([MyFiscalPeriod], [MyFiscalPeriod]) {
        var myFiscalPeriodAnnually = [MyFiscalPeriod]()
        var myFiscalPeriodQuarterly = [MyFiscalPeriod]()

        guard let myFiscalPeriod = myCompany?.fiscalPeriods?.allObjects as? [MyFiscalPeriod] else {
            return ([], [])
        }

        for eachPeriod in myFiscalPeriod {
            if eachPeriod.period == "Annually" {
                myFiscalPeriodAnnually.append(eachPeriod)
            } else {
                myFiscalPeriodQuarterly.append(eachPeriod)
            }
        }

        return (myFiscalPeriodAnnually, myFiscalPeriodQuarterly)
    }

//    func createEmployee(employeeName: String, company: Company) -> (Employee?, Error?) {
//        let context = persistentContainer.viewContext
//
//        //create an employee
//        let employee = NSEntityDescription.insertNewObject(forEntityName: "Employee", into: context) as! Employee
//
//        employee.company = company
//
//        // lets check company is setup correctly
    ////        let company = Company(context: context)
    ////        company.employees
    ////
    ////        employee.company
//
//        employee.setValue(employeeName, forKey: "name")
//
//        let employeeInformation = NSEntityDescription.insertNewObject(forEntityName: "EmployeeInformation", into: context) as! EmployeeInformation
//
//        employeeInformation.taxId = "456"
//
    ////        employeeInformation.setValue("456", forKey: "taxId")
//
//        employee.employeeInformation = employeeInformation
//
//        do {
//            try context.save()
//            // save succeeds
//            return (employee, nil)
//        } catch let err {
//            print("Failed to create employee:", err)
//            return (nil, err)
//        }
//
//    }
}
