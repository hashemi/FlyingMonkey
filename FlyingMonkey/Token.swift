//
//  Token.swift
//  FlyingMonkey
//
//  Created by Ahmad Alhashemi on 2017-08-18.
//  Copyright © 2017 Ahmad Alhashemi. All rights reserved.
//

enum TokenType {
    case illegal
    case eof
    
    case ident
    case int
    
    case assign
    case plus
    
    case comma
    case semicolon
    
    case lparen
    case rparen
    case lbrace
    case rbrace
    
    case function
    case `let`
}

extension TokenType {
    init(ident: String) {
        switch ident {
        case "fn": self = .function
        case "let": self = .let
        default: self = .ident
        }
    }
}

struct Token {
    let type: TokenType
    let literal: String
}
