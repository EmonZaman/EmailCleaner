//
//  EmailManager.swift
//  EmailCleaner
//
//  Created by Raqeeb on 9/5/23.
//

import Foundation
import GoogleAPIClientForREST

class EmailInfo {
    
    enum Category {
        case primary, promotions, social, updates, forums, sent, drafts, spam, trash, starred
    }
    
    var message: GTLRGmail_Message?
    var messageReceivedDate: String? = nil
    var isRead: Bool? = nil
    var isHasAttachment: Bool? = nil
    var isStarred: Bool? = nil
    var subject: String? = nil
    var from: String? = nil
    var to: String? = nil
    var time: String? = nil
    var messageBody: String? = nil
    var messageID: String? = nil
    var attachmentFilename: String?
    
    init(message: GTLRGmail_Message, messageReceivedDate: String?, isRead: Bool?, isHasAttachment: Bool?, isStarred: Bool?, subject: String?, from: String?, to: String?, time: String?, messageBody: String?, messageID: String?, attachmentFilename: String?) {
        self.message = message
        self.messageReceivedDate = messageReceivedDate
        self.isRead = isRead
        self.isHasAttachment = isHasAttachment
        self.isStarred = isStarred
        self.subject = subject
        self.from = from
        self.to = to
        self.time = time
        self.messageBody = messageBody
        self.messageID = messageID
        self.attachmentFilename = attachmentFilename
    }
    
    init() {}
}

class EmailManager {
    
    static let shared = EmailManager()
    
    var primaryMessages: [EmailInfo] = []
    var promotionsMessages: [EmailInfo] = []
    var socialMessages: [EmailInfo] = []
    var updatesMessages: [EmailInfo] = []
    var forumsMessages: [EmailInfo] = []
    var sentMessages: [EmailInfo] = []
    var draftsMessages: [EmailInfo] = []
    var spamMessages: [EmailInfo] = []
    var trashMessages: [EmailInfo] = []
    var starredMessages: [EmailInfo] = []
    
    // Append an email to the specified category
    func appendEmail(_ email: EmailInfo, to category: EmailInfo.Category) {
        switch category {
        case .primary:
            primaryMessages.append(email)
        case .promotions:
            promotionsMessages.append(email)
        case .social:
            socialMessages.append(email)
        case .updates:
            updatesMessages.append(email)
        case .forums:
            forumsMessages.append(email)
        case .sent:
            sentMessages.append(email)
        case .drafts:
            draftsMessages.append(email)
        case .spam:
            spamMessages.append(email)
        case .trash:
            trashMessages.append(email)
        case .starred:
            starredMessages.append(email)
        }
    }
    
    
    
    // Remove an email from the specified category
    //    func removeEmail(_ email: EmailInfo, from category: EmailInfo.Category) {
    //        switch category {
    //        case .primary:
    //            if let index = primaryMessages.firstIndex(where: { $0.messageID == email.messageID }) {
    //                primaryMessages.remove(at: index)
    //            }
    //        case .promotions:
    //            // Similar removal logic for other categories
    //        // ...
    //        }
    //    }
    //
    //    // Filter emails by date across all categories
    //    func filterEmailsByDate(date: String) -> [EmailInfo] {
    //        let allMessages = primaryMessages + promotionsMessages + socialMessages + updatesMessages + forumsMessages + sentMessages + draftsMessages + spamMessages + trashMessages
    //        return allMessages.filter { $0.messageReceivedDate == date }
    //    }
    
    // Add more methods as needed to manage and interact with email messages
    
    
    
}
