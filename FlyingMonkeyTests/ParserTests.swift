//
//  ParserTests.swift
//  FlyingMonkeyTests
//
//  Created by Ahmad Alhashemi on 2017-08-20.
//  Copyright © 2017 Ahmad Alhashemi. All rights reserved.
//

import XCTest

class ParserTests: XCTestCase {
    
    func testIdentifierExpression() {
        let input = "foobar;"
        let l = Lexer(input)
        let p = Parser(l)
        let program = p.parseProgram()
        
        XCTAssertEqual(p.errors.count, 0)
        XCTAssertEqual(program.statements.count, 1)
        
        guard
            let stmt = program.statements[0] as? ExpressionStatement
        else {
            XCTFail()
            return
        }
        
        guard
            let ident = stmt.expression as? Identifier
        else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(ident.value, "foobar")
        XCTAssertEqual(ident.tokenLiteral, "foobar")
    }
    
    func testIntegerLiteralExpression() {
        let input = "5;"
        let l = Lexer(input)
        let p = Parser(l)
        let program = p.parseProgram()
        
        XCTAssertEqual(p.errors.count, 0)
        XCTAssertEqual(program.statements.count, 1)
        
        guard
            let stmt = program.statements[0] as? ExpressionStatement
            else {
                XCTFail()
                return
        }
        
        guard
            let literal = stmt.expression as? IntegerLiteral
            else {
                XCTFail()
                return
        }
        
        XCTAssertEqual(literal.value, 5)
        XCTAssertEqual(literal.tokenLiteral, "5")
    }
    
    func _testIntegerLiteral(_ il: Expression, _ value: Int64) {
        guard
            let int = il as? IntegerLiteral
        else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(int.value, value)
    }
    
    func testParsingPrefixExpressions() {
        let tests: [(input: String, op: String, integerValue: Int64)] = [
            ("!5;", "!", 5),
            ("-15;", "-", 15),
        ]
        
        for tt in tests {
            let l = Lexer(tt.input)
            let p = Parser(l)
            let program = p.parseProgram()
            
            XCTAssertEqual(p.errors.count, 0)
            XCTAssertEqual(program.statements.count, 1)
            
            guard
                let stmt = program.statements[0] as? ExpressionStatement
                else {
                    XCTFail()
                    return
            }
            
            guard
                let exp = stmt.expression as? PrefixExpression
                else {
                    XCTFail()
                    return
            }
            
            guard
                let right = exp.right else {
                    XCTFail()
                    return
            }
            
            _testIntegerLiteral(right, tt.integerValue)
        }
    }
    
    func testParsingInfixExpressions() {
        let tests: [(input: String, leftValue: Int64, op: String, rightValue: Int64)] = [
            ("5 + 5;", 5, "+", 5),
            ("5 - 5;", 5, "-", 5),
            ("5 * 5;", 5, "*", 5),
            ("5 / 5;", 5, "/", 5),
            ("5 > 5;", 5, ">", 5),
            ("5 < 5;", 5, "<", 5),
            ("5 == 5;", 5, "==", 5),
            ("5 != 5;", 5, "!=", 5),
        ]
        
        for tt in tests {
            let l = Lexer(tt.input)
            let p = Parser(l)
            let program = p.parseProgram()
            
            XCTAssertEqual(p.errors.count, 0)
            XCTAssertEqual(program.statements.count, 1)
            
            guard
                let stmt = program.statements[0] as? ExpressionStatement
                else {
                    XCTFail()
                    return
            }
            
            guard
                let exp = stmt.expression as? InfixExpression
                else {
                    XCTFail()
                    return
            }

            guard
                let right = exp.right else {
                    XCTFail()
                    return
            }
            
            _testIntegerLiteral(exp.left, tt.leftValue)
            _testIntegerLiteral(right, tt.rightValue)
        }
    }
        
    func testOperatorPrecedenceParsing() {
        let tests: [(input: String, expected: String)] = [
            ("-a * b", "((-a) * b)"),
            ("!-a", "(!(-a))"),
            ("a + b + c", "((a + b) + c)"),
            ("a + b - c", "((a + b) - c)"),
            ("a * b * c", "((a * b) * c)"),
            ("a * b / c", "((a * b) / c)"),
            ("a + b / c", "(a + (b / c))"),
            ("a + b * c + d / e - f", "(((a + (b * c)) + (d / e)) - f)"),
            ("3 + 4; -5 * 5", "(3 + 4)((-5) * 5)"),
            ("5 > 4 == 3 < 4", "((5 > 4) == (3 < 4))"),
            ("5 < 4 != 3 > 4", "((5 < 4) != (3 > 4))"),
            ("3 + 4 * 5 == 3 * 1 + 4 * 5", "((3 + (4 * 5)) == ((3 * 1) + (4 * 5)))"),
            ("true", "true"),
            ("false", "false"),
            ("3 > 5 == false", "((3 > 5) == false)"),
            ("3 < 5 == true", "((3 < 5) == true)"),
            ("1 + (2 + 3) + 4", "((1 + (2 + 3)) + 4)"),
            ("(5 + 5) * 2", "((5 + 5) * 2)"),
            ("2 / (5 + 5)", "(2 / (5 + 5))"),
            ("(5 + 5) * 2 * (5 + 5)", "(((5 + 5) * 2) * (5 + 5))"),
            ("-(5 + 5)", "(-(5 + 5))"),
            ("!(true == true)", "(!(true == true))"),
        ]
        
        for tt in tests {
            let l = Lexer(tt.input)
            let p = Parser(l)
            let program = p.parseProgram()
            
            XCTAssertEqual(p.errors.count, 0)
            XCTAssertEqual(program.string, tt.expected)
        }
    }
    
    func testBooleanExpression() {
        let tests: [(input: String, expectedBoolean: Bool)] = [
            ("true;", true),
            ("false;", false)
        ]
        
        for tt in tests {
            let l = Lexer(tt.input)
            let p = Parser(l)
            let program = p.parseProgram()
            
            XCTAssertEqual(p.errors.count, 0)
            XCTAssertEqual(program.statements.count, 1)
            
            guard let stmt = program.statements[0] as? ExpressionStatement else {
                XCTFail()
                return
            }
            
            guard let boolean = stmt.expression as? Boolean else {
                XCTFail()
                return
            }
            
            XCTAssertEqual(boolean.value, tt.expectedBoolean)
        }
    }
    
    func testIfExpression() {
        let input = "if (x < y) { x }"
        
        let l = Lexer(input)
        let p = Parser(l)
        let program = p.parseProgram()
        
        XCTAssertEqual(p.errors.count, 0)
        XCTAssertEqual(program.statements.count, 1)
        
        guard let stmt = program.statements[0] as? ExpressionStatement else {
            XCTFail()
            return
        }
        
        guard let exp = stmt.expression as? IfExpression else {
            XCTFail()
            return
        }
        
        guard let condition = exp.condition else {
            XCTFail()
            return
        }
        
        _testInfixExpression(condition, "x", "<", "y")
        
        XCTAssertEqual(exp.consequence.statements.count, 1)
        
        guard let consequence = exp.consequence.statements[0] as? ExpressionStatement else {
            XCTFail()
            return
        }
        
        guard let consequenceExpression = consequence.expression else {
            XCTFail()
            return
        }
        
        _testIdentifier(consequenceExpression, "x")
        
        XCTAssertNil(exp.alternative)
    }
    
    func testIfElseExpression() {
        let input = "if (x < y) { x } else { y }"
        
        let l = Lexer(input)
        let p = Parser(l)
        let program = p.parseProgram()
        
        XCTAssertEqual(p.errors.count, 0)
        XCTAssertEqual(program.statements.count, 1)
        
        guard let stmt = program.statements[0] as? ExpressionStatement else {
            XCTFail()
            return
        }
        
        guard let exp = stmt.expression as? IfExpression else {
            XCTFail()
            return
        }
        
        guard let condition = exp.condition else {
            XCTFail()
            return
        }
        
        _testInfixExpression(condition, "x", "<", "y")
        
        XCTAssertEqual(exp.consequence.statements.count, 1)
        
        guard let consequence = exp.consequence.statements[0] as? ExpressionStatement else {
            XCTFail()
            return
        }
        
        guard let consequenceExpression = consequence.expression else {
            XCTFail()
            return
        }
        
        _testIdentifier(consequenceExpression, "x")
        
        XCTAssertEqual(exp.alternative?.statements.count ?? 0, 1)
        
        guard let alternative = exp.alternative?.statements[0] as? ExpressionStatement else {
            XCTFail()
            return
        }
        
        guard let alternativeExpression = alternative.expression else {
            XCTFail()
            return
        }
        
        _testIdentifier(alternativeExpression, "y")
    }

    func _testIdentifier(_ exp: Expression, _ value: String) {
        guard let ident = exp as? Identifier else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(ident.value, value)
        XCTAssertEqual(ident.tokenLiteral, value)
    }
    
    func _testLiteralExpression(_ exp: Expression, _ expected: Any) {
        switch expected {
        case let int as Int:
            _testIntegerLiteral(exp, Int64(int))
        case let int as Int64:
            _testIntegerLiteral(exp, int)
        case let string as String:
           _testIdentifier(exp, string)
        default:
            XCTFail()
        }
    }
    
    func _testInfixExpression(_ exp: Expression, _ left: Any, _ op: String, _ right: Any) {
        guard let opExp = exp as? InfixExpression else {
            XCTFail()
            return
        }
        
        _testLiteralExpression(opExp.left, left)
        XCTAssertEqual(opExp.op, op)
        
        guard let expRight = opExp.right else {
            XCTFail()
            return
        }
        
        _testLiteralExpression(expRight, right)
    }
}
