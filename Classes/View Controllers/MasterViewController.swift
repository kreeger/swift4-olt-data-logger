//
//  MasterViewController.swift
//  DataLogger
//
//  Created by Ben Kreeger on 9/21/17.
//  Copyright © 2017 Ben Kreeger. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {
    enum Segue: String {
        case showDetail
        case showCreate
        
        init(segue: UIStoryboardSegue) {
            self.init(rawValue: segue.identifier!)!
        }
    }
    
    var detailViewController: DetailViewController?
    var dataSource: DataEntryDataSource!
    
    private lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .medium
        return df
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "All", style: .plain, target: nil, action: nil)
        
        dataSource.fetchEntries { [weak self] error in
            if let error = error {
                self?.displayError(error)
                return
            }
            
            self?.tableView.reloadData()
        }
        
        navigationItem.leftBarButtonItem = editButtonItem
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers.last as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch Segue(segue: segue) {
        case .showCreate:
            let navVC = segue.destination as! UINavigationController
            let controller = navVC.topViewController as! DataEntryEditViewController
            controller.delegate = self
            
        case .showDetail:
            guard
                let indexPath = tableView.indexPathForSelectedRow,
                let object = dataSource.entry(at: indexPath.row)
                else { return }
            
            let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
            controller.configure(for: object)
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
    }
    
    @IBAction func prepareForUnwind(_ segue: UIStoryboardSegue?) {
        print("Unwinding from create.")
    }

    
    // MARK: UITableViewController

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.numberOfEntries
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if let object = dataSource.entry(at: indexPath.row) {
            cell.detailTextLabel?.text = dateFormatter.string(from: object.created)
                cell.textLabel?.text = object.content
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            guard let entry = dataSource.entry(at: indexPath.row) else { return }
            dataSource.delete(entry) { [weak self] error in
                if let error = error {
                    tableView.insertRows(at: [indexPath], with: .fade)
                    self?.displayError(error)
                    return
                }
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        default:
            break
        }
    }


    // MARK: Private functions
    
    private func displayError(_ error: Error) {
        print(error.localizedDescription)
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default) { [weak self] _ in self?.dismiss(animated: true, completion: nil) })
        present(alert, animated: true, completion: nil)
    }
}


extension MasterViewController: DataEntryEditViewControllerDelegate {
    func dataEntryEditViewController(_ viewController: DataEntryEditViewController, wantsToCreateDataEntryWith bodyCopy: String) {
        let newEntry = DataEntry(content: bodyCopy, created: Date())
        dataSource.commit(newEntry) { [weak self] newIndex, error in
            if let error = error {
                self?.displayError(error)
                return
            }
            
            let indexPath = IndexPath(row: newIndex, section: 0)
            self?.tableView.insertRows(at: [indexPath], with: .fade)
            self?.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .top)
            self?.performSegue(withIdentifier: Segue.showDetail.rawValue, sender: nil)
            self?.dismiss(animated: true, completion: nil)
        }
    }
}

