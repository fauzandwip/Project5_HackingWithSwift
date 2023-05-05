//
//  Anagram.swift
//  Project5
//
//  Created by Fauzan Dwi Prasetyo on 05/05/23.
//

import Foundation

class Anagram: NSObject, Codable {
    
    var word: String
    var usedWords: [String]
    
    init(word: String, usedWords: [String]) {
        self.word = word
        self.usedWords = usedWords
    }
}
