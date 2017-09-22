//
//  DetailViewController.swift
//  DataLogger
//
//  Created by Ben Kreeger on 9/21/17.
//  Copyright © 2017 Ben Kreeger. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    
    private(set) var isDisplayingEntry: Bool = false
    
    private lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .long
        df.timeStyle = .medium
        return df
    }()

    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configure(for: nil)
    }
    
    
    // MARK: Public functions
    
    func configure(for dataEntry: DataEntry?) {
        isDisplayingEntry = dataEntry != nil
        
        loadViewIfNeeded()
        bodyLabel.text = dataEntry?.content
        if let date = dataEntry?.created {
            dateLabel.text = dateFormatter.string(from: date)
        } else {
            dateLabel.text = nil
        }
    }
}

