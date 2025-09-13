//
//  BluetoothManager.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 11.09.2025.
//

import Foundation
import CoreBluetooth
#if os(iOS)
import UIKit
#endif
import SwiftUI
import Combine

final class BluetoothManager: NSObject, ObservableObject {

    @Published var messages:[String:Any] = [:]
    @Published var discoveredPeripherals: [CBPeripheral] = []
    @Published var connectedPeripheral: CBPeripheral?
    var isConntected: Bool {
        test != nil || connectedPeripheral != nil
    }

    private var centralManager: CBCentralManager!
    private var peripheralManager: CBPeripheralManager!
    @Published var test: CBPeripheralManager?

    private let serviceUUID = CBUUID(string: "0000FFF0-0000-1000-8000-00805F9B34FB")
    private let characteristicUUID = CBUUID(string: "0000FFF1-0000-1000-8000-00805F9B34FB")
    private var jsonCharacteristic: CBCharacteristic?
    private var peripheralCharacteristic: CBMutableCharacteristic?

    override init() {
        super.init()
        print("bluetooth inited")
        centralManager = CBCentralManager(delegate: self, queue: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }

    private func startAdvertising() {
        let characteristic = CBMutableCharacteristic(
            type: characteristicUUID,
            properties: [.write, .notify, .read],
            value: nil,
            permissions: [.writeable, .readable]
        )
        self.peripheralCharacteristic = characteristic

        let service = CBMutableService(type: serviceUUID, primary: true)
        service.characteristics = [characteristic]
        let localName: String
        #if os(iOS)
        localName = UIDevice.current.name
        #else
        localName = UUID().uuidString
        #endif
        peripheralManager.add(service)
        peripheralManager.startAdvertising([
            CBAdvertisementDataServiceUUIDsKey: [serviceUUID],
            CBAdvertisementDataLocalNameKey: localName
        ])
    }

    private func stopAdvertising() {
        if peripheralManager.isAdvertising {
            peripheralManager.stopAdvertising()
        }
    }

    private func startScanning() {
        discoveredPeripherals.removeAll()
        centralManager.scanForPeripherals(withServices: [serviceUUID],
                                          options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }

    private func stopScanning() {
        if centralManager.isScanning {
            centralManager.stopScan()
        }
    }

    private func disconnect() {
        if let peripheral = connectedPeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
        }
        self.test = nil
        self.connectedPeripheral = nil
        discoveredPeripherals.removeAll()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }

    private func handleReceivedData(_ data: Data) {
        self.stopScanning()
        self.stopAdvertising()
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                DispatchQueue.main.async {
                    self.messages = json
                }
            }
        } catch {
            print(#line, #function, "Failed to parse JSON:", error)
        }
    }
}
 
extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            startScanning()
        default:
            break
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if !discoveredPeripherals.contains(peripheral) {
            discoveredPeripherals.append(peripheral)
        }
        print(#line, #function, discoveredPeripherals.count)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print(#line, #function)
        print("Connected to: \(peripheral.name ?? "Unknown")")
        withAnimation {
            connectedPeripheral = peripheral
        }
        peripheral.delegate = self
        peripheral.discoverServices([serviceUUID])
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect:", error?.localizedDescription ?? "")
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print(#line, #function)
        print("Disconnected from:", peripheral.name ?? "")
        
        self.disconnect()
    }
}

extension BluetoothManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print(#line, #function)
        guard let services = peripheral.services else { return }
        for service in services where service.uuid == serviceUUID {
            peripheral.discoverCharacteristics([characteristicUUID], for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        jsonCharacteristic = characteristics.first(where: { $0.uuid == characteristicUUID })
        print(jsonCharacteristic?.uuid.uuidString, " changedsdsasadasd ")
        if let characteristic = jsonCharacteristic {
            peripheral.setNotifyValue(true, for: characteristic)
        }
        let json: [String: Any] = ["message": "Hello from central"]
                    if let data = try? JSONSerialization.data(withJSONObject: json, options: []) {
                        peripheral.writeValue(data, for: jsonCharacteristic!, type: .withResponse)
                    }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print(#line, #function)
        guard let data = characteristic.value else { return }
        handleReceivedData(data)
    }
}

extension BluetoothManager: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print(#line, #function)
        switch peripheral.state {
        case .poweredOn:
            print("Peripheral powered on")
            startAdvertising()
        default:
            print("Peripheral state: \(peripheral.state.rawValue)")
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        print(#line, #function)
        peripheralManager.respond(to: request, withResult: .success)
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        print(#line, #function)
        withAnimation {
            self.test = peripheral
        }
        for request in requests {
            if let value = request.value {
                handleReceivedData(value)
                peripheral.respond(to: request, withResult: .success)
            }
        }
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("Central subscribed to characteristic")

        let json: [String: Any] = ["message": "Hello from peripheral"]
        if let data = try? JSONSerialization.data(withJSONObject: json, options: []) {
            self.jsonCharacteristic = characteristic
            print(jsonCharacteristic?.uuid.uuidString, " changedsdsasadasd thgerfwd ")

            peripheralManager.updateValue(data, for: characteristic as! CBMutableCharacteristic, onSubscribedCentrals: [central])
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        self.disconnect()
    }
}

extension BluetoothManager {
    func send(jsonData: [String: Any]?) {
        guard let jsonData,
              let data = try? JSONSerialization.data(withJSONObject: jsonData) else {
            print("error converting dictionary to data ", jsonData)
            return
        }
        guard let peripheral = connectedPeripheral,
              let characteristic = jsonCharacteristic ?? peripheralCharacteristic
        else {
            if test != nil {
                test?.updateValue(data, for: peripheralCharacteristic!, onSubscribedCentrals: nil)
            } else {
                fatalError()
            }
        return
        }
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }

    func connect(to peripheral: CBPeripheral) {
        centralManager.connect(peripheral, options: nil)
    }
}
