//
//  DetailViewController.swift
//  iosApp3
//
//  Created by User1 RDMA on 2018-10-28.
//  Copyright © 2018 CP. All rights reserved.
//

import UIKit
import WebKit
import PDFKit

class DetailViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    var webView: WKWebView!
    var pdfView: PDFView!
    var isWebView: Bool!// if not true then pdfView to be shown
    let toolView = ToolView.instanceFromNib()
    var pdfdocument: PDFDocument?
    
    func configureView() {
        // Update the user interface for the detail item.
//        if let detail = detailItem {
//            if let label = detailDescriptionLabel {
//                label.text = detail.description
//            }
//        }
        
        if let filenameorurl = filenameOrURL{
            // Following three lines are for direct loading from internet
//             if let urll = URL(string:String(filenameorurl)){
//                 // Following two lines are for direct loading from internet
//                 webView.load(URLRequest(url: urll))
//                 webView.allowsBackForwardNavigationGestures = true
//                 webView.isMultipleTouchEnabled = true
//                 webView.isUserInteractionEnabled = true
//             }
            //    Uncomment for local viewing
            if let urll = URL(string:String("\(filenameorurl).pdf")){
                do {
                let docURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                    let contents = try FileManager.default.contentsOfDirectory(at: docURL, includingPropertiesForKeys: [.fileResourceTypeKey], options: .skipsHiddenFiles)
                    for url in contents {
                        if url.description.contains("iOSApp3-\(filenameorurl).pdf") {
                            if isWebView {
                                // its your file! do what you want with it!
                                //view.delete(pdfView)
                                //pdfView = nil
                                pdfView.removeFromSuperview()
                                webView.load(URLRequest(url:url))
                            }
                            else{
                                //////////// Trying to use pdfview now //////////
                                
                                if let document = PDFDocument(url: url) {
                                    pdfdocument = document
                                    pdfView.document = pdfdocument
                                }
                                //////////// Ends - Trying to use pdfview now //////////
                            }
                            break
                        }
                    }
                } catch {
                    print("could not locate pdf file !!!!!!!")
                }
            }
        }
    }
    override func loadView() {
        //if isWebView == nil {return}
        //if isWebView && webView == nil{
            webView = WKWebView()
            webView.uiDelegate = self
            webView.navigationDelegate = self
            webView.allowsBackForwardNavigationGestures = true
            webView.isMultipleTouchEnabled = true
            webView.isUserInteractionEnabled = true
            
            //view.addSubview(webView) // causes exception
            view = webView
        //}
        //else if !isWebView && pdfView == nil { // it's pdfView
            //pdfView = PDFView()
            pdfView = PDFView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
            pdfView.translatesAutoresizingMaskIntoConstraints = false
            //pdfView.usePageViewController(true, withViewOptions: nil)
            pdfView.displayMode = .singlePageContinuous
            pdfView.autoScales = true
            pdfView.displayDirection = .vertical
            //pdfView.document = pdfDocument
            //view = pdfView // not working
            view.addSubview(pdfView)
        
            pdfView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
            pdfView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
            pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            pdfView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        toolView.frame = CGRect(x: 10, y: view.frame.height - 50, width: self.view.frame.width - 20, height: 40)
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
        
        //self.view.addSubview(toolView)
        //toolView.bringSubviewToFront(self.view)
        
        toolView.thumbBtn.addTarget(self, action: #selector(thumbBtnClick), for: .touchUpInside)
        toolView.outlineBtn.addTarget(self, action: #selector(outlineBtnClick), for: .touchUpInside)
        toolView.searchBtn.addTarget(self, action: #selector(searchBtnClick), for: .touchUpInside)
        
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(tapGesture(_:)))
        view.addGestureRecognizer(tapgesture)
        
        //  guard let path = Bundle.main.url(forResource: "GOI", withExtension: "pdf") else { return }
        //}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

//    var detailItem: NSDate? {
//        didSet {
//            // Update the view.
//            configureView()
//        }
//    }
    var filenameOrURL: String?{
        didSet {
            loadView()
            configureView()
        }
    }
    
//    func showSavedPdf(url:String, fileName:String) {
//        if #available(iOS 10.0, *) {
//            do {
//                let docURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
//                let contents = try FileManager.default.contentsOfDirectory(at: docURL, includingPropertiesForKeys: [.fileResourceTypeKey], options: .skipsHiddenFiles)
//                for url in contents {
//                    if url.description.contains("\(fileName).pdf") {
//                        // its your file! do what you want with it!
//
//                    }
//                }
//            } catch {
//                print("could not locate pdf file !!!!!!!")
//            }
//        }
//    }
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        // Hide the Navigation Bar
//        self.navigationController?.setNavigationBarHidden(true, animated: animated)
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//
//        // Show the Navigation Bar
//        self.navigationController?.setNavigationBarHidden(false, animated: animated)
//    }
 
    @objc func tapGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        UIView.animate(withDuration: CATransaction.animationDuration()) { [weak self] in
            self?.toolView.alpha = 1 - (self?.toolView.alpha)!
        }
    }
    
    @objc func thumbBtnClick(sender: UIButton!) {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 20
        
        let width = (view.frame.width - 10 * 4) / 3
        let height = width * 1.5
        
        layout.itemSize = CGSize(width: width, height: height)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        let thumbnailGridViewController = ThumbnailGridViewController(collectionViewLayout: layout)
        thumbnailGridViewController.pdfDocument = pdfdocument
        thumbnailGridViewController.delegate = self
        
        let nav = UINavigationController(rootViewController: thumbnailGridViewController)
        self.present(nav, animated: false, completion:nil)
    }
    
    @objc func outlineBtnClick(sender: UIButton) {
        
        if let pdfoutline = pdfdocument?.outlineRoot {
            let oulineViewController = OulineTableviewController(style: UITableView.Style.plain)
            oulineViewController.pdfOutlineRoot = pdfoutline
            oulineViewController.delegate = self
            
            let nav = UINavigationController(rootViewController: oulineViewController)
            self.present(nav, animated: false, completion:nil)
        }
        
    }
    
    @objc func searchBtnClick(sender: UIButton) {
        let searchViewController = SearchTableViewController()
        searchViewController.pdfDocument = pdfdocument
        searchViewController.delegate = self
        
        let nav = UINavigationController(rootViewController: searchViewController)
        self.present(nav, animated: false, completion:nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension DetailViewController: OulineTableviewControllerDelegate {
    func oulineTableviewController(_ oulineTableviewController: OulineTableviewController, didSelectOutline outline: PDFOutline) {
        let action = outline.action
        if let actiongoto = action as? PDFActionGoTo {
            pdfView.go(to: actiongoto.destination)
        }
    }
}

extension DetailViewController: ThumbnailGridViewControllerDelegate {
    func thumbnailGridViewController(_ thumbnailGridViewController: ThumbnailGridViewController, didSelectPage page: PDFPage) {
        pdfView.go(to: page)
    }
}

extension DetailViewController: SearchTableViewControllerDelegate {
    func searchTableViewController(_ searchTableViewController: SearchTableViewController, didSelectSerchResult selection: PDFSelection) {
        selection.color = UIColor.yellow
        pdfView.currentSelection = selection
        pdfView.go(to: selection)
    }
}
