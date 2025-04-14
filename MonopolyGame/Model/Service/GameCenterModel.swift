//
//  GameCenterModel.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 14.04.2025.
//

import GameKit

class GameCenterModel:NSObject {
    func configureGameCenterPlayer() {
        let localPlayer = GKLocalPlayer.local
        localPlayer.authenticateHandler = { viewController, error in
            if let viewController = viewController {
                self.rootVC?.present(viewController, animated: true)
            } else if localPlayer.isAuthenticated {
            } else {
                print("Game Center authentication failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    func presentAchievements() {
        let gameCenterViewController = GKGameCenterViewController()
        gameCenterViewController.gameCenterDelegate = self
        gameCenterViewController.viewState = .leaderboards
        rootVC!.present(gameCenterViewController, animated: true)
    }
    
    private var rootVC:UIViewController? {
        if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
           let vc = windowScene.keyWindow?.rootViewController
        {
            return vc
        }
        return nil
    }
}

extension GameCenterModel: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        if let vc = rootVC?.presentedViewController as? GKGameCenterViewController {
            vc.dismiss(animated: true)
        }
    }
}
