//
//  ViewController.swift
//  PDF-Demo
//
//  Created by Mani Sareen.
//  Copyright © CP. All rights reserved.
//

import UIKit
import PDFKit
import WebKit

class DetailViewController: UIViewController, UIWebViewDelegate, WKNavigationDelegate {
    var masterViewController: MasterViewController? = nil
    var documents: [Document]? = nil
    var pdfdocument: PDFDocument?
    
    var pdfview: PDFView!
    var pdfthumbView: PDFThumbnailView!
    let toolView = ToolView.instanceFromNib()
    weak var observe : NSObjectProtocol?
    
    var maskView: UIView!
    var webview: WKWebView!
    @IBOutlet weak var viewForEmbeddingWebView: UIView!
    
    var GOISummaries: [String] = []
    var GOISummaryNumber = 0
    
    var filenameOrURL: String?{
        didSet {
            loadView()
            //configureView()
            viewDidLoad()
        }
    }
    
    //func setMask(with hole: CGRect, in view: UIView){
        
        // Create a mutable path and add a rectangle that will be h
        //let mutablePath = CGMutablePath()
        //mutablePath.addRect(view.bounds)
        //mutablePath.addRect(hole)
        
        // Create a shape layer and cut out the intersection
        //let mask = CAShapeLayer()
        //mask.path = mutablePath
        //mask.fillRule = CAShapeLayerFillRule.evenOdd
        
        // Add the mask to the view
        //view.layer.mask = mask
        
    //}
    
    func getCloseButton(frame: CGRect, color: UIColor) -> UIButton? {
        guard frame.size.width == frame.size.height else { return nil }
        let button = UIButton(type: .custom)
        button.frame = frame
        button.setTitleColor(color, for: .normal)
        button.setTitle("X", for: .normal)
        button.layer.borderColor = color.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = frame.size.height / 2.0
        button.addTarget(self, action: #selector(DetailViewController.closeButtonAction(_:)), for: .touchUpInside)
        return button
    }
    func getLeftButton(frame: CGRect, color: UIColor) -> UIButton? {
        guard frame.size.width == frame.size.height else { return nil }
        let button = UIButton(type: .custom)
        button.frame = frame
        button.setTitleColor(color, for: .normal)
        button.setTitle("<", for: .normal)
        button.layer.borderColor = color.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = frame.size.height / 2.0
        button.addTarget(self, action: #selector(DetailViewController.leftButtonAction(_:)), for: .touchUpInside)
        return button
    }
    func getRightButton(frame: CGRect, color: UIColor) -> UIButton? {
        guard frame.size.width == frame.size.height else { return nil }
        let button = UIButton(type: .custom)
        button.frame = frame
        button.setTitleColor(color, for: .normal)
        button.setTitle(">", for: .normal)
        button.layer.borderColor = color.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = frame.size.height / 2.0
        button.addTarget(self, action: #selector(DetailViewController.rightButtonAction(_:)), for: .touchUpInside)
        return button
    }
    func getAckButton(frame: CGRect, color: UIColor) -> UIButton? {
        let button = UIButton()
        //let button = UIButton(type: .custom)
        button.frame = frame
        button.backgroundColor = .black
        //button.buttonType = UIButton.ButtonType.System
//        button.setTitleColor(color, for: .normal)
//        button.setTitle("Acknowledge", for: .normal)
//        button.layer.borderColor = color.cgColor
//        button.layer.borderWidth = 1
//        button.layer.cornerRadius = frame.size.height / 2.0
//        button.addTarget(self, action: #selector(DetailViewController.rightButtonAction(_:)), for: .touchUpInside)
        
        button.setTitle("Acknowlege", for: UIControl.State.normal)
        button.setTitle("Acknowleged", for: UIControl.State.disabled)
        //button.style = .plain
        //button. .targ target = self
        //action = #selector(sayHello(sender:))
        button.addTarget(self, action: #selector(DetailViewController.ackButtonAction(_:)), for: .touchUpInside)
        
        return button
    }
    
    @objc func closeButtonAction(_ sender:UIButton!){
        webview.removeFromSuperview()
        maskView.removeFromSuperview()
        pdfview.layer.mask = nil;
    }
    @objc func leftButtonAction(_ sender:UIButton!){
        if GOISummaryNumber > 0{
            GOISummaryNumber -= 1
            loadSummary(wkwebview: webview, pathURLOrText: GOISummaries[GOISummaryNumber])
        }
    }
    @objc func rightButtonAction(_ sender:UIButton!){
        if GOISummaryNumber < (GOISummaries.count - 1){
            GOISummaryNumber += 1
            loadSummary(wkwebview: webview, pathURLOrText: GOISummaries[GOISummaryNumber])
        }
    }
    @objc func ackButtonAction(_ sender:UIButton!){
        //sender.isEnabled = false
        //sender.backgroundColor = .gray
        if GOISummaryNumber < (GOISummaries.count - 1){
            GOISummaryNumber += 1
            loadSummary(wkwebview: webview, pathURLOrText: GOISummaries[GOISummaryNumber])
        }
        else{
            webview.removeFromSuperview()
            maskView.removeFromSuperview()
            pdfview.layer.mask = nil;
        }
    }
    
    func loadSummary(wkwebview:WKWebView, pathURLOrText: String){
        let urlSummary = URL(string:pathURLOrText)
        if pathURLOrText.contains("secondGOISummary"){
            let req = URLRequest(url:urlSummary!)
            wkwebview.load(req)
        }
        else{
            wkwebview.loadHTMLString(pathURLOrText, baseURL: nil)
            //wkwebview.loadFileURL(URL(string: pathURLOrText)!, allowingReadAccessTo: URL(string: pathURLOrText)!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            masterViewController = (controllers[0] as! UINavigationController).topViewController as? MasterViewController
            documents = masterViewController?.documents
        }
        
        if filenameOrURL == nil { return }
        toolView.frame = CGRect(x: 10, y: view.frame.height - 50, width: self.view.frame.width - 20, height: 40)
        
        pdfview = PDFView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        
        //let url = Bundle.main.url(forResource: "sample", withExtension: "pdf")
        //let url = URL(string:String("\(String(describing: filenameOrURL)).pdf"))
        do{
            let docURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let contents = try FileManager.default.contentsOfDirectory(at: docURL, includingPropertiesForKeys: [.fileResourceTypeKey], options: .skipsHiddenFiles)
            var secondGOISummaryFileURL: URL!
            if secondGOISummaryFileURL == nil{
                for url in contents {
                    if url.description.contains("rdma-secondGOISummary.html") {
                        secondGOISummaryFileURL = url
                        GOISummaries.append("<html><body bgcolor='#DC8CFE'><br/><center><h1>First Summary!</center><br/>\(firstGOISummary)</h1></body></html>")
                        GOISummaries.append(try! String.init(contentsOf: secondGOISummaryFileURL))
                        GOISummaries.append("<html><body bgcolor='#E6E6FA'><br/><center><h1>Third Summary!</h1></center></body></html>")
                        GOISummaries.append("<html><body bgcolor='#F35C3B'><br/><center><h1>Fourth and Last Summary!</h1></center></body></html>")
                    }
                }
            }
            for url in contents{
                if url.description.contains("rdma-\(filenameOrURL ?? "GOI").pdf") {
                    pdfdocument = PDFDocument(url: url)
                    pdfview.autoScales = true
                    pdfview.maxScaleFactor = 4.0
                    pdfview.minScaleFactor = pdfview.scaleFactorForSizeToFit
//                    pdfview.usePageViewController(true, withViewOptions: [UIPageViewController.OptionsKey.interPageSpacing: 20])
                    
                    self.title = filenameOrURL
                    
//                    let maskView = UIView(frame: CGRect(x: 64, y: 0, width:50, height:60))
//                    maskView.backgroundColor = .blue
//                    maskView.layer.cornerRadius = 64
//                    pdfview.mask = maskView
                    
                    maskView = UIView()
                    maskView.backgroundColor = UIColor(white: 0, alpha: 0.5) //you can modify this to whatever you need
                    maskView.frame = CGRect(x: 0, y: 0, width: pdfview.frame.width-10, height: pdfview.frame.height-10)
                    
//                    // Create the view (you can also use a view created in the storyboard)
//                    let newView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
//                    newView.backgroundColor = UIColor(white: 0, alpha: 1)
                    
                    // You can play with these values and find one that fills your need
                    let rectangularHole = CGRect(x: view.bounds.width*0.1, y: view.bounds.height*0.1, width: view.bounds.width*0.8, height: view.bounds.height*0.8)
                    webview = WKWebView(frame:rectangularHole, configuration: WKWebViewConfiguration())
                    webview.allowsBackForwardNavigationGestures = true
                    webview.isUserInteractionEnabled = true
                    
                    //webview.translatesAutoresizingMaskIntoConstraints = true
                    //self.view.addSubview(webview)
//                    webview.topAnchor.constraint(equalTo: pdfview.topAnchor).isActive = true
//                    webview.rightAnchor.constraint(equalTo: pdfview.rightAnchor).isActive = true
//                    webview.leftAnchor.constraint(equalTo: pdfview.leftAnchor).isActive = true
//                    webview.bottomAnchor.constraint(equalTo: pdfview.bottomAnchor).isActive = true
//                    webview.heightAnchor.constraint(equalTo: pdfview.heightAnchor).isActive = true
                    
                    //webview.uiDelegate = self
                    //webview.navigationDelegate = self
                    pdfview.addSubview(maskView)
                    // setMask(with: rectangularHole, in: pdfview) // this function not needed at all!
                    let closeButtonFrame = CGRect(x: 20, y: 20, width: 36, height: 36)
                    if let closeButton = getCloseButton(frame: closeButtonFrame, color: .white) {
                        webview.addSubview(closeButton)
                    }
                    let leftButtonFrame = CGRect(x: 20, y: 420, width: 36, height: 36)
                    if let leftButton = getLeftButton(frame: leftButtonFrame, color: .white) {
                        webview.addSubview(leftButton)
                    }
                    let rightButtonFrame = CGRect(x: 620, y: 420, width: 36, height: 36)
                    if let rightButton = getRightButton(frame: rightButtonFrame, color: .white) {
                        webview.addSubview(rightButton)
                    }
                    let ackButtonFrame = CGRect(x: 260, y: 800, width: 120, height: 50)
                    if let ackButton = getAckButton(frame: ackButtonFrame, color: .white) {
                        webview.addSubview(ackButton)
                    }
                    
                    loadSummary(wkwebview: webview, pathURLOrText: GOISummaries[GOISummaryNumber])
                    
                    maskView.addSubview(webview)
                    maskView.bringSubviewToFront(webview)
                    maskView.isUserInteractionEnabled = true
                    maskView.isMultipleTouchEnabled = true

                    // Set the mask in the pdfview

                    
                    break
                }
            }
        } catch {
            print("could not locate pdf file !!!!!!!")
        }
        
        
        pdfview.document = pdfdocument
        pdfview.displayMode = PDFDisplayMode.singlePageContinuous
        pdfview.autoScales = true
        
        self.view.addSubview(pdfview)
        
        self.view.addSubview(toolView)
        toolView.bringSubviewToFront(self.view)
        
        toolView.thumbBtn.addTarget(self, action: #selector(thumbBtnClick), for: .touchUpInside)
        toolView.outlineBtn.addTarget(self, action: #selector(outlineBtnClick), for: .touchUpInside)
        toolView.searchBtn.addTarget(self, action: #selector(searchBtnClick), for: .touchUpInside)
        
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(tapGesture(_:)))
        view.addGestureRecognizer(tapgesture)
    }
    
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
    
    let firstGOISummary = """
General Rules
Canadian Rail Operating Rules
Table of Contents
PDF Version
A Every employee in any service connected with movements, handling of main track switches and protection of track work and track units shall;

(i) be subject to and conversant with applicable CROR rules, special instructions and general operating instructions;

(ii) have a copy of this rule book, the general operating instructions, current time table and any supplements, and other documents specified by the company accessible while on duty;

(iii) provide every possible assistance to ensure every rule, special instruction and general operating instruction is complied with and shall report promptly to the proper authority any violations thereof;

(iv) communicate by the quickest available means to the proper authority any condition which may affect the safe operation of a movement and be alert to the company’s interest and join forces to protect it;

(v) obtain assistance promptly when it is required to control a harmful or dangerous condition;

(vi) be conversant with and governed by every safety rule and instruction of the company pertaining to their occupation;

(vii) pass the required examination at prescribed intervals, not to exceed three years, and carry while on duty, a valid certificate of rules qualification;

(viii) seek clarification from the proper authority if in doubt as to the meaning of any rule or instruction;

(ix) conduct themselves in a courteous and orderly manner;

(x) when reporting for duty, be fit, rested and familiar with their duties and the territory over which they operate;

(xi) while on duty, not engage in non-railway activities which may in any way distract their attention from the full performance of their duties. Except as provided for in company policies, sleeping or assuming the position of sleeping is prohibited. The use of personal entertainment devices is prohibited. Printed material not connected with the operation of movements or required in the performance of duty, must not be openly displayed or left in the operating cab of a locomotive or track unit or at any work place location utilized in train, transfer or engine control; and

(xii) restrict the use of communication devices to matters pertaining to railway operations. Cellular telephones must not be used when normal railway radio communications are available. When cellular telephones are used in lieu of radio all applicable radio rules must be complied with.
"""
    
}


extension DetailViewController: OulineTableviewControllerDelegate {
    func oulineTableviewController(_ oulineTableviewController: OulineTableviewController, didSelectOutline outline: PDFOutline) {
        let action = outline.action
        if let actiongoto = action as? PDFActionGoTo {
            pdfview.go(to: actiongoto.destination)
        }
    }
}

extension DetailViewController: ThumbnailGridViewControllerDelegate {
    func thumbnailGridViewController(_ thumbnailGridViewController: ThumbnailGridViewController, didSelectPage page: PDFPage) {
        pdfview.go(to: page)
    }
}

extension DetailViewController: SearchTableViewControllerDelegate {
    func searchTableViewController(_ searchTableViewController: SearchTableViewController, didSelectSerchResult selection: PDFSelection) {
        selection.color = UIColor.yellow
        pdfview.currentSelection = selection
        pdfview.go(to: selection)
    }
}

