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
        let input = "=+(){},;"

        let tests: [(expectedType: TokenType, expectedLiteral: String)] = [
            (.assign, "="),
            (.plus, "+"),
            (.lparen, "("),
            (.rparen, ")"),
            (.lbrace, "{"),
            (.rbrace, "}"),
            (.comma, ","),
            (.semicolon, ";"),
            (.eof, "")
        ]
        
        var l = Lexer(input)
        
        for tt in tests {
            let tok = l.nextToken()
            
            XCTAssertEqual(tok.type, tt.expectedType)
            XCTAssertEqual(tok.literal, tt.expectedLiteral)
        }
    }
}
