//
//  TableViewController.swift
//  NewsDemo
//
//  Created by Герман on 23.10.21.
//

import UIKit
import CoreData

class NewsTableViewController: UITableViewController, UISearchControllerDelegate {
    
    let loadingView = UIView()
    let spinner = UIActivityIndicatorView()
    let loadingLabel = UILabel()
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    var articles: [Articles]?
    var filteredNews: [Articles]?
    var likedNews = [Articles]()
    let date = DateForNews()

    var count = 0
    let searchController = UISearchController(searchResultsController: nil)
        
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
        
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        setLoadingScreen()
        loadData(date: date.currentDate())
        createdSearch()
        tableView.reloadData()

    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering{
            return filteredNews?.count ?? 0
        }
        return articles?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        let item : Articles?
        if isFiltering{
            item = filteredNews?[indexPath.row]
        } else {
            item = articles?[indexPath.row]
        }
        
        if indexPath.row == articles!.count - 1{
            if count < 7{
                count += 1
                loadDataInTheEnd(count: count)
                self.tableView.reloadData()
            }
        }
        
        cell.labelTitle.text = item?.title
        cell.labelDescription.text = item?.content
        cell.imageOfNews.image = getImage(stringUrl: item?.urlToImage ?? "")
        cell.labelPublishAt.text = item?.publishedAt
        cell.buttonLike.addTarget(self, action: #selector(connected(sender:)), for: .touchUpInside)
        cell.buttonLike.tag = indexPath.row
            
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex {
            let spinner = UIActivityIndicatorView(style: .medium)
            spinner.startAnimating()
            spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))

            self.tableView.tableFooterView = spinner
            self.tableView.tableFooterView?.isHidden = false
        }
    }
    
    @IBAction func clickReloadData(_ sender: Any) {
        count = 0
        loadData(date: date.currentDate())
        tableView.reloadData()
    }
    
    @objc func connected(sender: UIButton){
        sender.showAnimation {
            let buttonTag = sender.tag
            self.likedNews.append((self.articles![buttonTag]))
            let url = URL(string: self.articles![buttonTag].urlToImage!)!
            let dataOfImage = try! Data(contentsOf: url)
            self.saveInArchive(titleOfNews: self.articles![buttonTag].title!, descriptionOfNews: self.articles![buttonTag].description!, imageOfNews: dataOfImage)
        }
    }
    
    func saveInArchive(titleOfNews : String, descriptionOfNews : String, imageOfNews : Data){
        let managedContext = appDelegate!.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "ArchiveOfNews", in: managedContext)!
        let archiveOfNews = NSManagedObject(entity: entity, insertInto: managedContext)
        archiveOfNews.setValue(titleOfNews, forKey: "titleOfNews")
        archiveOfNews.setValue(descriptionOfNews, forKey: "descriptionOfNews")
        archiveOfNews.setValue(imageOfNews, forKey: "imageOfNews")
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func loadData(date: String){
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(20)) {
            if let url = URL(string: "https://newsapi.org/v2/everything?q=world&from=\(date)&apiKey=afc2d2588b7e407cb4ba1e237dfe93bc"),
           let data = try? Data(contentsOf: url),
            let news = try? JSONDecoder().decode(News.self, from: data){
                self.articles = news.articles
                self.tableView.reloadData()
                self.tableView.separatorStyle = .singleLine
                self.removeLoadingScreen()
            }
        }
    }
    
    func loadDataInTheEnd(count: Int){
        if let url = URL(string: "https://newsapi.org/v2/everything?q=world&from=\(date.newPageDate(day: count))&to=\(date.newPageDate(day: count))&apiKey=afc2d2588b7e407cb4ba1e237dfe93bc"),
           let data = try? Data(contentsOf: url),
           let news = try? JSONDecoder().decode(News.self, from: data){
                self.articles?.append(contentsOf: news.articles!)
            print(url)
            }
    }
    
    func getImage(stringUrl: String) -> UIImage {
        let imageDefault: UIImage = #imageLiteral(resourceName: "constantImage")
        guard let url = URL(string: stringUrl) else { return imageDefault  }
        let data = try? Data(contentsOf: url)
        guard let imageData = data else { return imageDefault }
        guard let image = UIImage(data: imageData) else { return imageDefault }
        return image
    }

    
    func createdSearch(){
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search News"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    func filterContentForSearchText(_ searchText: String) {
        let articles = articles
        filteredNews = (articles?.filter{ (candy: Articles) -> Bool in
            return candy.title?.lowercased().contains(searchText.lowercased()) ?? false
        })
        tableView.reloadData()
    }
    
    private func setLoadingScreen() {

        let width: CGFloat = 120
        let height: CGFloat = 30
        let x = (tableView.frame.width / 2) - (width / 2)
        let y = (tableView.frame.height / 2) - (height / 2) - (navigationController?.navigationBar.frame.height)!
        loadingView.frame = CGRect(x: x, y: y, width: width, height: height)

        loadingLabel.textColor = .gray
        loadingLabel.textAlignment = .center
        loadingLabel.text = "Loading..."
        loadingLabel.frame = CGRect(x: 0, y: 0, width: 140, height: 30)

        spinner.style = .medium
        spinner.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        spinner.startAnimating()

        loadingView.addSubview(spinner)
        loadingView.addSubview(loadingLabel)

        tableView.addSubview(loadingView)

       }

    private func removeLoadingScreen() {
        spinner.stopAnimating()
        spinner.isHidden = true
        loadingLabel.isHidden = true
       }
}

extension NewsTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }
}

extension UIView {
    func showAnimation(_ completionBlock: @escaping () -> Void) {
      isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.1,
                       delay: 0,
                       options: .curveLinear,
                       animations: { [weak self] in
                            self?.transform = CGAffineTransform.init(scaleX: 0.95, y: 0.95)
        }) {  (done) in
            UIView.animate(withDuration: 0.1,
                           delay: 0,
                           options: .curveLinear,
                           animations: { [weak self] in
                                self?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            }) { [weak self] (_) in
                self?.isUserInteractionEnabled = true
                completionBlock()
            }
        }
    }
}

