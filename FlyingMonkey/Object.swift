//
//  Object.swift
//  FlyingMonkey
//
//  Created by Ahmad Alhashemi on 2017-08-31.
//  Copyright © 2017 Ahmad Alhashemi. All rights reserved.
//

enum ObjectType: String {
    case integer = "INTEGER"
    case boolean = "BOOLEAN"
    case null = "NULL"
}

protocol Object {
    var type: ObjectType { get }
    var inspect: String { get }
}

struct Integer: Object {
    let value: Int64
    
    var type: ObjectType {
        return .integer
    }
    
    var inspect: String {
        return "\(value)"
    }
}

struct Boolean: Object {
    let value: Bool
    
    var type: ObjectType { return .boolean }
    var inspect: String { return "\(value)" }
}

struct Null: Object {
    var type: ObjectType { return .null }
    var inspect: String { return "null" }
}
