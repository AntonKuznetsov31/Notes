//
//  NoteDetailViewController.swift
//  Notes
//
//  Created by Anton Kuznetsov on 5/17/19.
//  Copyright © 2019 AntonKuznetsov. All rights reserved.
//

import UIKit

class NoteDetailsViewController: UIViewController, UITextViewDelegate {
    
    var note: Note? = nil
    var isEditingAllowed = false
    @IBOutlet weak var noteDetails: UITextView!
    
    override func viewWillAppear(_ animated: Bool) {
        guard let note = note else { return }
        noteDetails.text = note.noteText
        
        let shareButton = UIBarButtonItem(barButtonSystemItem:.action, target: self, action: #selector(shareButtonPressed))
        
        let editButton = UIBarButtonItem(barButtonSystemItem:.edit, target: self, action: #selector(editButtonPressed))
        self.navigationItem.rightBarButtonItems = [editButton, shareButton]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noteDetails.delegate = self
    }
    
    @objc func editButtonPressed() {
        isEditingAllowed = true
        noteDetails.becomeFirstResponder()
    }
    
    @objc func shareButtonPressed() {
        if !noteDetails.text.isEmpty {
            let noteText = noteDetails.text!
            let textToShare = [noteText]
            let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    @objc func doneButtonPressed() {
        saveNoteChanges()
    }
    
    // MARK: - Text view delegate
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if isEditingAllowed == false {
            return false
        }
        
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        let doneButton = UIBarButtonItem(barButtonSystemItem:.done, target: self, action: #selector(doneButtonPressed))
        self.navigationItem.rightBarButtonItem = doneButton
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        saveNoteChanges()
    }
    
    func saveNoteChanges() {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            if !noteDetails.text.isEmpty && note?.noteText != noteDetails.text {
                note?.noteText = noteDetails.text
                note?.date = Date()
            }
            do {
                try context.save()
            } catch let error as NSError {
                print("Error \(error), \(error.userInfo)")
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
}
