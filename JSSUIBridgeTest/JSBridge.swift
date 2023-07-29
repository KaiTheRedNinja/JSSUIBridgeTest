//
//  JSBridge.swift
//  JSSUIBridgeTest
//
//  Created by Kai Quan Tay on 29/7/23.
//

import Foundation
import JavaScriptCore

class JSBridge {
    private var context: JSContext! = JSContext()

    init() {
        context.exceptionHandler = {context, exception in
            if let exception = exception {
                print(exception.toString()!)
            }
        }
    }

    func callFunction(functionName: String) -> JSValue? {
        let result = context.evaluateScript(functionName + "()")
        return result
    }

    func callFunction<T: Codable>(functionName:String, withData dataObject: T) -> JSValue? {
        var dataString = ""
        if let string = getString(fromObject: dataObject) {
            dataString = string
        }
        let functionString = functionName + "(\(dataString))"
        let result = context?.evaluateScript(functionString)
        return result
    }

    func loadSourceFile(atUrl url: URL) {
        guard let stringFromUrl = try? String(contentsOf: url) else {return}
        context.evaluateScript(stringFromUrl)
    }

    func evaluateJavaScript(_ jsString: String) -> JSValue? {
        context.evaluateScript(jsString)
    }

    func setObject(object: Any, withName: String) {
        context.setObject(object, forKeyedSubscript: withName as NSCopying & NSObjectProtocol)
    }

    func reset() {
        context = .init()
    }

    private func getString<T: Codable>(fromObject jsonObject: T) -> String? {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(jsonObject),
              let string = String(data:data, encoding:.utf8) else  {
            return nil
        }
        return string
    }
}

extension JSBridge {
    enum Permission {
        case username
    }

    func loadPermission(permission: Permission) {
        switch permission {
        case .username:
            setObject(object: SwiftBridge.self, withName: "SwiftBridge")
            _ = evaluateJavaScript("const getUserName = SwiftBridge.getUserName")
        }
    }
}

@objc protocol SwiftBridgeProtocol: JSExport {
    static func getUserName() -> String
}

class SwiftBridge: NSObject, SwiftBridgeProtocol {
    class func getUserName() -> String {
        return UserDefaults.standard.string(forKey: "username") ?? ""
    }
}
