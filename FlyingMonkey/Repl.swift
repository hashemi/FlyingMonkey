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
        var l = Lexer(line)
        var tok = l.nextToken()
        while tok.type != .eof {
            print(tok)
            tok = l.nextToken()
        }
    }
}
