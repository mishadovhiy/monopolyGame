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
    
    @Published private var bluetoothManager: BluetoothManager?
    @Published private var robotManager: RobotManager?
    let type: ConnectionType
    var delegate: MultiplierManagerDelegate? {
        didSet {
            if isConnected {
                delegate?.didConnect()
            }
        }
    }
    private var messagesCancellable: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    
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
            self.robotManager = nil
        case .AiRobot:
            self.bluetoothManager = nil
            self.robotManager = .init()
            self.messagesCancellable = robotManager?.$messages.sink(receiveValue: { newValue in
                self.delegate?.didReciveAction(newValue)
            })
        }
        
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
    
    var isPrimaryDevice: Bool {
        self.bluetoothManager?.test == nil
    }
    
    var connectedDeviceID: String? {
        bluetoothManager?.connectedPeripheral?.identifier.uuidString
    }
    
    var isConnected: Bool {
        if type.canConnect {
            return bluetoothManager?.isConntected ?? false
        } else {
            return true
        }
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
        robotManager?.action(action: data)
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
        
        var canConnect: Bool {
            switch self {
            case .bluetooth: true
            default: false
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
            
            /// morgage, sell, when minimum balance
            case robotIncreesBalancePrediction
            case robotUpgradePropertiesPrediction
            case robotLostGame
            case roboBuyOrAuctionPrediction
        }
    }
}
