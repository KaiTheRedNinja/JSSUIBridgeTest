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
        print("Calling: \(functionName + "()")")
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
        print("Loading yay \(url.absoluteString)")
        guard let stringFromUrl = try? String(contentsOf: url) else {return}
        print("Loading: \n\(stringFromUrl)")
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