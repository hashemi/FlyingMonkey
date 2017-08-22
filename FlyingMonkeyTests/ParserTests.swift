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
}
