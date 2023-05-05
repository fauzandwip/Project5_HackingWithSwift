//
//  ViewController.swift
//  Project5
//
//  Created by Fauzan Dwi Prasetyo on 20/04/23.
//

import UIKit

class ViewController: UITableViewController {
    
    var anagrams = [Anagram]()
    var anagram = Anagram(word: "Default", usedWords: [])
    var allWords = [String]()
    var word: String!
    
    var defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
        
        loadData()
        loadResource()
        startGame()
        
    }
    
    func loadResource() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
    }
    
    func loadData() {
        if let savedData = defaults.object(forKey: "anagrams") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                anagrams = try jsonDecoder.decode([Anagram].self, from: savedData)
                for anagram in anagrams {
                    print(anagram.word)
                    print(anagram.usedWords)
                }
            } catch {
                print("Failed to load anagrams.")
            }
        }
    }
    
    func saveData() {
        let jsonEncoder = JSONEncoder()
        
        do {
            let savedData = try jsonEncoder.encode(anagrams)
            defaults.set(savedData, forKey: "anagrams")
        } catch {
            print("Failed to save anagrams.")
        }
    }
    
    @objc func startGame() {
        word = allWords.randomElement()
        title = word
        
        if !anagrams.contains(where: { $0.word.contains(word) }) {
            anagrams.append(Anagram(word: word, usedWords: []))
        }
        anagram = anagrams.filter{ $0.word.contains(word)}[0]
        
        tableView.reloadData()
    }
    
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] action in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()

        let errorTitle: String
        let errorMessage: String

        if isPossible(lowerAnswer) {
            if isOriginal(lowerAnswer) {
                if isReal(lowerAnswer) {
                    anagram.usedWords.insert(lowerAnswer, at: 0)
                    saveData()
                    
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    
                    return
                } else {
                    errorTitle = "Word not recognised"
                    errorMessage = "You can't just make them up, you know!"
                    
                    showErrorMsg(title: errorTitle, msg: errorMessage)
                }
            } else {
                errorTitle = "Word used already"
                errorMessage = "Be more original!"
                
                showErrorMsg(title: errorTitle, msg: errorMessage)
            }
        } else {
            guard let title = title?.lowercased() else { return }
            errorTitle = "Word not possible"
            errorMessage = "You can't spell that word from \(title)"
            
            showErrorMsg(title: errorTitle, msg: errorMessage)
        }
    }
    
    func isPossible(_ word: String) -> Bool {
        guard var tempWord = title?.lowercased() else { return false }
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isOriginal(_ word: String) -> Bool {
        return !anagram.usedWords.contains(word)
    }
    
    func isReal(_ word: String) -> Bool {
        
        if word.count < 3 {
            return false
        }
        
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func showErrorMsg(title: String, msg: String) {
        let ac = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))

        present(ac, animated: true)
    }
}


// MARK: - UITableViewController method

extension ViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return anagram.usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WordCell", for: indexPath)
        
        cell.textLabel?.text = anagram.usedWords[indexPath.row]
        
        return cell
    }
}
