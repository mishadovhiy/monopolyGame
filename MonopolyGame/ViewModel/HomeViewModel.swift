//
//  HomeViewModel.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 13.04.2025.
//

import UIKit

struct HomeViewModel {
    var profileImage:UIImage? = nil
    var supportRequest:NetworkModel.RequestType.SupportRequest = .init(text: "", header: "", title: "")
    var profileWidth:CGFloat {
        isNavigationPushed && isGamePresenting ? 0 : (navigationPresenting.profile ? (navigationPresenting.profileProtoPicker ? 0 : 56) : (isNavigationPushed ? 0 : 56))
    }
    var gameConnectionPickerPresenting: Bool = false
    var selectedGameConnectionType: MultiplierManager.ConnectionType?
    var supportRequestCompletion:MessageContent?
    
    func sendSupportRequest(completion:@escaping(_ ok:Bool)->()) {
        NetworkModel().support(supportRequest) { response in
            completion(response?.success ?? false)
        }
    }
    
    mutating func popToRootView(force:Bool = false) {
        if force {
            navigationPresenting = .init()
return
        }
        if navigationPresenting.sound {
            navigationPresenting.sound = false
            return
        }
        if navigationPresenting.gameSettings {
            navigationPresenting.gameSettings = false
            return
        }
        if navigationPresenting.about {
            navigationPresenting.about = false
            return
        }
        navigationPresenting = .init()
    }
    
    var isNavigationPushed:Bool {
        let dict = navigationPresenting.dict
        return dict?.values.contains(true) ?? false
    }
    var animate: Bool = false

    var isGamePresenting:Bool {
        get {
            selectedGameConnectionType != nil
        }
        set {
            if !newValue {
                gameConnectionPickerPresenting = false
                selectedGameConnectionType = nil
            }
        }
    }
    var navigationPresenting:NavigationPresenting = .init()
    struct NavigationPresenting:Codable {
        var menu = false
        var sound = false
        var gameSettings = false
        var about = false
        var rate = false
        var share = false
        var leaderBoard = false
        var gameCenter = false
        var profileProtoPicker = false
        var profile = false
        var privacy = false
        var support = false
        var clearGameConfirmation = false
        
        var dict:[String:Bool]? {
            return dictionary as? [String:Bool]
        }
    }
}
