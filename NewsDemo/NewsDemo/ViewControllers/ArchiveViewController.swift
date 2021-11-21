//
//  ViewController.swift
//  NewsDemo
//
//  Created by Герман on 18.10.21.
//

import UIKit
import CoreData

class ArchiveViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableViewOfLikedPost: UITableView!
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var archiveOfLikedNews: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewOfLikedPost.delegate = self
        tableViewOfLikedPost.dataSource = self
        
        let managedContext =
            appDelegate!.persistentContainer.viewContext
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "ArchiveOfNews")
        do {
            archiveOfLikedNews = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return archiveOfLikedNews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableViewOfLikedPost.dequeueReusableCell(withIdentifier: "cell") as! LikedPostTableViewCell
        
        let item = archiveOfLikedNews[indexPath.row]
        cell.labelTitle.text = item.value(forKey: "titleOfNews") as? String
        let dataOfNews = item.value(forKey: "imageOfNews")
        let imageOfNews = UIImage(data: dataOfNews as! Data)
        cell.imageOfNews.image = imageOfNews
        cell.labelDescription.text = item.value(forKey: "descriptionOfNews") as? String
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
                let managedContext =
                appDelegate!.persistentContainer.viewContext
                managedContext.delete(archiveOfLikedNews[indexPath.row])
                    do {
                        try  managedContext.save()
                        archiveOfLikedNews.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    } catch {
                        let saveError = error as NSError
                        print(saveError)
                    }
                }
    }

}

