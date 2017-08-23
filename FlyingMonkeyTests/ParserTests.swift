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
    
    func _testIntegerLiteral(_ il: Expression, _ value: Int64) -> Bool {
        guard
            let int = il as? IntegerLiteral
        else {
            return false
        }
        
        if int.value != value {
            return false
        }
        
        return true
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
            
            XCTAssertTrue(_testIntegerLiteral(right, tt.integerValue))
        }
    }
}
