//
//  ContentView.swift
//  JSSUIBridgeTest
//
//  Created by Kai Quan Tay on 29/7/23.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("filePath") var filePath: String = ""
    @AppStorage("functionToCall") var functionToCall: String = ""
    @AppStorage("parameters") var parameters: String = ""
    @State var result: String = ""

    @State var bridge = JSBridge()

    var body: some View {
        VStack {
            TextField("File path", text: $filePath)
            TextField("Function", text: $functionToCall)
            TextField("Parameters", text: $parameters)
            Button("GO") {
                let fileURL = URL(filePath: filePath)

                bridge.reset()
                bridge.loadSourceFile(atUrl: fileURL)
                if let result = bridge.callFunction(functionName: functionToCall, withData: parameters), let strResult = result.toString() {
                    print(strResult)
                    self.result = strResult
                }
            }
            .disabled(filePath == "" || functionToCall == "")
            Text(result)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
