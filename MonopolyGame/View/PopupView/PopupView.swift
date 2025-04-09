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
    var canClose:Bool {
        true
//        if let canCloseSet {
//            return canCloseSet
//        }
//        return dataType?.canClose ?? true
    }
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
                            Color(.white)
                                .shadow(radius: 10)
                        }
                            
                    }
                    .cornerRadius(12)
                    
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
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                    isPresenting = false
                })
            }
        }
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
                .tint(.white)
                .background {
                    Color(.blue)
                    
                }
                .cornerRadius(6)
                .shadow(radius: 4)
                .padding(.top, -5)
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
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.vertical, 5)
                .background(dataType?.color ?? .black)
                ScrollView(.vertical, content: {
                    VStack {
                        rightContentView
                    }
                })
                primaryButtons
                .frame(maxHeight: 38)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    var primaryButtons: some View {
        HStack {
            if let secondary = secondaryButton {
                primaryButton(title: secondary.title, background: .blue) {
                    secondary.pressed?()
                }
            }
            primaryButton(title: (dataType?.message?.button?.title ?? self.buttonData?.title) ?? "OK", background: .blue) {
                (buttonData?.pressed ?? dataType?.message?.button?.pressed)?()

            }
        }
    }
    
    private func primaryButton(title:String, background:Color, pressed:@escaping()->()) -> some View {
        Button {
            
            pressed()
            dismiss()
        } label: {
            Text((dataType?.message?.button?.title ?? self.buttonData?.title) ?? "OK")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(background)
                .cornerRadius(8)

        }
        .tint(.white)
    }
    
    var imageView: some View {
        HStack(alignment:.center) {
            if let image = dataType?.image {
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: .infinity)
            }
            
        }
        .background(.orange)
    }
    
    var rightContentView: some View {
        VStack {
            switch dataType {
            case .custom(let messageContent):
                Text(messageContent.title)
                Text(messageContent.description)
            case .property(let step):
                BuyPropertyView(step: step)
            default:Text("")
            }
        }
    }
}


extension PopupView {
    enum PopupType {
        case custom(MessageContent)
        case property(Step)
        
        var image:ImageResource? {
            switch self {
            case .custom(let messageContent):
                messageContent.image
            case .property(let step):
                step.image
            }
        }
        
        var message:MessageContent? {
            switch self {
            case .custom(let messageContent):
                messageContent
            case .property(let step):
                    .init(title: step.rawValue)
            }
        }
        
        var color:Color? {
            switch self {
            case .property(let step):
                step.color?.color
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

