//
//  LexerTests.swift
//  FlyingMonkeyTests
//
//  Created by Ahmad Alhashemi on 2017-08-18.
//  Copyright © 2017 Ahmad Alhashemi. All rights reserved.
//

import XCTest

class LexerTests: XCTestCase {
    func testNextToken() {
        let input = """
                let five = 5;
                let ten = 10;

                let add = fn(x, y) {
                    x + y;
                };

                let result = add(five, ten);
                """

        let tests: [(expectedType: TokenType, expectedLiteral: String)] = [
            (.let, "let"),
            (.ident, "five"),
            (.assign, "="),
            (.int, "5"),
            (.semicolon, ";"),
            (.let, "let"),
            (.ident, "ten"),
            (.assign, "="),
            (.int, "10"),
            (.semicolon, ";"),
            (.let, "let"),
            (.ident, "add"),
            (.assign, "="),
            (.function, "fn"),
            (.lparen, "("),
            (.ident, "x"),
            (.comma, ","),
            (.ident, "y"),
            (.rparen, ")"),
            (.lbrace, "{"),
            (.ident, "x"),
            (.plus, "+"),
            (.ident, "y"),
            (.semicolon, ";"),
            (.rbrace, "}"),
            (.semicolon, ";"),
            (.let, "let"),
            (.ident, "result"),
            (.assign, "="),
            (.ident, "add"),
            (.lparen, "("),
            (.ident, "five"),
            (.comma, ","),
            (.ident, "ten"),
            (.rparen, ")"),
            (.semicolon, ";"),
            (.eof, ""),
        ]
        
        var l = Lexer(input)
        
        for tt in tests {
            let tok = l.nextToken()
            
            XCTAssertEqual(tok.type, tt.expectedType)
            XCTAssertEqual(tok.literal, tt.expectedLiteral)
        }
    }
}
