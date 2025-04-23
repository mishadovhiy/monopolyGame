//
//  SupportView.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 23.04.2025.
//

import SwiftUI

struct SupportView: View {
    @Binding var viewModel:HomeViewModel
    
    func textField(_ title:String, text:Binding<String>) -> some View {
        VStack(alignment:.leading) {
            Text(title)
                .font(.system(size: 14, weight:.semibold))
                .foregroundColor(.light)

            TextField("", text: text)
                .foregroundColor(.light)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var body: some View {
        VStack {
            Spacer().frame(height: 10)
            ScrollView(.vertical) {
                VStack {
                    VStack {
                        self.textField("Header", text: $viewModel.supportRequest.header)
                        Divider()
                        self.textField("Title", text: $viewModel.supportRequest.title)
                        Divider()
                        self.textField("Text", text: $viewModel.supportRequest.text)
                        Divider()
                        VStack {
                            Text(viewModel.supportRequestCompletion?.title ?? "")
                                .font(.system(size: 16, weight:.semibold))
                                .foregroundColor(.light)

                            Text(viewModel.supportRequestCompletion?.description ?? "")
                                .font(.system(size: 12))
                                .foregroundColor(.secondaryText)
                        }
                        .frame(maxHeight:viewModel.supportRequestCompletion != nil ? .infinity : 0)
                        .clipped()
                        .animation(.bouncy, value: viewModel.supportRequestCompletion != nil)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 10)
                    .background(.lightsecondaryBackground)
                    .cornerRadius(10)
                    HStack {
                        Spacer()
                        Button("Send") {
                            viewModel.sendSupportRequest { ok in
                                if ok {
                                    
                                }
                                withAnimation {
                                    viewModel.supportRequestCompletion = ok ? .init(title: "Your request has been sent!") : .init(title: "Error sending request", description:"Try again later")
                                    if ok {
                                        viewModel.supportRequest = .init(text: "", header: "", title: "")
                                    }
                                    
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                                    withAnimation {
                                        viewModel.supportRequestCompletion = nil
                                    }
                                })
                            }
                        }
                        .disabled(NetworkModel.RequestType.support(viewModel.supportRequest).isInvalid)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 15)
                        .background(.primaryBackground)
                        .cornerRadius(4)
                    }
                }
            }
            .frame(maxWidth: .infinity)

        }
        .frame(maxWidth: .infinity)
        .background(.secondaryBackground)
        .background {
            ClearBackgroundView()
        }
    }
}

