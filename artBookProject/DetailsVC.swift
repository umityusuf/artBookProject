//
//  DetailsVC.swift
//  artBookProject
//
//  Created by ümit yusuf erdem on 6.03.2023.
//

import UIKit
import CoreData

class DetailsVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    // seçilen painting ve id
    var chosenPainting = ""
    var chosenPaintingId : UUID?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenPainting != "" { // Kullanıcı tableView den bir görsel seçti ve görüntülemek istedi.
            
            saveButton.isHidden = true
            
            // core data
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            
            let idString = chosenPaintingId?.uuidString
            
            // Bir koşul yazacağım ve o koşulu bulup getirecek. Bütün kayıtları çekmek yerine sadece bir tane görsel bir tane name bir tane artis ismi ve bir tane yıl çekeceğim.
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            do{
               let results =  try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let name = result.value(forKey: "name") as? String {
                            nameText.text = name
                            if let artist = result.value(forKey: "artist") as? String {
                                artistText.text = artist
                                if let year = result.value(forKey: "year") as? Int {
                                    yearText.text = String(year)
                                    if let imageData = result.value(forKey: "image") as? Data {
                                        let image = UIImage(data: imageData)
                                        imageView.image = image
                                    }
                                }
                            }
                        }
                    }
                }
            } catch {
                print("Error")
            }
            
            
            
            
        } else { // Kullanıcı tableView den bir şey seçmedi ve eklemek istedi.
            saveButton.isHidden = false
            saveButton.isEnabled = false
            nameText.text = ""
            artistText.text = ""
            yearText.text = ""
        }
        
        
        
        
        // Regocnizers

        let gestureRegocnizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRegocnizer) // view içerisine gestureRegocnizer'i ekle.
        imageView.isUserInteractionEnabled = true // imageView'in tıklanabilir olma özelliğini aktif et.
        
        let imageTapRegocnizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRegocnizer) // imageView'e gestureRegocnizer'i ekle
    }
    
    
    
    @objc func selectImage() {
        // kullanıcı resme tıkladı nasıl galeriye gidecek. (picker kullanımı)
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary // kaynak tipi olarak fotoğraf galerisini seç
        picker.allowsEditing = true // kullanıcı seçtiği görseli editleyebilsin.
        present(picker, animated: true,completion: nil)
    }
    
    // Kullanıcı resmi seçtikten sonra ne olacak fonsiyonu
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true,completion: nil)
    }

   
    @objc func hideKeyboard(){
        view.endEditing(true) // Ekranda boş bir yere tıklandığında klavyeyi kapat.
    }
    
    
    
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        // Context'e ulaşabilmemiz için appDelegate'yi bir değişken olarak tanımlamamız gerekiyor.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        // Context içerisine ne koyacağım?
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        // Attributes
        newPainting.setValue(nameText.text!, forKey: "name")
        newPainting.setValue(artistText.text!, forKey: "artist")
        
        if let year = Int(yearText.text!) {
            newPainting.setValue(year, forKey: "year")
        }
        newPainting.setValue(UUID(), forKey: "id")
        
        
        // imageView içindeki görseli dataya çevirme
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        
        newPainting.setValue(data, forKey: "image")
        
        do {
            try context.save()
            print("Success")
        } catch {
            print("Error")
        }
        
        
        // Diğer viewControllerlara mesaj yollamak için kullanılan metod.
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil) // Tüm app içerisine newData diye bir mesaj yolladı.
        
        
        // Bir önceki viewController'e geri git.
        self.navigationController?.popViewController(animated: true)
        
    }
    
   
    
    
    

}
