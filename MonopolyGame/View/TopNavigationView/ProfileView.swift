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
    @State var image:UIImage? = nil
    var body: some View {
        VStack {
            HStack {
                NavigationLink(destination: PhotoLibraryView(imageSelected: { newImage in
                    FileManagerModel().upload(ImageQuality.allCases, newImage ?? .init(), name: "profile") {
                        self.image = newImage
                        if newImage == nil {
                            db.db.profile.imageURL = "profile1"
                        } else {
                            db.db.profile.imageURL = "profile"
                        }
                    } error: {
                    }

                }, isPreseting: $viewModel.navigationPresenting.profileProtoPicker), isActive: $viewModel.navigationPresenting.profileProtoPicker) {
                    Image(uiImage: self.image ?? .init(named: "profile1")!)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                }
                TextField("Profile name", text: $db.db.profile.username)
            }
            ScrollView(.horizontal) {
                HStack {
                    ForEach((1..<5), id:\.self) { i in
                        Image("profile\(i)")
                            .resizable()
                            .scaledToFit()
                            .frame(width:30, height: 30)
                    }
                }
            }
            
        }
        .onAppear {
            FileManagerModel().load(imageName: "profile", quality: .middle) { image in
                self.image = image ?? .init(named: "profile1")
            }
        }
    }
}

