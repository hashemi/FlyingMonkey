//
//  EvaluatorTests.swift
//  FlyingMonkeyTests
//
//  Created by Ahmad Alhashemi on 2017-08-31.
//  Copyright © 2017 Ahmad Alhashemi. All rights reserved.
//

import XCTest

class EvaluatorTests: XCTestCase {
    func testEvalIntegerExpression() {
        let tests: [(input: String, expected: Int64)] = [
                ("5", 5),
                ("10", 10)
            ]
        
        for tt in tests {
            let evaluated = _testEval(tt.input)
            _testIntegerObject(evaluated, tt.expected)
        }
    }
    
    func _testEval(_ input: String) -> Object? {
        let l = Lexer(input)
        let p = Parser(l)
        let program = p.parseProgram()
        return eval(program)
    }
    
    func _testIntegerObject(_ obj: Object?, _ expected: Int64) {
        guard let result = obj as? Integer else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(result.value, expected)
    }
}
