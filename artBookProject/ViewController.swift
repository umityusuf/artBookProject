//
//  ViewController.swift
//  artBookProject
//
//  Created by ümit yusuf erdem on 6.03.2023.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {

    
    @IBOutlet weak var tableView: UITableView!
    var nameArray = [String]()
    var idArray = [UUID]()
    
    var selectedPainting = ""
    var selectedPaintingId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addPaint))
        
        
        getData()
        
        
        
    }
    
    
    // ViewDidLoad açılmadan önce 
    override func viewWillAppear(_ animated: Bool) {
        // Gözlemci ekle (app içerisine gönderilen mesajı almak için kullanılan metod.)
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "newData"), object: nil)
    }
    
    
    
    
    
    // DataBase'den Veri nasıl çekilir.
    @objc func getData(){
        
        nameArray.removeAll(keepingCapacity: false)
        idArray.removeAll(keepingCapacity: false)
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
        
        // Cache'den okuma ile ilgili yapılan ayar.
        fetchRequest.returnsObjectsAsFaults = false
        
        // FetchRequestResult bir dizi içerisinde gelecek. Dolayısıyla birden fazla result olacak.
        do {
            let results = try context.fetch(fetchRequest)
            // Core Data model objesi olarak ele almam lazım ki ismini id'sini ayrı ayrı çekebileyim. Yoksa Any olarak gelir Entity içerisindeki tüm farklı değişken modelleri olduğu gibi alır. Bu yüzden for loop içersinde Cast etmemiz gerekiyor.
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let name = result.value(forKey: "name") as? String {
                        self.nameArray.append(name)
                    }
                    if let id = result.value(forKey: "id") as? UUID {
                        self.idArray.append(id)
                    }
                    // Table view'e veri eklendikten sonra yeni veri eklendiğini görmek için yenile (refresh) et.
                    self.tableView.reloadData()
                }
                
            }
            
        } catch {
            print("Error")
        }
        
    }
    
    @objc func addPaint() {
        
        selectedPainting = ""
        
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    
    // Kaç tane row olacak
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    
    // Her row içerisinde ne olacak.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC" {
            let destinationVC = segue.destination as! DetailsVC
            destinationVC.chosenPainting = selectedPainting
            destinationVC.chosenPaintingId = selectedPaintingId
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPainting = nameArray[indexPath.row]
        selectedPaintingId = idArray[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    // Core Data'dan Silme işlemlerinin tanımlandığı metod
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext

            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            let idString = idArray[indexPath.row].uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            fetchRequest.returnsObjectsAsFaults = false
            
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    
                    for result in results as! [NSManagedObject] {
                        if let id = result.value(forKey: "id") as? UUID {
                            if id == idArray[indexPath.row] {
                                context.delete(result)
                                nameArray.remove(at: indexPath.row)
                                idArray.remove(at: indexPath.row)
                                self.tableView.reloadData()
                                do {
                                    try context.save()
                                } catch {
                                    print("Error")
                                }
                                break
                                
                            }
                        }
                    }
                }
            } catch {
                print("Error")
            }
            
        }
    }
                                    
                                                                    
            
        


}

