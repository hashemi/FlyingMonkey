//
//  Ast.swift
//  FlyingMonkey
//
//  Created by Ahmad Alhashemi on 2017-08-18.
//  Copyright © 2017 Ahmad Alhashemi. All rights reserved.
//

protocol Node {
    var tokenLiteral: String { get }
    var string: String { get }
}

protocol Statement: Node { }

protocol Expression: Node { }

struct Program: Node {
    let statements: [Statement]
    
    var tokenLiteral: String {
        if statements.count > 0 {
            return statements[0].tokenLiteral
        } else {
            return ""
        }
    }
    
    var string: String {
        return statements.map { $0.string }.joined()
    }
}

// Statements
struct LetStatement: Statement {
    let token: Token
    let name: Identifier
    let value: Expression?
    
    var tokenLiteral: String { return token.literal }
    
    var string: String {
        return "\(tokenLiteral) \(name.string) = \(value?.string ?? "");"
    }
}

struct ReturnStatement: Statement {
    let token: Token
    let returnValue: Expression?
    
    var tokenLiteral: String { return token.literal }
    var string: String {
        return "\(tokenLiteral) \(returnValue?.string ?? "");"
    }
}

struct ExpressionStatement: Statement {
    let token: Token
    let expression: Expression?
    
    var tokenLiteral: String { return token.literal }
    
    var string: String { return expression?.string ?? "" }
}

struct BlockStatement: Statement {
    let token: Token
    let statements: [Statement]
    
    var tokenLiteral: String { return token.literal }
    var string: String {
        return statements.map { $0.string }.joined()
    }
}

// Expressions
struct Identifier: Expression {
    let token: Token
    let value: String
    
    var tokenLiteral: String { return token.literal }
    
    var string: String { return value }
}

struct Boolean: Expression {
    let token: Token
    let value: Bool
    
    var tokenLiteral: String { return token.literal }
    var string: String { return token.literal }
}

struct IntegerLiteral: Expression {
    let token: Token
    let value: Int64
    
    var tokenLiteral: String { return token.literal }
    var string: String { return token.literal }
}

struct PrefixExpression: Expression {
    let token: Token
    let op: String
    let right: Expression?
    
    var tokenLiteral: String { return token.literal }
    var string: String {
        return "(\(op)\(right?.string ?? "")"
    }
}

struct InfixExpression: Expression {
    let token: Token
    let left: Expression
    let op: String
    let right: Expression
    
    var tokenLiteral: String { return token.literal }

    var string: String {
        return "(\(left.string) \(op) \(right.string))"
    }
}

struct IfExpression: Expression {
    let token: Token
    let condition: Expression
    let consequence: BlockStatement
    let alternative: BlockStatement?

    var tokenLiteral: String { return token.literal }

    var string: String {
        let baseString = "if\(condition.string) \(consequence.string)"
        if let alternative = alternative {
            return "\(baseString) else \(alternative.string)"
        } else {
            return baseString
        }
    }
}

struct FunctionLiteral: Expression {
    let token: Token
    let parameters: [Identifier]
    let body: BlockStatement

    var tokenLiteral: String { return token.literal }

    var string: String {
        let paramsString = parameters.map { $0.string }.joined(separator: ", ")
        return "\(tokenLiteral)(\(paramsString)) \(body.string)"
    }
}

struct CallExpression: Expression {
    let token: Token
    let function: Expression
    let arguments: [Expression]

    var tokenLiteral: String { return token.literal }

    var string: String {
        let argsString = arguments.map { $0.string }.joined(separator: ", ")
        return "\(tokenLiteral)(\(argsString))"
    }
}
