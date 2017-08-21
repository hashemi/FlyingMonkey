//
//  AstTests.swift
//  FlyingMonkeyTests
//
//  Created by Ahmad Alhashemi on 2017-08-20.
//  Copyright © 2017 Ahmad Alhashemi. All rights reserved.
//

import XCTest

class AstTests: XCTestCase {
    func testString() {
        let program = Program(statements: [
            LetStatement(
                token: Token(type: .let, literal: "let"),
                name: Identifier(
                    token: Token(type: .ident, literal: "myVar"),
                    value: "myVar"
                ),
                value: Identifier(
                    token: Token(type: .ident, literal: "anotherVar"),
                    value: "anotherVar"
                )
            )])
        XCTAssertEqual(program.string, "let myVar = anotherVar;")
    }
}

