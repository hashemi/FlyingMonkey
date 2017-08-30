//
//  Repl.swift
//  FlyingMonkey
//
//  Created by Ahmad Alhashemi on 2017-08-18.
//  Copyright © 2017 Ahmad Alhashemi. All rights reserved.
//

let prompt = ">> "

func start() {
    while true {
        print(prompt, terminator: "")
        guard let line = readLine() else { return }
        let l = Lexer(line)
        let p = Parser(l)
        
        let program = p.parseProgram()
        
        if p.errors.count != 0 {
            printParserErrors(p.errors)
        }
        
        print(program.string)
    }
}

func printParserErrors(_ errors: [String]) {
    for msg in errors {
        print("\t\(msg)\n")
    }
}
