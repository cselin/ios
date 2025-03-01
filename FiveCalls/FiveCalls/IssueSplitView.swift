//
//  IssueSplitView.swift
//  FiveCalls
//
//  Created by Christopher Selin on 11/1/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI

struct IssueSplitView: View {
    @EnvironmentObject var store: Store
    
    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all), sidebar: {
            Dashboard(selectedIssue: $store.state.issueRouter.selectedIssue)
        }, detail: {
            NavigationStack(path: $store.state.issueRouter.path) {
                if let selectedIssue = store.state.issueRouter.selectedIssue {
                    IssueDetail(issue: selectedIssue,
                                contacts: selectedIssue.contactsForIssue(allContacts: store.state.contacts))
                    .navigationDestination(for: IssueDetailNavModel.self) { idnm in
                        IssueContactDetail(issue: idnm.issue, remainingContacts: idnm.contacts)
                    }.navigationDestination(for: IssueNavModel.self) { inm in
                        IssueDone(issue: inm.issue)
                    }
                } else {
                    HStack {
                        Image(systemName: "arrowshape.left.fill")
                            .font(.title)
                            .foregroundColor(.secondary)
                        VStack(alignment: .leading) {
                            Text(R.string.localizable.chooseIssuePlaceholder())
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            Text(R.string.localizable.chooseIssueSubheading())
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        })
        .navigationSplitViewStyle(.balanced)
    }
}

struct IssueSplitView_Previews: PreviewProvider {
    static let previewState = {
        var state = AppState()
        state.issues = [
            Issue.basicPreviewIssue,
            Issue.multilinePreviewIssue
        ]
        state.contacts = [
            Contact.housePreviewContact,
            Contact.senatePreviewContact1,
            Contact.senatePreviewContact2
        ]
        return state
    }()

    static let store = Store(state: previewState, middlewares: [appMiddleware()])
    
    static var previews: some View {
        IssueSplitView().environmentObject(store)
    }
}
