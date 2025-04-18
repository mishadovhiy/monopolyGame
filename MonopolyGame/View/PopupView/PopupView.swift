//
//  PopupView.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 08.04.2025.
//

import SwiftUI

struct PopupView: View {
    @Binding var dataType:PopupType?
    @Binding var buttonData:ButtonData?
    @Binding var secondaryButton:ButtonData?
    @State var isPresenting = false

    var canCloseSet:Bool? = nil

    var body: some View {
        VStack {
            Spacer()
                .frame(maxHeight: .infinity)
            HStack {
                Spacer()
                    .frame(maxWidth: 20)
                contentView
                    .background {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.red, lineWidth: 1)
                            Color(.secondaryBackground)
                                .cornerRadius(6)
                                .shadow(radius: 10)
                        }
                            
                    }
                    .cornerRadius(12)
                    .shadow(radius: 10)
                Spacer()
                    .frame(maxWidth: 20)
            }
                .frame(maxHeight: !isPresenting ? 0 : .infinity)
                .clipped()
                .overlay {
                    if canClose {
                        closeButton
                    }
                }
                .animation(.bouncy, value: !isPresenting)
            Spacer()
                .frame(maxHeight: !isPresenting ? 0 : .infinity)
                .animation(.bouncy, value: !isPresenting)
        }
        .background {
            Color.black.opacity(!isPresenting ? 0 : 0.15)
                .ignoresSafeArea(.all)
                .animation(.smooth, value: !isPresenting)
                
        }
        .onChange(of: isPresenting) { newValue in
            if !newValue {
                buttonData = nil
                secondaryButton = nil
            }
        }
        .onChange(of: dataType?.message != nil) { newValue in
            if newValue {
                withAnimation {
                    isPresenting = true
                }
            } else {
                withAnimation {
                    isPresenting = false
                }
            }
        }
    }
    
    var canClose:Bool {
        true
//        if let canCloseSet {
//            return canCloseSet
//        }
//        return dataType?.canClose ?? true
    }
    
    var closeButton: some View {
        HStack {
            Spacer()
            VStack {
                Button {
                    dismiss()
                } label: {
                    Text("+")
                        .padding(10)

                }
                .tint(.light)
                .background {
                    Color(.lightsecondaryBackground)
                    
                }
                .cornerRadius(6)
                .shadow(radius: 4)
                .padding(.top, -8)
                .padding(.trailing, 5)
                
                Spacer()
            }
        }
        .opacity(isPresenting ? 1 : 0)
        .animation(.bouncy, value: isPresenting)
        
    }
    
    func dismiss() {
        withAnimation(.bouncy) {
            isPresenting = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            self.dataType = nil
        })
    }
    
    var contentView: some View {
        HStack(spacing:0) {
            imageView.frame(maxWidth: .infinity, maxHeight: .infinity)
            VStack(spacing:0) {
                HStack {
                    Spacer()
                    Text(dataType?.message?.title ?? "")
                        .foregroundColor(.light)
                    Spacer()
                }
                .padding(.vertical, 5)
                ScrollView(.vertical, content: {
                    VStack {
                        rightContentView
                    }
                })
                .frame(maxHeight: .infinity)
                primaryButtons
                .frame(maxHeight: 38)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    var primaryButtons: some View {
        HStack {
            if let secondary = secondaryButton {
                primaryButton(title: secondary.title, background: .lightsecondaryBackground) {
                    secondary.pressed?()
                }
            }
            primaryButton(title: (dataType?.message?.button?.title ?? self.buttonData?.title) ?? "OK", background: .light) {
                (buttonData?.pressed ?? dataType?.message?.button?.pressed)?()

            }
        }
    }
    
    private func primaryButton(title:String, background:Color, pressed:@escaping()->()) -> some View {
        Button {
            
            pressed()
            dismiss()
        } label: {
            Text(title)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(background)
                .cornerRadius(8)

        }
        .tint(.white)
    }
    
    var imageView: some View {
        HStack(alignment:.center) {
            switch self.dataType {
            case .custom(let messageContent):
                if let image = messageContent.image {
                    Image(image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: .infinity)
                }
            case .property(let step):
                PropertyView(step: step.property, higlightUpgrade: step.ownerUpgrade, needPrice: false)
                    
            default:Text("").hidden()
            }
            
        }
//        .background(dataType?.color ?? .secondaryBackground)
    }
    
    var rightContentView: some View {
        VStack {
            switch dataType {
            case .custom(let messageContent):
                Text(messageContent.title)
                    .foregroundColor(.light)

                Text(messageContent.description)
                    .foregroundColor(.light)

            case .property(let step):
                BuyPopupContentView(step: step.property, owner: step.owner)
            default:Text("")
            }
        }
    }
}


extension PopupView {
    enum PopupType {
        case custom(MessageContent)
        case property(Property)
        
        struct Property {
            var owner:String?
            var ownerUpgrade:PlayerStepModel.Upgrade?
            var property:Step
        }
        
        var image:ImageResource? {
            switch self {
            case .custom(let messageContent):
                messageContent.image
            case .property(_):
                nil
            }
        }
        
        var message:MessageContent? {
            switch self {
            case .custom(let messageContent):
                messageContent
            case .property(_):
                    .init(title: "Buy Property")
            }
        }
        
        var color:Color? {
            switch self {
            case .property(let step):
                step.property.color?.color
            default:nil
            }
        }
        
        var canClose:Bool {
            switch self {
            case .custom(_):
                true
            case .property(_):
                false
            }
        }
    }
}

