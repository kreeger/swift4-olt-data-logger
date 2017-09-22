//
//  DataEntryEditViewController.swift
//  DataLogger
//
//  Created by Ben Kreeger on 9/21/17.
//  Copyright © 2017 Ben Kreeger. All rights reserved.
//

import UIKit


protocol DataEntryEditViewControllerDelegate: class {
    func dataEntryEditViewController(_ viewController: DataEntryEditViewController, wantsToCreateDataEntryWith bodyCopy: String)
}

class DataEntryEditViewController: UIViewController {
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem! {
        didSet {
            saveButton.isEnabled = false
        }
    }
    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.textContainerInset = textView.layoutMargins
        }
    }
    
    weak var delegate: DataEntryEditViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure(for: nil)
    }
    
    // MARK: Lifecycle
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.regular, .regular):
            navigationItem.leftBarButtonItem = nil
        default:
            navigationItem.leftBarButtonItem = cancelButton
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        textView.resignFirstResponder()
    }
    
    // MARK: Public functions
    
    func configure(for dataEntry: DataEntry?) {
        textView.text = dataEntry?.content ?? ""
        saveButton.isEnabled = !textView.text.isEmpty
    }
    
    
    // MARK: IBActions
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        guard let text = textView.text else { return }
        delegate?.dataEntryEditViewController(self, wantsToCreateDataEntryWith: text)
    }
}

extension DataEntryEditViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newString = (textView.text as NSString).replacingCharacters(in: range, with: text)
        saveButton.isEnabled = !newString.isEmpty
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        saveButton.isEnabled = !textView.text.isEmpty
    }
}
