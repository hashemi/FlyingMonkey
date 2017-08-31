//
//  Evaluator.swift
//  FlyingMonkey
//
//  Created by Ahmad Alhashemi on 2017-08-31.
//  Copyright © 2017 Ahmad Alhashemi. All rights reserved.
//

func eval(_ node: Node) -> Object? {
    switch node {
    case let node as Program:
        return evalStatements(node.statements)
    case let node as ExpressionStatement:
        guard let exp = node.expression else { return nil }
        return eval(exp)
    case let node as IntegerLiteral:
        return Integer(value: node.value)
    default:
        return nil
    }
}

func evalStatements(_ statements: [Statement]) -> Object? {
    var result: Object?
    
    for stmt in statements {
        result = eval(stmt)
    }
    
    return result
}
