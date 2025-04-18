//
//  TopNavigationView.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 13.04.2025.
//

import SwiftUI

struct TopNavigationView: View {
    @Binding var viewModel:HomeViewModel
    @EnvironmentObject var db:AppData
    var body: some View {
        HStack {
            NavigationView {
                HStack(spacing:0) {
                    NavigationLink(destination: ProfileView(viewModel: $viewModel, image: $viewModel.profileImage), isActive: $viewModel.navigationPresenting.profile) {
                        Text("Profile")
                    }
                    .hidden()
                    Spacer()
                        .frame(maxWidth: !viewModel.isGamePresenting ? .infinity : 0)
                        .animation(.bouncy, value: viewModel.isGamePresenting)
                    NavigationLink(destination: MenuView(viewModel: $viewModel), isActive: .init(get: {
                        viewModel.navigationPresenting.menu
                    }, set: { newValue in
                        withAnimation {
                            viewModel.navigationPresenting.menu = newValue
                        }
                    })) {
                        Image(viewModel.isGamePresenting ? .pause : .menu)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight:.infinity)
                            .frame(width:viewModel.isGamePresenting ? 20 : 35)
                            .animation(.bouncy, value: viewModel.isGamePresenting)

                    }
                    .padding(viewModel.isGamePresenting ? -20 : 0)
                    .offset(x:viewModel.isGamePresenting ? -5 : 0)
                    .animation(.bouncy, value: viewModel.isGamePresenting)
                    NavigationLink("", destination: LeaderboardView(viewModel: $viewModel), isActive: .init(get: {
                        viewModel.navigationPresenting.leaderBoard
                    }, set: { newValue in
                        withAnimation {
                            viewModel.navigationPresenting.leaderBoard = newValue
                        }
                    }))
                }
                .padding(.horizontal, viewModel.isGamePresenting ? 5 : 15)
                .padding(.vertical, viewModel.isGamePresenting ? 0 : 5)
                .background {
                    ClearBackgroundView()
                }
                .animation(.bouncy, value: viewModel.isGamePresenting && !viewModel.isNavigationPushed)
            }
            .tint(.white)
            .foregroundColor(.white)
            .frame(maxWidth: viewModel.isGamePresenting && !viewModel.isNavigationPushed ? 45 : .infinity)
            .navigationViewStyle(StackNavigationViewStyle())
            .background {
                ClearBackgroundView()
            }
            .padding(.horizontal, viewModel.isGamePresenting && !viewModel.isNavigationPushed ? 0 : 10)
            .padding(.bottom, viewModel.isGamePresenting || !viewModel.isNavigationPushed ? 0 : 10)
            .background(.secondaryBackground)
            .cornerRadius(12)
            .animation(.bouncy, value: viewModel.isGamePresenting && !viewModel.isNavigationPushed)
            .padding(10)
            Spacer()
                .frame(maxWidth: viewModel.isGamePresenting && !viewModel.isNavigationPushed ? .infinity : 0)
                .animation(.bouncy, value: viewModel.isGamePresenting)
                
        }
        .frame(maxHeight: viewModel.isNavigationPushed ? (viewModel.navigationPresenting.profile ? 180 : (viewModel.navigationPresenting.leaderBoard ? .infinity : (viewModel.navigationPresenting.dict?.values.filter({$0}).count ?? 0) <= 1 ? 140 : .infinity)) : 85)
        .padding(.top, viewModel.isGamePresenting ? 5 : 0)
        .overlay(content: {
            HStack {
                Spacer()
                    .frame(maxWidth: viewModel.isGamePresenting ? 70 : (viewModel.navigationPresenting.profile ? 35 : 15))
                    .animation(.bouncy, value: viewModel.isGamePresenting)
                Button(action: {
                    if viewModel.navigationPresenting.profile {
                        viewModel.navigationPresenting.profileProtoPicker = true
                    } else {

                        withAnimation {
                            viewModel.navigationPresenting.profile = true

                        }
                    }
                    
                }, label: {
                    Image(uiImage: self.viewModel.profileImage ?? .init(named: "profile1")!)
                        .frame(width: self.viewModel.isGamePresenting ? 45 : 56, height: self.viewModel.isGamePresenting ? 45 : 56)
                        .cornerRadius(56 / 2)
                        .animation(.bouncy, value: self.viewModel.isGamePresenting)

                })
                .offset(y:viewModel.navigationPresenting.profile ? -5 : (viewModel.isGamePresenting ? 3 : 0))
                .frame(width: viewModel.profileWidth)
                .padding(viewModel.navigationPresenting.profile ? 10 : 0)
                .aspectRatio(1, contentMode: .fit)
                .animation(.bouncy, value: viewModel.isNavigationPushed)
                .clipped()
                .disabled(viewModel.profileWidth == 0 || viewModel.isGamePresenting)
                Spacer()
            }
            .animation(.bouncy, value: viewModel.isGamePresenting)

        })
        .animation(.smooth, value: (viewModel.isGamePresenting || viewModel.isNavigationPushed))
        .sheet(isPresented: $viewModel.navigationPresenting.share, content: {ShareSheet(items: [Keys.shareAppURL])})
        .onAppear {
            setProfileImage()
        }
    }
    
    func setProfileImage() {
        print(db.db.profile.imageURL, " yhrtgerfds ")
        if db.db.profile.imageURL.isEmpty {
            viewModel.profileImage = .init(named: "profile1")
        } else {
            FileManagerModel().load(imageName: db.db.profile.imageURL, quality: .middle) { newImage in
                viewModel.profileImage = newImage

            }

        }
    }
}
