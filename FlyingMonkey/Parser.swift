//
//  Parser.swift
//  FlyingMonkey
//
//  Created by Ahmad Alhashemi on 2017-08-20.
//  Copyright © 2017 Ahmad Alhashemi. All rights reserved.
//

typealias PrefixParseFn = () -> Expression
typealias InfixParseFn = (Expression) -> Expression

struct Parser {
    enum Precedence: Int {
        case lowest
        case equals      // ==
        case lessgreater // > or <
        case sum         // +
        case product     // *
        case prefix      // -X or !X
        case call        // myFunction(X)
    }
    
    var l: Lexer
    var errors: [String] = []
    
    var curToken: Token
    var peekToken: Token
    
    var prefixParseFns: [TokenType: PrefixParseFn] = [:]
    var infixParseFns: [TokenType: InfixParseFn] = [:]

    mutating func registerPrefix(tokenType: TokenType, fn: @escaping PrefixParseFn) {
        prefixParseFns[tokenType] = fn
    }

    mutating func registerInfix(tokenType: TokenType, fn: @escaping PrefixParseFn) {
        prefixParseFns[tokenType] = fn
    }
    
    init(_ l: Lexer) {
        self.l = l
        curToken = self.l.nextToken()
        peekToken = self.l.nextToken()
        
        registerPrefix(tokenType: .ident, fn: parseIdentifier)
    }
    
    mutating func parseProgram() -> Program {
        var statements: [Statement] = []
        
        while !curTokenIs(.eof) {
            if let stmt = parseStatement() {
                statements.append(stmt)
            }
            nextToken()
        }
        
        return Program(statements: statements)
    }
    
    mutating func parseStatement() -> Statement? {
        switch curToken.type {
        default:
            return parseExpressionStatement()
        }
    }
    
    mutating func nextToken() {
        curToken = peekToken
        peekToken = l.nextToken()
    }
    
    func curTokenIs(_ t: TokenType) -> Bool {
        return curToken.type == t
    }

    func peekTokenIs(_ t: TokenType) -> Bool {
        return peekToken.type == t
    }
    
    mutating func parseExpressionStatement() -> ExpressionStatement {
        let token = curToken
        let expression = parseExpression(.lowest)
        if peekTokenIs(.semicolon) {
            nextToken()
        }
        
        return ExpressionStatement(token: token, expression: expression)
    }
    
    func parseExpression(_ precedence: Precedence) -> Expression? {
        guard let prefix = prefixParseFns[curToken.type] else {
            return nil
        }
        return prefix()
    }
    
    func parseIdentifier() -> Expression {
        return Identifier(token: curToken, value: curToken.literal)
    }
}
