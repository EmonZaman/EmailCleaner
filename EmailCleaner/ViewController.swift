//
//  ViewController.swift
//  EmailCleaner
//
//  Created by Raqeeb on 8/16/23.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST
import GTMSessionFetcher
import GTMAppAuth

var isLoggedIn: Bool?

class EmailInfo {
    enum Category {
        case primary, promotions, social, updates, forums, sent, drafts, spam, trash
    }
    
    var message: GTLRGmail_Message?
    var category: Category?
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
    
    
    init(message: GTLRGmail_Message, category: Category, messageReceivedDate: String?, isRead: Bool?, isHasAttachment: Bool?, isStarred: Bool?, subject: String?, from: String?, to: String?, time: String?, messageBody: String?, messageID: String?) {
        self.message = message
        self.category = category
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
        
    }
    
    init() {}
}

class ViewController: UIViewController {
    
    @IBOutlet weak var btnSignIn: GIDSignInButton!{
        didSet{
            btnSignIn.addTarget(self, action: #selector(btnSignInAction), for: .touchUpInside)
        }
    }
    @IBOutlet weak var btnSignOut: UIButton!{
        didSet{
            btnSignOut.addTarget(self, action: #selector(btnSignOutAction), for: .touchUpInside)
        }
    }
    
    // Define a struct to represent categorized messages
    
    
    var primaryMessages: [EmailInfo] = []
    var promotionsMessages: [EmailInfo] = []
    var sentMessages: [EmailInfo] = []
    var socialMessages: [EmailInfo] = []
    var spamMessages: [EmailInfo] = []
    var updatesMessages: [EmailInfo] = []
    var forumsMessages: [EmailInfo] = []
    var draftsMessages: [EmailInfo] = []
    var trashMessages: [EmailInfo] = []
    
    
    private var service: GTLRGmailService?
    var allMessages: [GTLRGmail_Message] = []
    
    var i = 0
    var totalMessageFound = 0
    
    var isTrashFetching = false
    
    private var gmailService: GTLRGmailService?
    var inboxMessages: [GTLRGmail_Message] = []
    // var service: GTLServiceGmail?
    var output: UITextView?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("view controller")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if isLoggedIn ?? true {
                self.btnSignIn.alpha = 0
            }
            else{
                self.btnSignOut.alpha = 0
            }
            
        }
        
        
    }
    
    @objc func btnSignInAction(){
        
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
            
            guard error == nil else { return }
            if let user = signInResult?.user {
                
                print("FALSE ===== 1111")
                
                let driveScope = "https://www.googleapis.com/auth/gmail.modify"
                
                let grantedScopes = user.grantedScopes
                let service = GTLRGmailService()
                // Modify the scopes to include Gmail API scopes
                
                // Set the access token for the Gmail service
                ///  let authorizer = GTMAppAuthFetcherAuthorization(authState: user.fetcherAuthorizer)
                
                if grantedScopes == nil || !grantedScopes!.contains(driveScope) {
                    
                    //  let additionalScopes = ["https://www.googleapis.com/auth/gmail.readonly"]
                    let additionalScopes = ["https://www.googleapis.com/auth/gmail.readonly", "https://www.googleapis.com/auth/gmail.modify"]
                    
                    guard let currentUser = GIDSignIn.sharedInstance.currentUser else {
                        return ;  /* Not signed in. */
                    }
                    currentUser.addScopes(additionalScopes, presenting: self) { signInResult, error in
                        guard error == nil else { return }
                        guard let signInResult = signInResult else { return }
                        
                        print("FALSE ===== 2222")
                        
                        // Check if the user granted access to the scopes you requested.
                    }
                    
                    currentUser.refreshTokensIfNeeded { user, error in
                        guard error == nil else { return }
                        guard let user = user else { return }
                        
                        
                        print("FALSE ===== 33333")
                        
                        // Get the access token to attach it to a REST or gRPC request.
                        let accessToken = user.accessToken.tokenString
                        
                        // Or, get an object that conforms to GTMFetcherAuthorizationProtocol for
                        // use with GTMAppAuth and the Google APIs client library.
                        
                        let service = GTLRGmailService()
                        
                        // Modify the scopes to include Gmail API scopes
                        // Set the access token for the Gmail service
                        ///  let authorizer = GTMAppAuthFetcherAuthorization(authState: user.fetcherAuthorizer)
                        service.authorizer =  user.fetcherAuthorizer
                        
                        self.gmailService = service
                        
                        // Fetch inbox messages using batch query
                        self.fetchInboxMessages() {
                            
                            print("ALL DONE")
                        }
                    }
                    // Request additional Drive scope.
                }
                else{
                    
                    print("FALSE ===== else codition and authorized")
                    service.authorizer =  user.fetcherAuthorizer
                    self.gmailService = service
                    
                    // Fetch inbox messages using batch query
                    // self.fetchInboxMessages()
                    
                    let dispatchGroup = DispatchGroup()
                    
                    
                    self.isTrashFetching = false
                    self.fetchInboxMessages() {
                        print("1st time Found \(self.totalMessageFound)")
                        self.totalMessageFound = 0
                        self.isTrashFetching = true
                        dispatchGroup.enter()
                        self.fetchInboxMessages {
                            
                            print("2nd time Found \(self.totalMessageFound)")
                            
                            
                            dispatchGroup.leave()
                        }
                        print("ALL DONE")
                        
                    }
                }
                // Update UI or perform other actions
            }
            
            
        }
        self.btnSignIn.alpha = 0
        self.btnSignOut.alpha = 1
        isLoggedIn = true
        
        // If sign in succeeded, display the app's main content View.
    }
    
    
    
    @objc func btnSignOutAction(){
        GIDSignIn.sharedInstance.signOut()
        
        self.btnSignIn.alpha = 1
        self.btnSignOut.alpha = 0
        isLoggedIn = false
    }
    
    var called = 0
    
    //MARK: WITH DISPATCH GROUP
    
    func fetchInboxMessages(pageToken: String? = nil, completion: @escaping () -> Void) {
        
        called += 1
        debugPrint("called \(called)")
        guard let service = gmailService else {
            print("Gmail service not configured")
            return
        }
        
        
        
        let query = GTLRGmailQuery_UsersMessagesList.query(withUserId: "me")
        query.pageToken = pageToken // Set the page token for pagination
        
        if isTrashFetching{
            query.labelIds = ["TRASH"]
        }
        
        query.pageToken = pageToken // Set the page token for pagination
        
        let group = DispatchGroup()
        
        group.enter()
        
        service.executeQuery(query) { [weak self] (ticket, response, error) in
            
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching inbox messages: \(error.localizedDescription)")
                return
            }
            
            if let messagesResponse = response as? GTLRGmail_ListMessagesResponse,
               
                let messages = messagesResponse.messages {
                
                totalMessageFound += messages.count
                print("Fetched count \(messages.count) inbox email messages")
                
                // Create a dispatch group to wait for message details fetching
                let dispatchGroup = DispatchGroup()
                
                for message in messages {
                    
                    dispatchGroup.enter()
                    
                    self.fetchMessageDetails(messageId: message.identifier!) {
                        
                        dispatchGroup.leave()
                        
                    }
                }
                
                
                // Notify when all message details have been fetched
                dispatchGroup.notify(queue: .main) {
                    // Debug prints to help identify the issue
                    print("Finished fetching details for current page")
                    
                    // Fetch the next page if available
                    if let nextPageToken = messagesResponse.nextPageToken {
                        print("Fetching next page...")
                        
                        self.fetchInboxMessages(pageToken: nextPageToken, completion: completion)
                    } else {
                        // All messages have been fetched
                        print("Total messages fetched count ==== final: \(self.totalMessageFound)")
                        
                        completion()
                        
                        // completion(true) // Call the completion handler
                    }
                }
                
            } else {
                group.leave()
                debugPrint("hellooooooo")
            }
        }
        
        group.notify(queue: .main) {
            completion()
        }
    }
    
    //MARK: WITH GROUP
    
    func fetchMessageDetails(messageId: String, completion: @escaping () -> Void) {
        
        
        var emailInfo: EmailInfo = EmailInfo()
        
        guard let service = gmailService else {
            print("Gmail service not configured")
            completion() // Call completion even if there's an error
            return
        }
        
        let messageQuery = GTLRGmailQuery_UsersMessagesGet.query(withUserId: "me", identifier: messageId)
        messageQuery.format = kGTLRGmailFormatFull
        
        let group = DispatchGroup()
        
        group.enter()
        
        service.executeQuery(messageQuery) { (ticket, response, error) in
            if let error = error {
                print("Error fetching message details: \(error.localizedDescription)")
                completion() // Call completion in case of an error
                return
            }
            
            
            if let message = response as? GTLRGmail_Message {
                self.allMessages.append(message) // Store the entire message object
                
                // Print all available fields and metadata
                if let id = message.identifier {
                    
                    
                    
                    print("Message ID: \(id)")
                }
                if let snippet = message.snippet {
                    print("Snippet: \(snippet)")
                }
                if let internalDate = message.internalDate {
                    print("Internal Date: \(internalDate)")
                }
                
                // Check if the message is read or not
                if let labelIds = message.labelIds {
                    if labelIds.contains("UNREAD") {
                        print("Status: Unread")
                    } else {
                        print("Status: Read")
                    }
                }
                
                //Check message starred
                if self.isTrashFetching == false{
                    if let labelIds = message.labelIds {
                        
                        if labelIds.contains("STARRED") {
                            print("this is starred message")
                        }
                        
                    }
                }
                
                
                // Check message categories
                
                if self.isTrashFetching{
                    print("Category: Trash")
                    
                    
                }
                else{
                    
                    if let labelIds = message.labelIds {
                        
                        if labelIds.contains("INBOX") {
                            print("Category: Inbox")
                        }
                        else if labelIds.contains("CATEGORY_PROMOTIONS") {
                            print("Category: Promotions")
                        }
                        else if labelIds.contains("CATEGORY_SOCIAL") {
                            print("Category: Social")
                        }
                        else if labelIds.contains("CATEGORY_UPDATES") {
                            print("Category: Update")
                        }
                        else if labelIds.contains("CATEGORY_FORUMS") {
                            print("Category: Forums")
                        }
                        else if labelIds.contains("DRAFT") {
                            print("Category: Draft")
                        }
                        else if labelIds.contains("SENT") {
                            print("Category: Sent")
                        }
                        else if labelIds.contains("SPAM") {
                            print("Category: Spam")
                        }
                        if labelIds.contains("TRASH") {
                            print("Category: Trash")
                        }
                        // Add more category checks as needed
                    }
                    
                }
                
                
                
                // Process message headers
                if let payload = message.payload, let headers = payload.headers {
                    for header in headers {
                        if let name = header.name, let value = header.value {
                            print("Header - \(name): \(value)")
                            
                            // Check for specific headers like "From", "To", "Subject", etc.
                            if name.lowercased() == "from" {
                                print("Sender: \(value)")
                            } else if name.lowercased() == "to" {
                                print("Receiver: \(value)")
                            } else if name.lowercased() == "subject" {
                                print("Subject: \(value)")
                            }
                            // Add more header checks as needed
                        }
                    }
                }
                
                // Process message body and attachments
                if let payload = message.payload {
                    if let mimeType = payload.mimeType {
                        print("MIME Type: \(mimeType)")
                    }
                    if let filename = payload.filename {
                        print("Filename: \(filename)")
                    }
                    
                    // Check for attachments
                    if let parts = payload.parts {
                        for part in parts {
                            if let filename = part.filename, let mimeType = part.mimeType {
                                // Check if the part has an attachment ID
                                if let body = part.body, let attachmentId = body.attachmentId {
                                    print("Attachment: \(filename), Mime Type: \(mimeType), Attachment ID: \(attachmentId)")
                                    
                                    // Fetch attachment data us ing attachmentId
                                    //                                    if let attachmentData = self.fetchAttachmentData(service: service, messageId: message.identifier ?? "", attachmentId: attachmentId) {
                                    //                                        // Save attachment to document directory
                                    //                                        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                                    //                                            let fileURL = documentsDirectory.appendingPathComponent(filename)
                                    //                                            do {
                                    //                                                try attachmentData.write(to: fileURL)
                                    //                                                print("Attachment saved to: \(fileURL)")
                                    //                                            } catch {
                                    //                                                print("Error saving attachment: \(error.localizedDescription)")
                                    //                                            }
                                    //                                        }
                                    //                                    }
                                } else {
                                    print("Attachment without attachmentId: \(filename), Mime Type: \(mimeType)")
                                    
                                    // Handling attachments without attachmentId
                                    // You might need to extract the attachment data from the `part.body.data` in this case.
                                    // Save the extracted data to the document directory.
                                }
                            }
                            
                            if let partBodyData = part.body?.data {
                                if let decodedBody = Data(base64Encoded: partBodyData) {
                                    if let bodyString = String(data: decodedBody, encoding: .utf8) {
                                        print("Message Body: \(bodyString)")
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            group.leave()
        }
        
        group.notify(queue: .main) {
            //
            completion()
        }
    }
    
    
    //MARK: Fetch Attachment data
    
    func fetchAttachmentData(service: GTLRGmailService, messageId: String, attachmentId: String) -> Data? {
        let attachmentQuery = GTLRGmailQuery_UsersMessagesAttachmentsGet.query(withUserId: "me", messageId: messageId, identifier: attachmentId)
        
        var attachmentData: Data?
        
        let semaphore = DispatchSemaphore(value: 0)
        
        service.executeQuery(attachmentQuery) { (ticket, response, error) in
            if let error = error {
                print("Error fetching attachment data: \(error.localizedDescription)")
                semaphore.signal()
                return
            }
            
            if let attachment = response as? GTLRGmail_MessagePartBody {
                if let attachmentBase64 = attachment.data, let data = Data(base64Encoded: attachmentBase64, options: .ignoreUnknownCharacters) {
                    attachmentData = data
                }
            }
            
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        return attachmentData
        
    }
    
    

    func getHeaderValue(_ headers: [GTLRGmail_MessagePartHeader]?, _ name: String) -> String? {
        return headers?.first(where: { $0.name?.lowercased() == name.lowercased() })?.value
    }
    
    
    func deleteMessage(messageId: String) {
        guard let service = gmailService else {
            print("Gmail service not configured")
            return
        }
        
        let deleteQuery = GTLRGmailQuery_UsersMessagesDelete.query(withUserId: "me", identifier: messageId)
        
        service.executeQuery(deleteQuery) { (ticket, response, error) in
            if let error = error {
                print("Error deleting message: \(error.localizedDescription)")
                return
            }
            
            print("Message with ID \(messageId) has been deleted.")
        }
    }
    
}







