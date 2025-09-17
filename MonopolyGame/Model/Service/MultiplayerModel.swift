//
//  MultiplayerModel.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 11.09.2025.
//

import Foundation
import Combine

protocol MultiplierManagerDelegate {
    func didReciveAction(_ action: MultiplierManager.ActionUnparcer?)
    func didConnect()
    func didDisconnect()
}

class MultiplierManager: ObservableObject {
    
    @Published var bluetoothManager: BluetoothManager?
    let type: ConnectionType
    var delegate: MultiplierManagerDelegate?
    private var messagesCancellable: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    @Published var test: Bool = false
    
    var isConnected: Bool {
        bluetoothManager?.isConntected ?? false
    }
    init(
        type: ConnectionType
    ) {
        self.delegate = nil
        self.type = type
        switch type {
        case .bluetooth:
            self.bluetoothManager = .init()
            self.messagesCancellable = bluetoothManager?.$messages.sink(receiveValue: { newValue in
                self.delegate?.didReciveAction(.configure(dict: newValue))
            })
        case .AiRobot:
            self.bluetoothManager = nil
            self.messagesCancellable = nil
//            delegate.didConnect()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            self.test = true
            print("changeddd")
        })
//
        bluetoothManager?.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
                if self?.isConnected ?? false {
                    self?.delegate?.didConnect()
                } else {
                    self?.delegate?.didDisconnect()
                }
            }
            .store(in: &cancellables)
        
    }
    
    var deviceList: [UserDevice] {
        switch type {
        case .AiRobot:
            []
        case .bluetooth:
            bluetoothManager?.discoveredPeripherals.compactMap({
                .init(identifier: $0.identifier.uuidString, deviceName: $0.name ?? "unknown name")
            }) ?? []
        }
    }

    
    
    func action(_ data: ActionUnparcer) {
        print(data.data?.count, " gefwdadcs ", data.key.rawValue)
        bluetoothManager?.send(jsonData: data.dictionary ?? [:])
    }
    
    func connectToUser(deviceID: String) {
        switch self.type {
        case .AiRobot:
            break
        case .bluetooth:
            if let device = bluetoothManager?.discoveredPeripherals.first(where: {
                $0.identifier.uuidString == deviceID
            }) {
                bluetoothManager?.connect(to: device)
            }
        }
    }
}

extension MultiplierManager {
    enum ConnectionType: String, CaseIterable {
        case AiRobot, bluetooth
        
        var iconName: String {
            switch self {
            case .AiRobot:
                "brain"
            case .bluetooth:
                "bluetooth"
            }
        }
    }
    
    struct UserDevice {
        let identifier: String
        let deviceName: String
    }
    
    struct ActionUnparcer: Codable {
        let value: String
        let key: ActionKey
        let additionalValue: String?
        let data: Data?
        
        init(value: String,
             key: ActionKey,
             additionalValue: String? = nil,
             data: Data? = nil
        ) {
            self.value = value
            self.key = key
            self.additionalValue = additionalValue
            self.data = data
        }
        
        enum ActionKey: String, CaseIterable, Codable {
            // -/+/toUser - adds oposite value to the currentUser's balance
            case okPressed

            case auctionBetValue
            case tradeProposal
            case tradeResponse
            
            case topCard
            case bottomCard
            case loosePressed
            
            case playerID
            case enemyID
            case playerPosition
            case enemyPosition
            case playerMorgage
            case playerBalance
            case enemyBalance
            case boughtPlayerProperties
        }
    }
}
