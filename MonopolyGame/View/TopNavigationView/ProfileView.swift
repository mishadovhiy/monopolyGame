//
//  ProfileView.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 14.04.2025.
//

import SwiftUI

struct ProfileView: View {
    @Binding var viewModel:HomeViewModel
    @EnvironmentObject var db:AppData
    @Binding var image:UIImage?
    var body: some View {
        HStack {
            Spacer().frame(width: 90)
            VStack {
                HStack {
                    NavigationLink(destination: PhotoLibraryView(imageSelected: { newImage in
                        self.imageSelected(image: newImage)

                    }, isPreseting: $viewModel.navigationPresenting.profileProtoPicker), isActive: $viewModel.navigationPresenting.profileProtoPicker) {
                        
                    }
                    .hidden()
                    TextField("Profile name", text: $db.db.profile.username)
                }
                ScrollView(.horizontal) {
                    HStack {
                        ForEach((1..<5), id:\.self) { i in
                            Button {
                                self.imageSelected(image: .init(named: "profile\(i)"))
                            } label: {
                                Image("profile\(i)")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width:30, height: 30)
                            }

                        }
                    }
                    .padding(.leading, 75)
                    .padding(.vertical, 20)
                    .padding(.trailing, 20)
                    .background {
                        Color.lightsecondaryBackground
                            .cornerRadius(100)

                    }
                }
                .padding(.leading, -75)
                .background {
                    HStack {
                        Color.lightsecondaryBackground
                            .cornerRadius(100)
                        Spacer().frame(maxWidth: .infinity)
                    }
                    .padding(.leading, -75)
                }

            }
        }

    }
    
    func imageSelected(image:UIImage?) {
        FileManagerModel().upload(ImageQuality.allCases, image ?? .init(named: "profile1")!, name: "profile") {
            self.image = image
            if image == nil {
                db.db.profile.imageURL = "profile1"
            } else {
                db.db.profile.imageURL = "profile"
            }
        } error: {
        }
    }
}

