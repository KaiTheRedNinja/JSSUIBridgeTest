//
//  BridgeUIElement.swift
//  JSSUIBridgeTest
//
//  Created by Kai Quan Tay on 29/7/23.
//

import Foundation
import SwiftUI

struct BridgeElementView: View {
    var element: BridgeUIElement

    @EnvironmentObject var buttonCoordinator: ButtonCoordinator

    var body: some View {
        switch element {
        case .stack(let bridgeStackData):
            switch bridgeStackData.orientation {
            case .horizontal:
                HStack {
                    stackContent(content: bridgeStackData.content)
                }
            case .vertical:
                VStack {
                    stackContent(content: bridgeStackData.content)
                }
            }
        case .text(let bridgeTextData):
            Text(bridgeTextData.content)
        case .button(let bridgeButtonData):
            Button {
                buttonCoordinator.triggerFunction(named: bridgeButtonData.action)
            } label: {
                BridgeElementView(element: bridgeButtonData.content)
            }
        }
    }

    func stackContent(content: [BridgeUIElement]) -> some View {
        ForEach(Array(content.enumerated()), id: \.offset) { data in
            BridgeElementView(element: data.element)
        }
    }
}

indirect enum BridgeUIElement {
    case stack(BridgeStackData)
    case text(BridgeTextData)
    case button(BridgeButtonData)
}

struct BridgeStackData {
    var orientation: Orientation
    var content: [BridgeUIElement]

    enum Orientation {
        case horizontal
        case vertical
    }
}

struct BridgeTextData {
    var content: String
}

struct BridgeButtonData {
    var action: String
    var content: BridgeUIElement
}

enum BridgeBuildingError: Error {
    case unidentifiedViewType
    case invalidContent
}

func bridgeElementFor(dict: [String: Any]) throws -> BridgeUIElement {
    guard let viewType = dict["viewType"] as? String else { throw BridgeBuildingError.unidentifiedViewType }
    switch viewType {
    case "hstack", "vstack":
        guard let rawContent = dict["content"] as? [[String: Any]] else { throw BridgeBuildingError.invalidContent }
        let content = try rawContent.map({ try bridgeElementFor(dict: $0) })
        return .stack(.init(orientation: viewType == "hstack" ? .horizontal : .vertical, content: content))
    case "text":
        guard let content = dict["content"] as? String else { throw BridgeBuildingError.invalidContent }
        return .text(.init(content: content))
    case "button":
        guard let action = dict["action"] as? String,
              let rawContent = dict["content"] as? [String: Any]
        else { throw BridgeBuildingError.invalidContent }
        let content = try bridgeElementFor(dict: rawContent)
        return .button(.init(action: action, content: content))
    default: throw BridgeBuildingError.unidentifiedViewType
    }
}
