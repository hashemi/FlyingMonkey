//
//  Parser.swift
//  FlyingMonkey
//
//  Created by Ahmad Alhashemi on 2017-08-20.
//  Copyright © 2017 Ahmad Alhashemi. All rights reserved.
//

typealias PrefixParseFn = () -> Expression?
typealias InfixParseFn = (Expression) -> Expression?

class Parser {
    enum Precedence: Int, Comparable {
        static func <(lhs: Parser.Precedence, rhs: Parser.Precedence) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
        
        case lowest
        case equals      // ==
        case lessgreater // > or <
        case sum         // +
        case product     // *
        case prefix      // -X or !X
        case call        // myFunction(X)
        
        init(for type: TokenType) {
            switch type {
            case .eq: self = .equals
            case .notEq: self = .equals
            case .lt: self = .lessgreater
            case .gt: self = .lessgreater
            case .plus: self = .sum
            case .minus: self = .sum
            case .slash: self = .product
            case .asterisk: self = .product
            default: self = .lowest
            }
        }
    }
    
    var l: Lexer
    var errors: [String] = []
    
    var curToken: Token
    var peekToken: Token
    
    var prefixParseFns: [TokenType: PrefixParseFn] = [:]
    var infixParseFns: [TokenType: InfixParseFn] = [:]

    
    func peekPrecedence() -> Precedence {
        return Precedence(for: peekToken.type)
    }

    func curPrecedence() -> Precedence {
        return Precedence(for: curToken.type)
    }
    
    func registerPrefix(tokenType: TokenType, fn: @escaping PrefixParseFn) {
        prefixParseFns[tokenType] = fn
    }

    func registerInfix(tokenType: TokenType, fn: @escaping InfixParseFn) {
        infixParseFns[tokenType] = fn
    }
    
    init(_ l: Lexer) {
        self.l = l
        curToken = self.l.nextToken()
        peekToken = self.l.nextToken()
        
        registerPrefix(tokenType: .ident, fn: parseIdentifier)
        registerPrefix(tokenType: .int, fn: parseIntegerLiteral)
        registerPrefix(tokenType: .bang, fn: parsePrefixExpression)
        registerPrefix(tokenType: .minus, fn: parsePrefixExpression)
        registerPrefix(tokenType: .true, fn: parseBoolean)
        registerPrefix(tokenType: .false, fn: parseBoolean)

        registerInfix(tokenType: .plus, fn: parseInfixExpression)
        registerInfix(tokenType: .minus, fn: parseInfixExpression)
        registerInfix(tokenType: .slash, fn: parseInfixExpression)
        registerInfix(tokenType: .asterisk, fn: parseInfixExpression)
        registerInfix(tokenType: .eq, fn: parseInfixExpression)
        registerInfix(tokenType: .notEq, fn: parseInfixExpression)
        registerInfix(tokenType: .lt, fn: parseInfixExpression)
        registerInfix(tokenType: .gt, fn: parseInfixExpression)
    }
    
    func parseProgram() -> Program {
        var statements: [Statement] = []
        
        while !curTokenIs(.eof) {
            if let stmt = parseStatement() {
                statements.append(stmt)
            }
            nextToken()
        }
        
        return Program(statements: statements)
    }
    
    func parseStatement() -> Statement? {
        switch curToken.type {
        default:
            return parseExpressionStatement()
        }
    }
    
    func nextToken() {
        curToken = peekToken
        peekToken = l.nextToken()
    }
    
    func curTokenIs(_ t: TokenType) -> Bool {
        return curToken.type == t
    }

    func peekTokenIs(_ t: TokenType) -> Bool {
        return peekToken.type == t
    }
    
    func noPrefixParseFnError(_ tokenType: TokenType) {
        self.errors.append("no prefix parse function for \(tokenType) found")
    }
    
    func parseExpressionStatement() -> ExpressionStatement {
        let token = curToken
        let expression = parseExpression(.lowest)
        if peekTokenIs(.semicolon) {
            nextToken()
        }
        
        return ExpressionStatement(token: token, expression: expression)
    }
    
    func parseExpression(_ precedence: Precedence) -> Expression? {
        guard let prefix = prefixParseFns[curToken.type] else {
            noPrefixParseFnError(curToken.type)
            return nil
        }
        
        var leftExp = prefix()
        
        while !peekTokenIs(.semicolon) && precedence < peekPrecedence() {
            guard let infix = infixParseFns[peekToken.type]
                else { return leftExp }
            nextToken()
            guard let unwrappedLeftExp = leftExp
                else { return leftExp }
            leftExp = infix(unwrappedLeftExp)
        }
        
        return leftExp
    }
    
    func parseIdentifier() -> Expression {
        return Identifier(token: curToken, value: curToken.literal)
    }
    
    func parseIntegerLiteral() -> Expression? {
        guard let value = Int64(self.curToken.literal)
            else {
                self.errors.append("could not parse \(self.curToken.literal) as integer")
                return nil
            }
        
        return IntegerLiteral(token: self.curToken, value: value)
    }
    
    func parseBoolean() -> Expression {
        return Boolean(token: curToken, value: curTokenIs(.true))
    }
    
    func parsePrefixExpression() -> Expression {
        let tok = curToken
        let op = curToken.literal
        
        nextToken()
        
        let right = parseExpression(.prefix)
        
        return PrefixExpression(token: tok, op: op, right: right)
    }
    
    func parseInfixExpression(_ left: Expression) -> Expression {
        let token = curToken
        let op = curToken.literal

        let precedence = curPrecedence()
        nextToken()
        let right = parseExpression(precedence)
        return InfixExpression(token: token, left: left, op: op, right: right)
    }
}
