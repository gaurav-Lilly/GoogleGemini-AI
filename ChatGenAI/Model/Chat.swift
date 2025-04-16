//
//  Chat.swift
//  ChatGenAI
//
//  Created by Gaurav Sharma on 14/02/25.
//


import Foundation
import UIKit

enum ChatRole {
    case user
    case aiModel
}

struct Media {
    let mimeType: String
    let data: Data
    let thumbnail: UIImage
    var overlayIconName: String {
        if mimeType.starts(with: "video") {
            return "video.circle.fill"
        }
        else if mimeType.starts(with: "image") {
            return "photo.circle.fill"
        }
        else if mimeType.contains("pdf") || mimeType.contains("text") {
            return "doc.circle.fill"
        }
        return ""
    }
}

struct ChatMessage: Identifiable, Equatable {
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        return lhs.id == rhs.id && lhs.role == rhs.role && lhs.message == rhs.message
    }
    
    let id = UUID().uuidString
    let role: ChatRole
    var message: String
    let media: [Media]?
}
