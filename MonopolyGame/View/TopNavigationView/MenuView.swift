//
//  MenuView.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 13.04.2025.
//

import SwiftUI

struct MenuView: View {
    @Binding var viewModel:HomeViewModel
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    topMenu
                    Spacer()
                }
                .frame(alignment: .leading)
                HStack {
                    bottomMenu
                    Spacer()
                }
            }
            Spacer()
        }
        .background {
            ClearBackgroundView()
        }
        .background(.secondaryBackground)
    }
    
    @ViewBuilder
    var topMenu: some View {
        self.navigationLink(
            title: "Sound",
            NavigationDestinationType(isActive: $viewModel.navigationPresenting.sound,
                                      destination: AnyView(SoundSettingsView(viewModel: $viewModel))))
        self.navigationLink(
            title: "Game Settings",
            isHidden: viewModel.isGamePresenting,
            NavigationDestinationType(isActive: $viewModel.navigationPresenting.gameSettings,
                                      destination: AnyView(GameSettingsView( viewModel: $viewModel))))
        
        self.navigationLink(isDistructive: true,
                            title: "Close game", isHidden: !viewModel.isGamePresenting,
                            ButtonType(didPress: {
            withAnimation {
                viewModel.isGamePresenting = false
                viewModel.popToRootView()
            }
        }))
    }
    
    @ViewBuilder
    var bottomMenu: some View {
        self.navigationLink(
            title: "About",
            NavigationDestinationType(isActive: $viewModel.navigationPresenting.about,
                                      destination: AnyView(AboutView())))
        
        self.navigationLink(
            title: "Privacy",
            NavigationDestinationType(isActive: $viewModel.navigationPresenting.privacy,
                                      destination: AnyView(PrivacyPolicyView(viewModel: $viewModel))))
        
        self.navigationLink(isPrimary: false,
                            title: "Rate",
                            ButtonType(didPress: {
            StorekitModel().requestReview()
        }))
        
        self.navigationLink(isPrimary: false,
                            title: "Share App",
                            ButtonType(didPress: {
            viewModel.navigationPresenting.share = true
        }))
    }
    
    @ViewBuilder
    fileprivate func navigationLink(isPrimary: Bool = true,
                                    isDistructive: Bool = false,
                                    title: String,
                                    isHidden: Bool = false,
                                    _ navigation: MenuButtonType) -> some View
    {
        if !isHidden {
            navigationButton(
                buttonContent: Text(title)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 5)
                    .background(Color(uiColor: isDistructive ? .init(resource: .red) : .lightsecondaryBackground).opacity(isPrimary ? 1 : 0.4))
                    .cornerRadius(4),
                data: navigation)
        }
    }
    
    @ViewBuilder
    fileprivate func navigationButton(
        buttonContent: some View,
        data: MenuButtonType
    ) -> some View {
        if let data = data as? NavigationDestinationType {
            NavigationLink(
                destination: data.destination,
                isActive: data.isActive
            ) {
                buttonContent
            }
        } else if let data = data as? ButtonType {
            Button {
                data.didPress()
            } label: {
                buttonContent
            }
            
        }
    }
}

fileprivate protocol MenuButtonType { }

fileprivate extension MenuView {
    struct NavigationDestinationType: MenuButtonType {
        let isActive: Binding<Bool>
        let destination: AnyView
    }
    
    struct ButtonType: MenuButtonType {
        let didPress: ()->()
    }
}
