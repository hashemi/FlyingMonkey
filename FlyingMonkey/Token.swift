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
    case minus
    case bang
    case asterisk
    case slash
    case lt
    case gt
    case eq
    case notEq

    case comma
    case semicolon
    
    case lparen
    case rparen
    case lbrace
    case rbrace
    
    case function
    case `let`
    case `true`
    case `false`
    case `if`
    case `else`
    case `return`
}


extension TokenType {
    init(ident: String) {
        switch ident {
        case "fn":      self = .function
        case "let":     self = .let
        case "true":    self = .true
        case "false":   self = .false
        case "if":      self = .if
        case "else":    self = .else
        case "return":  self = .return
        default:        self = .ident
        }
    }
}

struct Token {
    let type: TokenType
    let literal: String
}
