//
//  AboutSheet.swift
//  FiveCalls
//
//  Created by Christopher Selin on 9/18/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI
import MessageUI
import StoreKit

private let appId = "1202558609"
private let appUrl = URL(string: "https://itunes.apple.com/us/app/myapp/id\(appId)?ls=1&mt=8")

struct AboutSheet: View {
    @Environment(\.dismiss) var dismiss
    
    @State var showEmailComposer = false
    @State var showEmailComposerAlert = false
    private var versionString: String? = {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return nil
        }
        
        var string = "v" + version
        if let userID = SessionManager.shared.userID {
            string = "\(string) - \(userID)"
        }
        
        return string
    }()
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("GENERAL")) {
                    NavigationLink(value: WebViewContent.whycall) {
                        Text("Why Calling Works")
                            .foregroundStyle(.black)
                    }
                    NavigationLink(value: WebViewContent.whoweare) {
                        Text("Who Made 5 Calls?")
                            .foregroundStyle(.black)
                    }
                    .navigationDestination(for: WebViewContent.self) { webViewContent in
                        WebView(webViewContent: webViewContent)
                            .navigationTitle(webViewContent.navigationTitle)
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbarBackground(.visible)
                            .toolbarBackground(Color.fivecallsDarkBlue)
                            .toolbarColorScheme(.dark, for: .navigationBar)

                    }
                    AboutListItem(title: "Feedback") {
                        AnalyticsManager.shared.trackEventOld(withName: "Action: Feedback")
                        if EmailComposerView.canSendEmail() {
                            showEmailComposer = true
                        } else {
                            showEmailComposerAlert = true
                        }
                    }
                    .sheet(isPresented: $showEmailComposer, content: {
                        EmailComposerView() { _ in }
                    })
                    .alert(isPresented: $showEmailComposerAlert) {
                        Alert(title: Text(R.string.localizable.cantSendEmailTitle()),
                              message: Text(R.string.localizable.cantSendEmailMessage()),
                              dismissButton: .default(Text(R.string.localizable.dismissTitle())))
                    }
                }
                
                Section(header: Text("SOCIAL")) {
                    AboutListItem(title: "Follow on Twitter") {
                        followOnTwitter()
                    }
                    if appUrl != nil {
                        ShareLink(item: appUrl!) {
                            HStack {
                                Text("Share with Others")
                                    .foregroundStyle(.black)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                        
                    }
                    AboutListItem(title: "Please Rate 5 Calls") { requestReview() }
                }
                
                if let versionString {
                    Section(header: HStack {
                        Spacer()
                        Text(versionString)
                            .font(.caption)
                            .foregroundStyle(.gray)
                        Spacer()
                    },
                            content: {})
                }
            }
            .listStyle(.grouped)
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbarBackground(.visible)
            .toolbarBackground(Color.fivecallsDarkBlue)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        self.dismiss()
                    }) {
                        Text(R.string.localizable.doneButtonTitle())
                            .bold()
                    }
                }
            }
        }
        .accentColor(.white)
    }
    
    func followOnTwitter() {
        AnalyticsManager.shared.trackEventOld(withName: "Action: Follow On Twitter")
        guard let url = URL(string: "https://twitter.com/make5calls") else { return }
        UIApplication.shared.open(url)
    }

    
    func requestReview() {
        AnalyticsManager.shared.trackEventOld(withName: "Action: Rate the App")
        guard let currentScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return
        }
        
        SKStoreReviewController.requestReview(in: currentScene)
    }
}

struct AboutSheet_Previews: PreviewProvider {
    static var previews: some View {
        AboutSheet()
    }
}

struct EmailComposerView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
    var result: (Result<MFMailComposeResult, Error>) -> Void
    
    static func canSendEmail() -> Bool {
        MFMailComposeViewController.canSendMail()
    }
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let emailComposer = MFMailComposeViewController()
        emailComposer.mailComposeDelegate = context.coordinator
        emailComposer.setToRecipients(["make5calls@gmail.com"])
        emailComposer.setMessageBody("", isHTML: true)
        return emailComposer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController,
                                context: Context) { }
    
    func makeCoordinator() -> Coordinator {
         Coordinator(self)
     }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: EmailComposerView
        
        init(_ parent: EmailComposerView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
                
                if let error = error {
                    parent.result(.failure(error))
                    return
                }
                
                parent.result(.success(result))
                
                parent.presentationMode.wrappedValue.dismiss()
            }
    }
}

struct AboutListItem: View {
    var title: String
    var action: () -> Void

    var body: some View {
        Button(action: action, label: {
            HStack {
                Text(title)
                    .foregroundStyle(.black)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        })
    }
}
