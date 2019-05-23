//
//  NotesViewController.swift
//  Notes
//
//  Created by Anton Kuznetsov on 5/16/19.
//  Copyright © 2019 AntonKuznetsov. All rights reserved.
//

import UIKit
import CoreData

class NotesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var filterButton: UIBarButtonItem!
    
    var fetchedResultsController: NSFetchedResultsController <Note>!
    var selectedNote: Note? = nil
    var notes: [Note] = []
    var isFilterDescending = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        fetchNotesFromCoreData()
    }
    
    @IBAction func filterButtonPressed(_ sender: UIBarButtonItem) {
        if isFilterDescending == false {
            filterButton.image = UIImage(named: "descending")
            notes.sort() {$0.date! > $1.date!}
            isFilterDescending = true
        } else {
            filterButton.image = UIImage(named: "ascending")
            notes.sort() {$0.date! < $1.date!}
            isFilterDescending = false
        }
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "noteDetails" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            guard let destinationVC = segue.destination as? NoteDetailsViewController else { return }
            destinationVC.note = notes[indexPath.row]
        }
    }
    
    func fetchNotesFromCoreData() {
        let request: NSFetchRequest <Note> = Note.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        request.fetchBatchSize = 20
        
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultsController.delegate = self as NSFetchedResultsControllerDelegate
            
            do {
                try fetchedResultsController.performFetch()
                notes = fetchedResultsController.fetchedObjects!
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell") as! NoteTableViewCell
        
        let currentNote = notes[indexPath.row]
        
        // working with note date
        guard let date = currentNote.date else { return cell }
        
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd.MM.yyyy"
        let timeFormat = DateFormatter()
        timeFormat.dateFormat = "HH:mm"
        
        cell.date.text = dateFormat.string(from: date)
        cell.time.text = timeFormat.string(from: date)
        
        // working with note text
        guard let text = currentNote.noteText else { return cell }
        if text.count >= 100 {
            let index = text.index(text.startIndex, offsetBy: 100)
            let mySubstring = text[..<index]
            cell.noteText.text = mySubstring + "..."
        } else {
            cell.noteText.text = text
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    // MARK: - Table view delegate
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            self.notes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
                
                let objectToDelete = self.fetchedResultsController.object(at: indexPath)
                context.delete(objectToDelete)
                
                do {
                    try context.save()
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
        }
        return [delete]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Search bar delegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != "" {
            var predicate: NSPredicate = NSPredicate()
            predicate = NSPredicate(format: "noteText contains[c] '\(searchText)'")
            
            if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
                let fetchRequest: NSFetchRequest <Note> = Note.fetchRequest()
                fetchRequest.predicate = predicate
                
                do {
                    notes = try context.fetch(fetchRequest)
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
        } else {
            fetchNotesFromCoreData()
        }
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }
    
    // MARK: - Fetch Results Controller Delegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert: guard let indexPath = newIndexPath else { break }
        tableView.insertRows(at: [indexPath], with: .fade)
        case .delete: guard let indexPath = newIndexPath else { break }
        tableView.deleteRows(at: [indexPath], with: .fade)
        case .update: guard let indexPath = newIndexPath else { break }
        tableView.reloadRows(at: [indexPath], with: .fade)
        default:
            tableView.reloadData()
        }
        notes = controller.fetchedObjects as! [Note]
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
