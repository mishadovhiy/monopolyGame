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
        rootVC?.present(gameCenterViewController, animated: true)
    }
    
    private var rootVC:UIViewController? {
        if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
           let vc = windowScene.keyWindow?.rootViewController
        {
            return vc
        }
        return nil
    }
    
    func addGameCompletionScore(_ progress:PlayerStepModel) {
        let loeaderboard = GKLeaderboard()
        loeaderboard.identifier = Keys.gameCenterLeaderboardID.rawValue
        loeaderboard.loadScores { scores, error in
            var score = scores?.first(where: {
                $0.playerID == GKLocalPlayer.local.playerID
            })?.value ?? 0

            score += Int64(progress.balance + progress.bought.totalPrice.price)
            let newScore = GKScore(leaderboardIdentifier: Keys.gameCenterLeaderboardID.rawValue)
            newScore.value = score
            GKScore.report([newScore]) { error in
                print("reporterror: ", error?.localizedDescription)
            }
        }

    }
}

extension GameCenterModel: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        if let vc = rootVC?.presentedViewController as? GKGameCenterViewController {
            vc.dismiss(animated: true)
        }
    }
}
