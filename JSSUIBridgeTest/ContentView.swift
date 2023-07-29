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

    @State var bridge = JSBridge()

    @State var rootElement: BridgeUIElement?

    @StateObject var buttonCoordinator: ButtonCoordinator = .init()

    var body: some View {
        VStack {
            TextField("File path", text: $filePath)
            TextField("View Class", text: $functionToCall)
            Button("Load") {
                let fileURL = URL(filePath: filePath)

                bridge.reset()
                bridge.loadSourceFile(atUrl: fileURL)
                _ = bridge.evaluateJavaScript(
                """
                let contentView = new \(functionToCall)()
                """)
                render()
            }
            .disabled(filePath == "" || functionToCall == "")

            GroupBox {
                ZStack {
                    if let rootElement {
                        BridgeElementView(element: rootElement)
                            .environmentObject(buttonCoordinator)
                    }
                }
                .padding(10)
                .onChange(of: buttonCoordinator.triggeredFunction) { _, newValue in
                    guard let newValue else { return }
                    print("Evaluating {\("contentView.\(newValue)()")}")
                    _ = bridge.evaluateJavaScript("contentView.\(newValue)()")
                    render()
                    buttonCoordinator.dismissTrigger()
                }
            }
            .padding(10)
        }
        .padding()
    }

    func render() {
        if let result = bridge.callFunction(functionName: "contentView.render"), let strResult = result.toString() {
            processJsonStr(json: strResult)
        }
    }

    func processJsonStr(json: String) {
        guard let json = try? JSONSerialization.jsonObject(with: json.data(using: .utf8)!) as? [String: Any] else { return }
        do {
            let tree = try bridgeElementFor(dict: json)
            print(tree)
            rootElement = tree
        } catch {
            print("ERROR: \(error)")
        }
    }
}

class ButtonCoordinator: ObservableObject {
    @Published private(set) var triggeredFunction: String?

    func triggerFunction(named name: String) {
        self.triggeredFunction = name
    }

    func dismissTrigger() {
        self.triggeredFunction = nil
    }
}

#Preview {
    ContentView()
}
