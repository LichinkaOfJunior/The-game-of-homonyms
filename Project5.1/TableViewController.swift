import UIKit

class TableViewController: UITableViewController {
    
    var allWord: [String] = []
    var usedWord = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForUser))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
        
        if let startWordsPath = Bundle.main.path(forResource: "start", ofType: "txt") {
            if let startWord = try? String(contentsOfFile: startWordsPath) {
                allWord = startWord.components(separatedBy: "\n")
            }
        }
        
        startGame()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        usedWord.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWord[indexPath.row]
        return cell
    }
    
    @objc func startGame() {
        title = allWord.randomElement()
        usedWord.removeAll()
        tableView.reloadData()
    }
    
    
    @objc func promptForUser() {
        
        let ac = UIAlertController(title: "Enter word", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { _ in
            guard let answer = ac.textFields?[0].text else { return }
            self.submit(answer)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func submit(_ answer: String) {
        
        let lowerAnswer = answer.lowercased()
        
        if isReal(lowerAnswer) {
            if isPossible(lowerAnswer) {
                if isOriginal(lowerAnswer) {
                    
                    usedWord.insert(answer, at: 0)
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    return
                } else {
                    showErrorMessage("isOriginal")
                }
            } else {
                showErrorMessage("isPossible")
            }
        } else {
            showErrorMessage("isReal")
        }
        
        
        func isReal(_ answer: String) -> Bool {
            
            
            let checker = UITextChecker()
            let range = NSRange(location: 0, length: answer.utf16.count)
            let misspellRange = checker.rangeOfMisspelledWord(in: answer, range: range, startingAt: 0, wrap: false, language: "en")
            
            return misspellRange.location == NSNotFound && answer != title && answer.count >= 3
        }
        
        func isOriginal(_ answer: String) -> Bool {
     
            for word in usedWord {
                if word.lowercased() == answer {
                    return false
                }
            }
            return true
        }
        
        func isPossible(_ answer: String) -> Bool {
            
            var title = title
            
            for letter in answer {
                if let index = title?.firstIndex(of: letter) {
                    title?.remove(at: index)
                } else {
                    return false
                }
            }
            return true
        }
        
    }
    
    func showErrorMessage(_ keyFunction: String) {
        
        var errorTitle: String
        var errorMessage: String
        
        switch keyFunction {
        case "isReal" :
            errorTitle = "Invalid Word"
            errorMessage = "The word you entered is not a real word. Please enter a valid word."
        case "isPossible":
            errorTitle = "Word Not Possible"
            errorMessage = "The word you entered cannot be made from the given title. Please enter a different word."
        case "isOriginal":
            errorTitle = "Word Already Used"
            errorMessage = "The word you entered has already been used. Please enter a different word."
        default: return
        }
        
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        present(ac, animated: true)
        
    }
}
