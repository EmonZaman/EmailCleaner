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
    struct CategorizedMessage {
        enum Category {
            case primary, promotions, social, updates, forums, sent, drafts, spam, trash
        }
        
        let message: GTLRGmail_Message
        let category: Category
        let messageReceivedDate: String?
        let isRead: Bool?
        let isHasAttachment: Bool?
        
    }
    
    
    var primaryMessages: [CategorizedMessage] = []
    var promotionsMessages: [CategorizedMessage] = []
    var sentMessages: [CategorizedMessage] = []
    var socialMessages: [CategorizedMessage] = []
    var spamMessages: [CategorizedMessage] = []
    var updatesMessages: [CategorizedMessage] = []
    var forumsMessages: [CategorizedMessage] = []
    var draftsMessages: [CategorizedMessage] = []
    var trashMessages: [CategorizedMessage] = []
    
    private var service: GTLRGmailService?
    var allMessages: [GTLRGmail_Message] = []
    
    var i = 0
    
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
        
        //   self.fetchEmails()
        
        // Do any additional setup after loading the view.
    }
    //    func requestAdditionalScopesAndMakeAPICall() {
    //        let additionalScopes = ["https://www.googleapis.com/auth/gmail.readonly"]
    //
    //        guard let currentUser = GIDSignIn.sharedInstance.currentUser else {
    //            return // Not signed in.
    //        }
    //
    //        currentUser.addScopes(additionalScopes, presenting: self) { signInResult, error in
    //            guard error == nil else { return }
    //
    //            // Get the user's granted scopes
    //            let grantedScopes = currentUser.grantedScopes
    //
    //            // Check if the user granted access to the scopes you requested.
    //            if ((grantedScopes?.contains("https://www.googleapis.com/auth/gmail.readonly")) != nil) {
    //                // Make an API call with fresh tokens
    //                currentUser.refreshTokensIfNeeded { user, error in
    //                    guard error == nil else { return }
    //                    guard let user = user else { return }
    //
    //                    // Get the access token to attach it to an API request.
    //                    let accessToken = user.accessToken.tokenString
    //
    //                    // Initialize the Gmail service
    //                    let service = GTLRGmailService()
    //                    service.authorizer = user.fetcherAuthorizer
    //
    //                    // Create a Gmail API request
    //                    let query = GTLRGmailQuery_UsersMessagesList.query(withUserId: "me")
    //                    query.q = "is:unread"
    //
    //                    service.executeQuery(query) { ticket, result, error in
    //                        // Handle the API response
    //                        if error == nil, let messages = (result as? GTLRGmail_ListMessagesResponse)?.messages {
    //                            // Process the list of unread messages
    //                            for message in messages {
    //                                if let messageId = message.identifier {
    //                                    print("Unread message ID: \(messageId)")
    //                                }
    //                            }
    //                        } else {
    //                            print("Error fetching unread messages: \(error?.localizedDescription ?? "Unknown error")")
    //                        }
    //                    }
    //                }
    //            }
    //        }
    //    }
    
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
                        self.fetchInboxMessages()
                    }
                    // Request additional Drive scope.
                }
                else{
                    
                    print("FALSE ===== else codition and authorized")
                    service.authorizer =  user.fetcherAuthorizer
                    self.gmailService = service
                    
                    // Fetch inbox messages using batch query
                    // self.fetchInboxMessages()
                    self.fetchInboxMessages()
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
    
    
    //MARK: Fetching Message working
    
    //    func fetchInboxMessages(pageToken: String? = nil) {
    //        guard let service = gmailService else {
    //            print("Gmail service not configured")
    //            return
    //        }
    //
    //        let query = GTLRGmailQuery_UsersMessagesList.query(withUserId: "me")
    //        query.pageToken = pageToken // Set the page token for pagination
    //
    //        service.executeQuery(query) { [weak self] (ticket, response, error) in
    //            guard let self = self else {
    //                return
    //            }
    //
    //            if let error = error {
    //                print("Error fetching inbox messages: \(error.localizedDescription)")
    //                return
    //            }
    //
    //            if let messagesResponse = response as? GTLRGmail_ListMessagesResponse,
    //               let messages = messagesResponse.messages {
    //                print("Fetched count \(messages.count) inbox email messages")
    //
    //                // Create a batch query to fetch message details for this page
    //                let batchQuery = GTLRBatchQuery()
    //                for message in messages {
    //                    let messageQuery = GTLRGmailQuery_UsersMessagesGet.query(withUserId: "me", identifier: message.identifier!)
    //                    messageQuery.format = kGTLRGmailFormatFull
    //                    batchQuery.addQuery(messageQuery)
    //                }
    //
    //                service.executeQuery(batchQuery) { (ticket, response, error) in
    //                    if let error = error {
    //                        print("Error fetching message details: \(error.localizedDescription)")
    //                        return
    //                    }
    //
    //                    if let batchResult = response as? [String: GTLRObject] {
    //                        for (_, result) in batchResult {
    //                            if let message = result as? GTLRGmail_Message {
    //                                if let payload = message.payload, let headers = payload.headers {
    //                                    for header in headers {
    //                                        if header.name?.lowercased() == "subject" {
    //                                            print("Message Subject: \(header.value ?? "")")
    //                                            break
    //                                        }
    //                                    }
    //                                }
    //                            }
    //                        }
    //                    }
    //
    //                    // Fetch the next page if available
    //                    if let nextPageToken = messagesResponse.nextPageToken {
    //                        self.fetchInboxMessages(pageToken: nextPageToken)
    //                    }
    //                }
    //            }
    //        }
    //    }
    
    // MARK: Testing func and working
    
    func fetchInboxMessages(pageToken: String? = nil) {
        
        guard let service = gmailService else {
            print("Gmail service not configured")
            return
        }
        
        var totalMessageFound = 0
        
        let query = GTLRGmailQuery_UsersMessagesList.query(withUserId: "me")
        // query.labelIds = ["SENT"]
        //   query.labelIds = ["INBOX", "CATEGORY_PROMOTIONS", "CATEGORY_SOCIAL", "CATEGORY_UPDATES", "CATEGORY_FORUMS", "SENT", "DRAFT", "SPAM", "TRASH"]
        query.pageToken = pageToken // Set the page token for pagination
        
        //   query.q = "is:unread"
        //   query.q = "has:attachment"
        
        query.labelIds = ["SENT"]
        query.pageToken = pageToken // Set the page token for pagination
        
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
                
                for message in messages {
                    
                    //   print(message)
                    
                        self.fetchMessageDetails(messageId: message.identifier!)
                    
                    //  self.deleteMessage(messageId: message.identifier!)
                }
                
                // Fetch the next page if available
                if let nextPageToken = messagesResponse.nextPageToken {
                    self.fetchInboxMessages(pageToken: nextPageToken)
                } else {
                    // All messages have been fetched
                    print("Total messages fetched: \(totalMessageFound)")
                }
            }
        }
    }
    
    
      //MARK: Message Details
    func fetchMessageDetails(messageId: String) {
        
    
        guard let service = gmailService else {
            print("Gmail service not configured")
            return
        }
        if i == 0 {
            self.deleteMessage(messageId: messageId)
            i += 1
        }

        let messageQuery = GTLRGmailQuery_UsersMessagesGet.query(withUserId: "me", identifier: messageId)
        messageQuery.format = kGTLRGmailFormatFull

        service.executeQuery(messageQuery) { (ticket, response, error) in
            if let error = error {
                print("Error fetching message details: \(error.localizedDescription)")
                return
            }

            //            if let message = response as? GTLRGmail_Message {
            //                if let headers = message.payload?.headers {
            //                    let sender = self.getHeaderValue(headers, "From") ?? "Unknown"
            //                    let receiver = self.getHeaderValue(headers, "To") ?? "Unknown"
            //                    let subject = self.getHeaderValue(headers, "Subject") ?? "No Subject"
            //                    print("Sender: \(sender)")
            //                    print("Receiver: \(receiver)")
            //                    print("Subject: \(subject)")
            //
            //
            //                }
            //
            //                if let body = message.payload?.body?.data {
            //                    if let decodedBody = Data(base64Encoded: body) {
            //                        if let bodyString = String(data: decodedBody, encoding: .utf8) {
            //                            print("Message Body: \(bodyString)")
            //                        }
            //                    }
            //                }
            //
            //                // Handle other parts of the message as needed
            //            }
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
        
                //   query.labelIds = ["INBOX", "CATEGORY_PROMOTIONS", "CATEGORY_SOCIAL", "CATEGORY_UPDATES", "CATEGORY_FORUMS", "SENT", "DRAFT", "SPAM", "TRASH"]
                
                if let labelIds = message.labelIds {
                     if labelIds.contains("INBOX") {
                         print("Category: Inbox")
                     }
                     if labelIds.contains("CATEGORY_PROMOTIONS") {
                         print("Category: Promotions")
                     }
                     if labelIds.contains("CATEGORY_SOCIAL") {
                         print("Category: Social")
                     }
                    if labelIds.contains("CATEGORY_UPDATES") {
                        print("Category: Update")
                    }
                    if labelIds.contains("CATEGORY_FORUMS") {
                        print("Category: Forums")
                    }
                    if labelIds.contains("DRAFT") {
                        print("Category: Draft")
                    }
                    if labelIds.contains("SENT") {
                        print("Category: Sent")
                    }
                    if labelIds.contains("SPAM") {
                        print("Category: Spam")
                    }
                    if labelIds.contains("TRASH") {
                        print("Category: Trash")
                    }
                     // Add more category checks as needed
                 }
                // ... Print other fields as needed

                if let payload = message.payload {
                    if let headers = payload.headers {
                        for header in headers {
                            if let name = header.name, let value = header.value {
                                print("Header - \(name): \(value)")
                                // Check for message category
                                                            }
                            
                        }
                    }
                    if let mimeType = payload.mimeType {
                        print("MIME Type: \(mimeType)")
                    }
                    if let filename = payload.filename {
                        print("Filename: \(filename)")
                    }
                
                    
                    if let parts = payload.parts {
                        for part in parts {
                            if let filename = part.filename, let mimeType = part.mimeType {
                                print("Attachment: \(filename), Mime Type: \(mimeType)")
                                
                            }
                        }
                    }
                    // ... Print other payload details as needed

                    if let bodyParts = payload.parts {
                        for part in bodyParts {
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

                // Handle other parts of the message as needed
            }


        }


    }
    
    
    //MARK: Fetch Message Details test

    
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
    
    
    //    func fetchMessageDetails(messageId: String) {
    //        guard let service = gmailService else {
    //            print("Gmail service not configured")
    //            return
    //        }
    //
    //        let messageQuery = GTLRGmailQuery_UsersMessagesGet.query(withUserId: "me", identifier: messageId)
    //        messageQuery.format = kGTLRGmailFormatFull
    //
    //        service.executeQuery(messageQuery) { (ticket, response, error) in
    //            if let error = error {
    //                print("Error fetching message details: \(error.localizedDescription)")
    //                return
    //            }
    //
    //            if let message = response as? GTLRGmail_Message {
    //                if let headers = message.payload?.headers {
    //                    for header in headers {
    //                        print("\(header.name!): \(header.value!)")
    //                    }
    //                }
    //
    //                if let body = message.payload?.body?.data {
    //                    if let decodedBody = Data(base64Encoded: body) {
    //                        if let bodyString = String(data: decodedBody, encoding: .utf8) {
    //                            print("Message Body: \(bodyString)")
    //                        }
    //                    }
    //                }
    //
    //                // Handle other parts of the message as needed
    //            }
    //        }
    //    }
    
    
    
    
    
    //working
    //    func fetchInboxMessages() {
    //        guard let service = gmailService else {
    //            print("Gmail service not configured")
    //            return
    //        }
    //
    //        let query = GTLRGmailQuery_UsersMessagesList.query(withUserId: "emon.twinbit@gmail.com")
    //
    //        service.executeQuery(query) { (ticket, response, error) in
    //
    //
    //            print("Ticket \(ticket)")
    //            print("Response \(response.debugDescription)")
    //            print("error \(String(describing: error))")
    //
    //            if let error = error {
    //                print("Error fetching inbox messages: \(error.localizedDescription)")
    //                return
    //            }
    //            if let messages = (response as? GTLRGmail_ListMessagesResponse)?.messages {
    //
    //                for message in messages {
    //                    print("message ======= ======    \(message)")
    //                }
    //                print("Fetched \(messages.count) inbox email messages")
    //
    //                // Create a batch query to fetch message details
    //                let batchQuery = GTLRBatchQuery()
    //                for message in messages {
    //                    let messageQuery = GTLRGmailQuery_UsersMessagesGet.query(withUserId: "me", identifier: message.identifier!)
    //                    messageQuery.format = kGTLRGmailFormatFull
    //                    batchQuery.addQuery(messageQuery)
    //                }
    //
    //                service.executeQuery(batchQuery) { [weak self] (ticket, response, error) in
    //                    guard let self = self else {
    //                        return // Exit the closure if self is nil
    //                    }
    //
    //                    if let error = error {
    //                        print("Error fetching message details: \(error.localizedDescription)")
    //                        return
    //                    }
    //
    //                    if let batchResult = response as? [String: GTLRObject] {
    //                        for (_, result) in batchResult {
    //                            if let message = result as? GTLRGmail_Message {
    //                                if let payload = message.payload, let headers = payload.headers {
    //                                    for header in headers {
    //                                        if header.name?.lowercased() == "subject" {
    //                                            print("Message Subject: \(header.value ?? "")")
    //                                            break
    //                                        }
    //                                    }
    //                                }
    //                            }
    //                        }
    //                    }
    //                }
    //            }
    //
    //
    //
    ////
    ////            if let messages = (response as? GTLRGmail_ListMessagesResponse)?.messages {
    ////                print("Fetched \(messages.count) inbox email messages")
    ////
    ////                // Create a batch query to fetch message details
    ////                let batchQuery = GTLRBatchQuery()
    ////                for message in messages {
    ////                    let messageQuery = GTLRGmailQuery_UsersMessagesGet.query(withUserId: "me", identifier: message.identifier!)
    ////                    messageQuery.format = kGTLRGmailFormatFull
    ////                    batchQuery.addQuery(messageQuery)
    ////                }
    ////
    ////                service.executeQuery(batchQuery) { [weak self] (ticket, response, error) in
    ////
    ////                    print("Ticket \(ticket)")
    ////                    print("Response \(response.debugDescription)")
    ////                    print("error \(String(describing: error))")
    ////                   // self?.displayMessageDetailsList(ticket, finishedWithObject: response as? GTLRBatchResult, error: error)
    ////                }
    ////            }
    //        }
    //    }
    
    //    func displayMessageDetailsList(_ ticket: GTLRServiceTicket, finishedWithObject response: GTLRBatchResult?, error: Error?) {
    //          if let error = error {
    //              print("Error fetching message details: \(error.localizedDescription)")
    //              return
    //          }
    //
    //          if let messageList = response?.successes as? [GTLRGmail_Message] {
    //              var messageDetails = ""
    //              for message in messageList {
    //                  if let snippet = message.snippet {
    //                      messageDetails += "Snippet: \(snippet)\n\n"
    //                  }
    //              }
    //              self.output?.text = messageDetails
    //          }
    //      }
    
    //    func fetchInboxMessages() {
    //          guard let service = gmailService else {
    //              print("Gmail service not configured")
    //              return
    //          }
    //
    //          let query = GTLRGmailQuery_UsersMessagesList.query(withUserId: "me")
    //       //   query.q = "label:inbox" // Fetch messages from the inbox
    //
    //          service.executeQuery(query) { (ticket, response, error) in
    //
    //              print("Ticket \(ticket)")
    //              print("Response \(response.debugDescription)")
    //              print("error \(String(describing: error))")
    //
    //
    //              if let error = error {
    //                  print("Error fetching inbox messages: \(error.localizedDescription)")
    //                  return
    //              }
    //
    //              if let messages = (response as? GTLRGmail_ListMessagesResponse)?.messages {
    //                  print("Fetched \(messages.count) inbox email messages")
    //                  for message in messages {
    //                      print("Message ID: \(message.identifier ?? "")")
    //                  }
    //              }
    //          }
    //      }
    
    
    //    func fetchEmails() {
    //        DispatchQueue.main.async { [weak self] in
    //            guard let self = self else { return }
    //
    //            let session = MCOIMAPSession()
    //            session.hostname = "pop.gmail.com"
    //            session.port = 995
    //            session.username = "emon.twinbit@gmail.com"
    //            session.password = "e1m2o3n4"
    //
    //
    //            let folder = "INBOX"
    //            let requestKind: MCOIMAPMessagesRequestKind = [.headers, .flags, .structure]
    //
    //            let fetchOperation = session.fetchMessagesOperation(
    //                withFolder: folder,
    //                requestKind: requestKind,
    //                uids: MCOIndexSet(range: MCORange(location: 1, length: UINT64_MAX))
    //            )
    //
    //            print("Fetch Start")
    //
    //            fetchOperation?.start { error, fetchedMessages, _ in
    //                if let error = error {
    //                    print("Failed to fetch emails: \(error)")
    //                    return
    //                }
    //                print("Fetch HERE IT COMES")
    //
    //                if let fetchedMessages = fetchedMessages as? [MCOIMAPMessage] {
    //                    self.emails = fetchedMessages
    //                    // Update UI here (e.g., reload table view)
    //                }
    //            }
    //        }
    //    }
    
    
    
}




