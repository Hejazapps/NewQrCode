//
//  LogoVc.swift
//  NewQrMaker
//
//  Created by Sadiqul AMin on 25/2/26.
//

import UIKit

protocol DataPassDelegate: AnyObject {
    func didReceiveData1(_ logo: UIImage?)
}


class LogoVc: UIViewController, UITableViewDelegate, UITableViewDataSource, LogoCellDelegate {
    func didSelectLogo(_ image: UIImage?) {
        delegate?.didReceiveData1(image)
    }
    
   
    
    weak var delegate: DataPassDelegate?

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var holderView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "LogoCell", bundle: nil), forCellReuseIdentifier: "LogoCell")
        tableView.separatorColor = UIColor.clear
        tableView.reloadData()
        // Do any additional setup after loading the view.
    }
    

    @IBAction func dimsisView(_ sender: Any) {
        
        self.dismiss(animated: true)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        holderView.layer.cornerRadius = 20
        holderView.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner
        ]
        holderView.clipsToBounds = true
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "LogoCell", for: indexPath) as! LogoCell
        
       
        cell.selectionStyle = .none
        
        cell.delegate = self
        
        
      
        
        return cell
        
        
        
        
    }
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath)
    {
      
      
      
    }
    
}


