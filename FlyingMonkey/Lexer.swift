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
        } else {
            ch = input[readPosition]
            readPosition = input.index(after: readPosition)
        }
        position = readPosition
    }
    
    mutating func nextToken() -> Token {
        let tok: Token
        
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

        default:
            tok = Token(type: .illegal, literal: String(ch))
        }
        
        readChar()
        
        return tok
    }
}
