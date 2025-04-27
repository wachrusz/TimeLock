//
//  FireBaseManager.swift
//  TimeLock
//
//  Created by Misha Vakhrushin on 27.04.2025.
//

import Foundation
import FirebaseAnalytics
import FirebaseCore
import SwiftyJSON

enum AnalyticsAction{
    case buttonTapped
    case addedCode
    case generatedIcon
    case backedUpData
    case toggledSettings
    case deletedCode
    
    var text: String {
        switch self{
        case .buttonTapped:
            return "buttonTapped"
        case .addedCode:
            return "addedCode"
        case .generatedIcon:
            return "generatedIcon"
        case .backedUpData:
            return "backedUpData"
        case .toggledSettings:
            return "toggledSettings"
        case .deletedCode:
            return "deletedCode"
        }
    }
}

final class FirebaseAnalyticsManager: ObservableObject {
    static let shared = FirebaseAnalyticsManager()
    
    private init() {}
    
    func logEvent(_ name: String, parameters: [String: Any]? = nil) {
        Analytics.logEvent(name, parameters: parameters)
        Logger.shared.log("Firebase Analytics: Logged event: \(name), parameters: \(parameters ?? [:])", level: .warning)
    }
    
    func logUserActionEvent(
        actionType: AnalyticsAction,
        additionalData: [String: Any]? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let fileName = (file as NSString).lastPathComponent
        
        var parameters: [String: Any] = [
            "action_type": actionType.text,
            "source_file": fileName,
            "source_function": function,
            "source_line": line
        ]
        
        if let userInfo = getUserInfo() {
            parameters.merge(userInfo) { current, _ in current }
        }
        
        if let additionalData = additionalData {
            parameters.merge(additionalData) { current, _ in current }
        }
        
        logEvent(actionType.text, parameters: parameters)
    }
    
    private func getUserInfo() -> [String: Any]? {
        let locale = Locale.current
        let country = locale.region?.identifier ?? "Unknown"
        let language = locale.language.languageCode?.identifier ?? "Unknown"
        
        return [
            "country": country,
            "language": language
        ]
    }
    
    func logComplexDataEvent(eventName: String, data: [String: Any]) {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: []),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            Logger.shared.log("Firebase Analytics: Failed to convert data to JSON string")
            return
        }
        
        let parameters: [String: Any] = [
            "data": jsonString
        ]
        logEvent(eventName, parameters: parameters)
    }
}
