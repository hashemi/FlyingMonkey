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
            case .lparen: self = .call
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
        registerPrefix(tokenType: .lparen, fn: parseGroupedExpression)
        registerPrefix(tokenType: .if, fn: parseIfExpression)
        registerPrefix(tokenType: .function, fn: parseFunctionLiteral)

        registerInfix(tokenType: .plus, fn: parseInfixExpression)
        registerInfix(tokenType: .minus, fn: parseInfixExpression)
        registerInfix(tokenType: .slash, fn: parseInfixExpression)
        registerInfix(tokenType: .asterisk, fn: parseInfixExpression)
        registerInfix(tokenType: .eq, fn: parseInfixExpression)
        registerInfix(tokenType: .notEq, fn: parseInfixExpression)
        registerInfix(tokenType: .lt, fn: parseInfixExpression)
        registerInfix(tokenType: .gt, fn: parseInfixExpression)
        registerInfix(tokenType: .lparen, fn: parseCallExpression)
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
        case .let:
            return parseLetStatement()
        case .return:
            return parseReturnStatement()
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
    
    func parseLetStatement() -> LetStatement? {
        let token = curToken
        
        if !expectPeek(.ident) {
            return nil
        }
        
        let name = Identifier(token: curToken, value: curToken.literal)
        
        if !expectPeek(.assign) {
            return nil
        }
        
        nextToken()
        
        let value = parseExpression(.lowest)
        
        if peekTokenIs(.semicolon) {
            nextToken()
        }
        
        return LetStatement(token: token, name: name, value: value)
    }
    
    func parseReturnStatement() -> ReturnStatement {
        let token = curToken
        nextToken()
        
        let returnValue = parseExpression(.lowest)
        
        if peekTokenIs(.semicolon) {
            nextToken()
        }
        
        return ReturnStatement(token: token, returnValue: returnValue)
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
        return BooleanLiteral(token: curToken, value: curTokenIs(.true))
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
    
    func expectPeek(_ type: TokenType) -> Bool {
        if peekTokenIs(type) {
            nextToken()
            return true
        } else {
            peekError(type)
            return false
        }
    }
    
    func peekError(_ type: TokenType) {
        errors.append("Expected next token to by \(type), got \(peekToken.type)")
    }
    
    func parseGroupedExpression() -> Expression? {
        nextToken()
        
        let exp = parseExpression(.lowest)
        
        if !expectPeek(.rparen) {
            return nil
        }
        
        return exp
    }
    
    func parseIfExpression() -> Expression? {
        let token = curToken
        
        if !expectPeek(.lparen) {
            return nil
        }
        
        nextToken()
        
        let condition = parseExpression(.lowest)
        
        if !expectPeek(.rparen) {
            return nil
        }
        
        if !expectPeek(.lbrace) {
            return nil
        }
        
        let consequence = parseBlockStatement()
        
        
        let alternative: BlockStatement?
        if peekTokenIs(.else) {
            nextToken()
            
            if !expectPeek(.lbrace) {
                return nil
            }
            
            alternative = parseBlockStatement()
        } else {
            alternative = nil
        }
        
        return IfExpression(token: token, condition: condition, consequence: consequence, alternative: alternative)
    }
    
    func parseFunctionLiteral() -> Expression? {
        let token = curToken
        
        if !expectPeek(.lparen) { return nil }
        
        let parameters = parseFunctionParameters()
        
        if !expectPeek(.lbrace) { return nil }
        
        let body = parseBlockStatement()
        
        return FunctionLiteral(token: token, parameters: parameters, body: body)
    }
    
    func parseFunctionParameters() -> [Identifier]? {
        var identifiers: [Identifier] = []
        
        if peekTokenIs(.rparen) {
            nextToken()
            return identifiers
        }
        
        nextToken()
        
        let ident = Identifier(token: curToken, value: curToken.literal)
        identifiers.append(ident)
        
        while peekTokenIs(.comma) {
            nextToken()
            nextToken()
            let ident = Identifier(token: curToken, value: curToken.literal)
            identifiers.append(ident)
        }
        
        if !expectPeek(.rparen) {
            return nil
        }
        
        return identifiers
    }
    
    func parseCallExpression(_ function: Expression) -> Expression {
        let token = curToken
        let arguments = parseCallArguments()
        return CallExpression(token: token, function: function, arguments: arguments)
    }
    
    func parseCallArguments() -> [Expression]? {
        var args: [Expression] = []
        
        if peekTokenIs(.rparen) {
            nextToken()
            return args
        }
        
        nextToken()
        
        if let exp = parseExpression(.lowest) {
            args.append(exp)
        }

        while peekTokenIs(.comma) {
            nextToken()
            nextToken()
            if let exp = parseExpression(.lowest) {
                args.append(exp)
            }
        }
        
        if !expectPeek(.rparen) {
            return nil
        }
        
        return args
    }
    
    func parseBlockStatement() -> BlockStatement {
        let token = curToken
        var statements: [Statement] = []
        
        nextToken()
        
        while !curTokenIs(.rbrace) && !curTokenIs(.eof) {
            if let stmt = parseStatement() {
                statements.append(stmt)
            }
            nextToken()
        }
        
        return BlockStatement(token: token, statements: statements)
    }
}
