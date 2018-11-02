//
//  MasterViewController.swift
//  rdma
//
//  Created by User1 RDMA on 2018-10-28.
//  Copyright © 2018 CP. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    //var objects = [Any]()
    var documents = [Document]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //navigationItem.leftBarButtonItem = editButtonItem

        //let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        //navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        var i:Int = 0
        
//        objects.insert("Using WebView Control", at:i); i+=1
//        objects.insert("  GOI", at: i); i+=1
//        objects.insert("  CROR", at: i); i+=1
//        objects.insert("  GCOR", at: i); i+=1
        //objects.insert("Using PDFView Control", at:i); i+=1
        documents.insert(Document(fromName: "GOI"), at: i); i+=1
        documents.insert(Document(fromName: "CROR"), at: i); i+=1
        documents.insert(Document(fromName: "GCOR"), at: i); i+=1
        for document in documents{
            document.versions["1.0"] = Version(fromVersionNumber: "1.0")
        }
//        objects.insert("  GOI", at: i); i+=1
//        objects.insert("  CROR", at: i); i+=1
//        objects.insert("  GCOR", at: i); i+=1
        
        //let indexPath = IndexPath(row: 0, section: 0)
        //tableView.insertRows(at: [indexPath], with: .automatic)
        let GOIAlreadySaved = fileAlreadySaved(url: "http://www.tcrcmoosejaw.ca/TCRCAttach/Documents/GOI%202009.pdf", fileName: "GOI",fileNameExtension: "pdf")
        let CRORAlreadySaved = fileAlreadySaved(url: "https://www.tc.gc.ca/media/documents/railsafety/CROR_English_May_18_2018_Web_Services.pdf", fileName: "CROR", fileNameExtension: "pdf")
        let GCORAlreadySaved = fileAlreadySaved(url: "http://fwwr.net/assets/gcor-effective-2015-04-01.pdf", fileName: "GCOR", fileNameExtension: "pdf")
        let secondGOISummaryAlreadySaved = fileAlreadySaved(url: "http://chtr.ca/operations/general-rail-operating-instruction/", fileName: "secondGOISummary", fileNameExtension: "html")
        
        GOIAlreadySaved ? () : saveFileFromService(urlString: "http://www.tcrcmoosejaw.ca/TCRCAttach/Documents/GOI%202009.pdf", fileName: "GOI", fileNameExtension: "pdf", version: documents[0].versions["1.0"]!)
        CRORAlreadySaved ? () : saveFileFromService(urlString: "https://www.tc.gc.ca/media/documents/railsafety/CROR_English_May_18_2018_Web_Services.pdf", fileName: "CROR", fileNameExtension: "pdf", version: documents[1].versions["1.0"]!)
        GCORAlreadySaved ? () : saveFileFromService(urlString: "http://fwwr.net/assets/gcor-effective-2015-04-01.pdf", fileName: "GCOR", fileNameExtension: "pdf", version: documents[2].versions["1.0"]!)
        secondGOISummaryAlreadySaved ? () : saveFileFromService(urlString: "http://chtr.ca/operations/general-rail-operating-instruction/", fileName: "secondGOISummary", fileNameExtension: "html", version: documents[2].versions["1.0"]!)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    @objc
    func insertNewObject(_ sender: Any) {
        //objects.insert(NSDate(), at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                //let object = objects[indexPath.row] as! String
                let documentName = documents[indexPath.row].Name
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                //controller.isWebView = indexPath.row <= 3 ? true : false
                if(documentName.contains("GOI")){
                    controller.filenameOrURL = "GOI"
                }
                else if (documentName.contains("CROR")){
                    controller.filenameOrURL = "CROR"
                }
                else if(documentName.contains("GCOR")){
                    //controller.filenameOrURL = "http://fwwr.net/assets/gcor-effective-2015-04-01.pdf"
                    controller.filenameOrURL = "GCOR"
                }
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
        
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return objects.count
        return documents.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        //let object = objects[indexPath.row] as! String
        let documentName = documents[indexPath.row].Name
        cell.textLabel!.text = "  " + documentName
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            objects.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        } else if editingStyle == .insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
//        }
//    }

    func saveFileFromService(urlString:String, fileName:String, fileNameExtension:String, version: Version) {
        DispatchQueue.main.async {
            let url = URL(string: urlString)
            do{
                _ = try String(contentsOf: url!, encoding: String.Encoding.utf16)
            } catch{
                print("Error")
            }
            
            let fileData = try? Data.init(contentsOf: url!)
            let resourceDocPath = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
            let fileNameFromUrl = "rdma-\(fileName).\(fileNameExtension)"
            let actualPath = resourceDocPath.appendingPathComponent(fileNameFromUrl)
            version.filePath = actualPath
            do {
                try fileData?.write(to: actualPath, options: .atomic)
                print("pdf successfully saved!")
            } catch {
                print("Pdf could not be saved")
            }
        }
    }
    
    func setSummary(urlString:String, fileName:String, fileNameExtension:String, summary: Summary) {
        DispatchQueue.main.async {
            let url = URL(string: urlString)
            do{
                _ = try String(contentsOf: url!, encoding: String.Encoding.utf16)
            } catch{
                print("Error")
            }
            
            let fileData = try? Data.init(contentsOf: url!)
            let resourceDocPath = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
            let fileNameFromUrl = "rdma-\(fileName).\(fileNameExtension)"
            let actualPath = resourceDocPath.appendingPathComponent(fileNameFromUrl)
            //summary.filePath = actualPath
            summary.Content = String(data: fileData!, encoding: String.Encoding.utf16)!
            do {
                try fileData?.write(to: actualPath, options: .atomic)
                print("pdf successfully saved!")
            } catch {
                print("Pdf could not be saved")
            }
        }
    }
    
    
    // check to avoid saving a file multiple times
    func fileAlreadySaved(url:String, fileName:String, fileNameExtension:String)-> Bool {
        var status = false
        if #available(iOS 10.0, *) {
            do {
                let docURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let contents = try FileManager.default.contentsOfDirectory(at: docURL, includingPropertiesForKeys: [.fileResourceTypeKey], options: .skipsHiddenFiles)
                for url in contents {
                    if url.description.contains("rdma-\(fileName).\(fileNameExtension)") {
                        status = true
                    }
                }
            } catch {
                print("could not locate pdf file !!!!!!!")
            }
        }
        return status
    }

}

