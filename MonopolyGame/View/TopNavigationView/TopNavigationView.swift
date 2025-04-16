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
                    NavigationLink(destination: MenuView(viewModel: $viewModel), isActive: $viewModel.navigationPresenting.menu) {
                        Text("Menu")
                    }
                    .background(.green)
                    NavigationLink("", destination: LeaderboardView(viewModel: $viewModel), isActive: $viewModel.navigationPresenting.leaderBoard)
                }
                .padding(.horizontal, viewModel.isGamePresenting ? 5 : 15)
                .padding(.vertical, 5)
                .background {
                    ClearBackgroundView()
                }
                .animation(.bouncy, value: viewModel.isGamePresenting && !viewModel.isNavigationPushed)
            }
            .frame(maxWidth: viewModel.isGamePresenting && !viewModel.isNavigationPushed ? 85 : .infinity)
            .navigationViewStyle(StackNavigationViewStyle())
            .background {
                ClearBackgroundView()
            }
            .background(.red)
            .cornerRadius(12)
            .animation(.bouncy, value: viewModel.isGamePresenting && !viewModel.isNavigationPushed)

            Spacer()
                .frame(maxWidth: viewModel.isGamePresenting && !viewModel.isNavigationPushed ? .infinity : 0)
                .animation(.bouncy, value: viewModel.isGamePresenting)
                
        }
        .frame(maxHeight: viewModel.isNavigationPushed ? (viewModel.navigationPresenting.profile ? 200 : .infinity) : 85)
        .padding(.top, viewModel.isGamePresenting ? 5 : 0)
        .overlay(content: {
            HStack {
                Spacer()
                    .frame(maxWidth: viewModel.isGamePresenting ? 110 : 15)
                    .animation(.bouncy, value: viewModel.isGamePresenting)
                Button(action: {
                    if viewModel.navigationPresenting.profile {
                        viewModel.navigationPresenting.profileProtoPicker = true
                    } else {
                        viewModel.navigationPresenting.profile = true
                    }
                    
                }, label: {
                    Image(uiImage: self.viewModel.profileImage ?? .init(named: "profile1")!)
                        .frame(width: 56, height: 56)
                        .cornerRadius(56 / 2)
                })
                
                .frame(width: viewModel.isNavigationPushed && viewModel.isGamePresenting ? 0 : (viewModel.navigationPresenting.profile ? (viewModel.navigationPresenting.profileProtoPicker ? 0 : 56) : (viewModel.isNavigationPushed ? 0 : 56)))
                .padding(viewModel.navigationPresenting.profile ? 10 : 0)
                .background(content:{
                    VStack {
                        Spacer().frame(maxHeight: .infinity)
                        Color.lightsecondaryBackground
                    }
                    .background {
                        VStack {
                            RoundedRectangle(cornerRadius: 0)
                                .fill(.clear)
                                .background(content: {
                                    Color(.lightsecondaryBackground)
                                        .frame(height:56)
                                        .padding(.bottom, -40)

                                        .cornerRadius(56)
                                })
                            .frame(maxHeight: .infinity)
                            Spacer().frame(maxHeight: .infinity)
                        }
                    }
                })
                .aspectRatio(1, contentMode: .fit)
                .animation(.bouncy, value: viewModel.isNavigationPushed)
                .clipped()
                Spacer()
            }
            .animation(.bouncy, value: viewModel.isGamePresenting)

        })
        .animation(.smooth, value: viewModel.isGamePresenting)
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
