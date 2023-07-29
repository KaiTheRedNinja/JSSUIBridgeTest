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
                loadFile()
                registerSource()
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
                    _ = bridge.evaluateJavaScript("contentView.\(newValue)()")
                    render()
                    buttonCoordinator.dismissTrigger()
                }
            }
            .padding(10)
        }
        .padding()
    }

    @State var source: DispatchSourceFileSystemObject?

    func registerSource() {
        let fileURL = URL(filePath: filePath)

        guard let fileHandler = try? FileHandle(forReadingFrom: fileURL) else {
            print("Could not get file descriptor")
            return
        }

        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileHandler.fileDescriptor,
            eventMask: .extend
        )

        source.setEventHandler {
            loadFile()
            print("LOADING")
        }

        source.setCancelHandler {
            try? fileHandler.close()
        }

        source.resume()

        self.source = source
    }

    func loadFile() {
        let fileURL = URL(filePath: filePath)

        bridge.reset()
        bridge.loadSourceFile(atUrl: fileURL)
        _ = bridge.evaluateJavaScript(
                """
                let contentView = new \(functionToCall)()
                """)
        render()
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
