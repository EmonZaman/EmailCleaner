//
//  GmailService.swift
//  EmailCleaner
//
//  Created by Raqeeb on 8/22/23.
//

import GoogleSignIn
import GoogleAPIClientForREST


class GmailService {
    func fetchEmails(completion: @escaping ([Email]?, Error?) -> Void) {


        let url = URL(string: "https://www.googleapis.com/gmail/v1/users/me/messages")!

        guard let googleUser = GIDSignIn.sharedInstance.currentUser else {
               let error = NSError(domain: "GmailServiceErrorDomain", code: -1, userInfo: nil)
               completion(nil, error)
               return
           }

        let accessToken = googleUser.accessToken

           var request = URLRequest(url: url)
           request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in

            print(data)

            print(response)

            print(error)


            if let error = error {
                completion(nil, error)
                return
            }

            guard let data = data else {
                completion(nil, NSError(domain: "GmailServiceErrorDomain", code: -1, userInfo: nil))
                return
            }

            do {
                let decoder = JSONDecoder()
                let gmailApiResponse = try decoder.decode(GmailApiResponse.self, from: data)
                completion(gmailApiResponse.messages, nil)
            } catch {
                completion(nil, error)
            }
        }

        task.resume()
    }

}

// Struct to decode Gmail API response
struct GmailApiResponse: Codable {
    var messages: [Email]
}

// Model to represent email messages (customize as needed)
struct Email: Codable {
    var id: String
    var threadId: String
    // Add more properties as needed
}
