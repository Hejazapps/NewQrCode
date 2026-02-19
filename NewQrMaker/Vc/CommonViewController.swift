
import UIKit
import WebKit
import SVProgressHUD

class CommonViewController: UIViewController,WKNavigationDelegate {
    var url:String!
    
    
     
    
    @IBOutlet weak var tite: UILabel!
    @IBOutlet var webView: WKWebView!
    var titleForValue:String!
    override func viewDidLoad() {
        
        navigationController?.navigationBar.barTintColor = UIColor.systemBlue

        
        webView = WKWebView(frame:
            CGRect(x: 0, y: 100, width: UIScreen.main.bounds.width,
                   height: UIScreen.main.bounds.height - 100))

        DispatchQueue.main.async{
            SVProgressHUD.show()
        }
        super.viewDidLoad()
        let  urlf = URL(string: url)
        let urlRequest = URLRequest(url: urlf!)
        webView.navigationDelegate =  self
        webView.load(urlRequest)
        self.tite.text = titleForValue
        self.view.addSubview(webView)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func gotoPreviousView(_ sender: Any) {
        
        self.dismiss(animated: true)
    }
    func webView(_ webView: WKWebView,
                 didFinish navigation: WKNavigation!)
    {
        
        DispatchQueue.main.async{
            SVProgressHUD.dismiss()
        }
        
        
    }
    func webView(_ webView: WKWebView,
                 didFailProvisionalNavigation navigation: WKNavigation!,
                 withError error: Error)
    { DispatchQueue.main.async{
        SVProgressHUD.dismiss()
        }
        
        
    }
    
}
