//
//  CreateNoteViewController.swift
//  Notes
//
//  Created by Anton Kuznetsov on 5/19/19.
//  Copyright © 2019 AntonKuznetsov. All rights reserved.
//

import UIKit
import CoreData

class CreateNoteViewController: UIViewController {
    
    @IBOutlet weak var noteText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        noteText.becomeFirstResponder()
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        noteText.resignFirstResponder()
        self.dismiss(animated: true)
    }
    
    @IBAction func saveAction(_ sender: UIBarButtonItem) {
        if !noteText.text.isEmpty {
            guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else { return }
            
            let newNote = Note(context: context)
            newNote.noteText = noteText.text
            newNote.date = Date()
            
            do {
                try context.save()
                
            } catch let error as NSError {
                print("Error \(error), \(error.userInfo)")
            }
            noteText.resignFirstResponder()
            self.dismiss(animated: true)
        }
    }
}
