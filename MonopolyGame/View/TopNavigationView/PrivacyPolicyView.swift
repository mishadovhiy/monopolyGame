//
//  PrivacyPolicyView.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 23.04.2025.
//

import SwiftUI

struct PrivacyPolicyView: View {
    @State var urlContent:String = ""
    @Binding var viewModel:HomeViewModel
    
    var body: some View {
        VStack(content: {
            HStack(spacing:20) {
                Button("Website") {
                    if let url = URL(string: Keys.websiteURL.rawValue) {
                        UIApplication.shared.open(url)
                    }
                }

                NavigationLink(destination: SupportView(viewModel: $viewModel), isActive: $viewModel.navigationPresenting.support) {
                    Text("Support")
                }
                Spacer()
            }
            UpdateView(html: urlContent)
                .cornerRadius(6)
        })
        .background(.secondaryBackground)

        .background {
            ClearBackgroundView()
        }
        .onAppear {
            DispatchQueue.init(label: "api", qos: .userInitiated).async {
                NetworkModel().fetchStringFrom(Keys.privacyPolicy.rawValue) { content in
                    DispatchQueue.main.async {
                        self.urlContent = """
<!DOCTYPE html>
<html lang="en">
<head>
</head>
<style>
html, body{background: #3A3A3A;}
h2{ font-size: 18px; color: white; }h1{font-size: 32px; color: white;}
p{font-size: 12px; color: white;}
</style>
<body>
""" + ((content ?? "").extractSubstring(key: "!--Privacy--", key2: "!--/Privacy--") ?? "") + """
    </body>
    </html>
    """
                        print(urlContent, " rgtfsd ")
                    }
                }
            }
        }
    }
}

