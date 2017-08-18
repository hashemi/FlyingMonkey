//
//  Lexer.swift
//  FlyingMonkey
//
//  Created by Ahmad Alhashemi on 2017-08-18.
//  Copyright © 2017 Ahmad Alhashemi. All rights reserved.
//

struct Lexer {
    let input: String
    var position: String.Index
    var readPosition: String.Index
    var ch: Character
    
    init(_ input: String) {
        self.input = input
        self.position = input.startIndex
        self.readPosition = input.startIndex
        self.ch = "\0"
        self.readChar()
    }
    
    mutating func readChar() {
        if readPosition >= input.endIndex {
            ch = "\0"
            position = readPosition
        } else {
            ch = input[readPosition]
            position = readPosition
            readPosition = input.index(after: readPosition)
        }
    }
    
    mutating func nextToken() -> Token {
        let tok: Token
        
        skipWhitespace()
        
        switch ch {
        case "=": tok = Token(type: .assign, literal: String(ch))
        case ";": tok = Token(type: .semicolon, literal: String(ch))
        case "(": tok = Token(type: .lparen, literal: String(ch))
        case ")": tok = Token(type: .rparen, literal: String(ch))
        case ",": tok = Token(type: .comma, literal: String(ch))
        case "+": tok = Token(type: .plus, literal: String(ch))
        case "{": tok = Token(type: .lbrace, literal: String(ch))
        case "}": tok = Token(type: .rbrace, literal: String(ch))
        case "\0": tok = Token(type: .eof, literal: "")
        
        case _ where ch.isLetter:
            let literal = readIdentifier()
            let type = TokenType(ident: literal)
            return Token(type: type, literal: literal)
        
        case _ where ch.isDigit:
            return Token(type: .int, literal: readNumber())

        default:
            tok = Token(type: .illegal, literal: String(ch))
        }
        
        readChar()
        
        return tok
    }
    
    mutating func readIdentifier() -> String {
        let start = position
        while ch.isLetter { readChar() }
        return String(input[start..<position])
    }
    
    mutating func readNumber() -> String {
        let start = position
        while ch.isDigit { readChar() }
        return String(input[start..<position])
    }
    
    mutating func skipWhitespace() {
        while Set([" ", "\t", "\r\n", "\r", "\n"]).contains(ch) { readChar() }
    }
}

fileprivate extension Character {
    var isLetter: Bool {
        return "a" <= self && self <= "z" || "A" <= self && self <= "Z" || self == "_"
    }
    
    var isDigit: Bool {
        return "0" <= self && self <= "9"
    }
}
