import UIKit
import Contacts

protocol ContactSelectionDelegate: AnyObject {
    func didSelectContact(_ contact: CNContact)
}


class ContactListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var co: UILabel!
    
    var contacts = [String: [CNContact]]()
    var filteredContactDictionary = [String: [CNContact]]() // Dictionary to hold contacts categorized by first letter
    var contactSectionTitles = [String]() // Array to hold section titles (first letters)
    let contactStore = CNContactStore()
    weak var delegate: ContactSelectionDelegate?
    
    @IBOutlet weak var searchBar: UISearchBar!
    
   
    @IBOutlet weak var backBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        requestContactsAccess()
        searchBar.showsCancelButton = true
        searchBar.delegate = self
     
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ContactCell")
        
        self.view.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 243/255, alpha: 1)

        searchBar.searchBarStyle = .default
        
        
        
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString.init(string: "Search", attributes: [NSAttributedString.Key.foregroundColor:UIColor.lightGray])
        searchBar.searchTextField.textColor = UIColor.black
        
        
        searchBar.isTranslucent = true
        searchBar.alpha = 1
        searchBar.backgroundImage = UIImage()
        searchBar.barTintColor = UIColor.clear
        tableView.separatorColor = UIColor.clear
        
        
        backBtn.setTitle("Back".localize(), for: .normal)
        co.text = "Contact".localize()
        
    }
    
    func requestContactsAccess() {
        contactStore.requestAccess(for: .contacts) { [weak self] (granted, error) in
            if granted {
                self?.fetchContacts()
            } else {
                // Handle denied access
                print("Access to contacts denied")
                DispatchQueue.main.async {
                    self?.showSettingsAlert()
                }
            }
        }
    }
    
    @IBAction func gotoPreviousView(_ sender: Any) {
        let transition = CATransition()
        transition.duration = 0.4
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        view.window?.layer.add(transition, forKey: "leftToRightTransition")
        dismiss(animated: false, completion: nil)
    }
    func fetchContacts() {
        
        
        
        let keysToFetch = [CNContactGivenNameKey,
                           CNContactFamilyNameKey,
                           CNContactPhoneNumbersKey,
                           CNContactEmailAddressesKey,
                           CNContactOrganizationNameKey,
                           CNContactJobTitleKey,
                           CNContactPostalAddressesKey,
                           CNContactUrlAddressesKey,
                           CNContactBirthdayKey,
                           CNContactMiddleNameKey,
                           
        ] as [CNKeyDescriptor]
        let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
        
        
        
        do {
            try contactStore.enumerateContacts(with: fetchRequest) { [weak self] (contact, _) in
                let firstLetter = String(contact.givenName.prefix(1)).uppercased()
                
                print("name found \(contact.givenName)")
                if contact.givenName.count > 0 {
                    if var contactsForLetter = self?.contacts[firstLetter] {
                        contactsForLetter.append(contact)
                        self?.contacts[firstLetter] = contactsForLetter
                    } else {
                        self?.contacts[firstLetter] = [contact]
                    }
                }
            }
            
            // Sort the contact section titles alphabetically
            self.contactSectionTitles = self.contacts.keys.sorted()
            
            DispatchQueue.main.async {
                self.filteredContactDictionary = self.contacts
                self.tableView.reloadData()
            }
        } catch let error {
            print("Failed to fetch contacts: \(error.localizedDescription)")
            // Show an alert to the user indicating the failure
            let alertController = UIAlertController(title: "error".localize(), message: "failed_to_fetch_contacts_message".localize(), preferredStyle: .alert)
            let okAction = UIAlertAction(title: "ok".localize(), style: .default, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func showSettingsAlert() {
        let alertController = UIAlertController(title: "access_to_contacts_denied".localize(), message: "grant_contacts_access_message".localize(), preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings".localize(), style: .default) { (_) in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel".localize(), style: .cancel, handler: nil)
        
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return contactSectionTitles
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20.0  // Set the desired height for the header
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  40.0  // Set the desired height for the cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return contactSectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionTitle = contactSectionTitles[section]
        return filteredContactDictionary[sectionTitle]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil // We no longer need to use this method for title
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        
        // Create a UILabel for the title
        let label = UILabel()
        label.text = contactSectionTitles[section]
        label.font = UIFont.systemFont(ofSize: 16)  // Customize the font if needed
        label.textColor = .black  // Customize the text color if needed
        
        // Add padding to the label by setting the frame or using constraints
        let padding: CGFloat = 16.0 // Adjust padding value as needed
        label.frame = CGRect(x: padding, y: 0, width: tableView.bounds.width - padding, height: 40)  // Adjust height as needed
        
        // Add the label to the header view
        headerView.addSubview(label)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "TableViewCell")  as! TableViewCell
        let sectionTitle = contactSectionTitles[indexPath.section]
        
        if let contactsForLetter = contacts[sectionTitle] {
            let contact = contactsForLetter[indexPath.row]
            cell.headerLabel
                .text = "\(contact.givenName) \(contact.familyName)"
            
        }
        cell.selectionStyle = .none
        
        
         
        
        return cell
    }

    // MARK: - Table View Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionTitle = contactSectionTitles[indexPath.section]
        if let contactsForLetter = contacts[sectionTitle] {
            let selectedContact = contactsForLetter[indexPath.row]
            self.dismiss(animated: true) {
                self.delegate?.didSelectContact(selectedContact)
            }
            
        }
    }
}


extension ContactListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
           if !searchText.isEmpty {
               let filteredContacts = contacts.flatMap { $0.value }.filter {
                   $0.givenName.localizedCaseInsensitiveContains(searchText) || $0.familyName.localizedCaseInsensitiveContains(searchText)
               }
               
               // Filter out duplicates from the filtered contacts
               var uniqueFilteredContacts = [CNContact]()
               var uniqueContactIDs = Set<String>()
               for contact in filteredContacts {
                   if !uniqueContactIDs.contains(contact.identifier) {
                       uniqueFilteredContacts.append(contact)
                       uniqueContactIDs.insert(contact.identifier)
                   }
               }
               
               let temp = Dictionary(grouping: uniqueFilteredContacts, by: { String($0.givenName.prefix(1)).uppercased() })
               filteredContactDictionary = temp
           } else {
               // If search bar is empty, reload all contacts
               filteredContactDictionary = self.contacts
           }
           tableView.reloadData()
       }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil // Clear search text
        searchBar.resignFirstResponder() // Dismiss keyboard
        // Restore original contacts
        filteredContactDictionary = self.contacts
        tableView.reloadData()
    }
}
