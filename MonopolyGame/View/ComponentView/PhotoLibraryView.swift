//
//  PhotoibraryView.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 14.04.2025.
//

import UIKit
import SwiftUI
import AVFoundation

struct PhotoLibraryView: UIViewControllerRepresentable {
    let imageSelected:(_ newImage:UIImage?)->()
    var dissmiss:(()->())? = nil
    @Binding var isPreseting:Bool
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let vc = PhotoLibraryVC()
        vc.didSelectImage = self.imageSelected
        vc.didDismiss = dissmiss
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        guard let vc = uiViewController as? PhotoLibraryVC else { return}
        if isPreseting {
            vc.cameraModel?.resume()
        } else {
            vc.cameraModel?.stop()
        }
    }
}

class PhotoLibraryVC: UIViewController {
    var didSelectImage:((_ image:UIImage?)->())?
    var didDismiss:(()->())?
    
    private var contentStack:UIStackView? {
        view.subviews.first as? UIStackView
    }
    
    private var buttonsStack:UIStackView? {
        contentStack?.arrangedSubviews.first(where: {
            $0.layer.name == "buttonsStack"
        }) as? UIStackView
    }
    /// opens camera view
    var cameraButton:UIButton? {
        buttonsStack?.arrangedSubviews.first(where: {
            $0.tag == 0
        }) as? UIButton
    }
    /// opens photo library view
    var photoLibButton:UIButton? {
        buttonsStack?.arrangedSubviews.first(where: {
            $0.tag == 1
        }) as? UIButton
    }
    var captureButton:UIButton? {
        view.subviews.first(where: {
            $0.layer.name == "captureButton"
        }) as? UIButton
    }
    
    var cameraView:UIView? {
        contentStack?.arrangedSubviews.first(where: {
            $0.layer.name == "camera"
        })
    }
    var photoLibraryView:UIView? {
        contentStack?.arrangedSubviews.first(where: {
            $0.layer.name == "photoLib"
        })
    }
    
    var cameraModel:CameraModel?
    
    override func removeFromParent() {
        super.removeFromParent()
        self.cameraModel?.stop()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.cameraModel?.stop()
    }
    
    override func loadView() {
        let libButton = UIButton()
        let cameraButton = UIButton()
        cameraButton.setTitle(" Open camera", for: [])
//        cameraButton.setImage(.camera, for: [])
        cameraButton.addTarget(self, action: #selector(cameraPressed(_:)), for: .touchUpInside)

        cameraButton.tag = 0
        libButton.setTitle(" Open Photo library", for: [])
        
//        libButton.setImage(.photoLibrary, for: [])
        libButton.addTarget(self, action: #selector(photoLibraryPressed(_:)), for: .touchUpInside)
        libButton.tag = 1
        
        

        let buttonStack = UIStackView()
        buttonStack.layer.name = "buttonsStack"
        buttonStack.axis = .horizontal
        buttonStack.alignment = .fill
        buttonStack.distribution = .equalSpacing
        [cameraButton, libButton].forEach {
            $0.backgroundColor = .systemPink
            $0.layer.cornerRadius = 5
            $0.layer.masksToBounds = true
            $0.tintColor = .white
            $0.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
            $0.contentEdgeInsets = .init(top: 0, left: 10, bottom: 0, right: 10)
            buttonStack.addArrangedSubview($0)
        }
        
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .fill
        
        let cameraHolder:UIView = .init()
        cameraHolder.layer.name = "camera"
        cameraHolder.layer.cornerRadius = 10
        cameraHolder.layer.masksToBounds = true
        let photoLibContainer = UIView()
        photoLibContainer.layer.name = "photoLib"
        [buttonStack, photoLibContainer, cameraHolder].forEach {
            stack.addArrangedSubview($0)
        }
        photoLibContainer.layer.cornerRadius = 10
        photoLibContainer.layer.masksToBounds = true
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.viewControllers.first?.view.layer.cornerRadius = 10
        vc.viewControllers.first?.view.layer.masksToBounds = true
        vc.view.backgroundColor = .clear
        vc.view.layer.cornerRadius = 10
        vc.view.layer.masksToBounds = true
        vc.navigationBar.topItem?.leftBarButtonItem = nil
        vc.navigationController?.isToolbarHidden = true
        photoLibContainer.addSubview(vc.view)
        addChild(vc)
        vc.didMove(toParent: self)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        vc.view.leadingAnchor.constraint(equalTo: vc.view.superview!.leadingAnchor).isActive = true
        vc.view.trailingAnchor.constraint(equalTo: vc.view.superview!.trailingAnchor).isActive = true
        vc.view.topAnchor.constraint(equalTo: vc.view.superview!.topAnchor).isActive = true
        vc.view.bottomAnchor.constraint(equalTo: vc.view.superview!.bottomAnchor).isActive = true
        
        let captureButton = UIButton()
        captureButton.tag = 2
        captureButton.layer.name = "captureButton"
        captureButton.setTitle("capture", for: [])
//        captureButton.setImage(.capture, for: [])
        captureButton.tintColor = .white
        captureButton.addTarget(self, action: #selector(capturePressed(_:)), for: .touchUpInside)
        super.loadView()
        
        view.addSubview(stack)
        view.addSubview(captureButton)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.leadingAnchor.constraint(equalTo: stack.superview!.leadingAnchor).isActive = true
        stack.trailingAnchor.constraint(equalTo: stack.superview!.trailingAnchor).isActive = true
        stack.topAnchor.constraint(equalTo: stack.superview!.topAnchor).isActive = true
        stack.bottomAnchor.constraint(equalTo: stack.superview!.bottomAnchor).isActive = true
        
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        captureButton.centerXAnchor.constraint(equalTo: captureButton.superview!.centerXAnchor).isActive = true
        captureButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        captureButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        captureButton.bottomAnchor.constraint(equalTo: captureButton.superview!.bottomAnchor, constant: -10).isActive = true
        
        cameraModel = .init(view: cameraHolder)
        
        self.cameraView?.isHidden = false
        self.cameraButton?.isHidden = true
        self.captureButton?.isHidden = false
        self.photoLibButton?.isHidden = false
        self.photoLibraryView?.isHidden = true
        cameraModel?.stop()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let view = cameraView {
            cameraModel?.updateFrame(.init(origin: .zero, size: view.frame.size))
        }
    }
    
    @objc func cameraPressed(_ sender: UIButton) {
        setPhotoLibraryViewHidden(true)
    }
    
    func setPhotoLibraryViewHidden(_ hidden: Bool, animated:Bool = true) {
        if cameraView?.isHidden != (!hidden) {
            if hidden {
                cameraModel?.resume()
            } else {
                cameraModel?.stop()
            }
            
            UIView.animate(withDuration: animated ? 0.3 : 0) {
                self.cameraView?.isHidden = !hidden
                self.cameraButton?.isHidden = hidden
                self.captureButton?.isHidden = !hidden
                self.photoLibButton?.isHidden = !hidden
                self.photoLibraryView?.isHidden = hidden
            }
        }
        
    }
    
    @objc func photoLibraryPressed(_ sender:UIButton) {
        setPhotoLibraryViewHidden(false)
    }
    
    @objc func capturePressed(_ sender: UIButton) {
        if !(cameraModel?.isCameraAuthorized ?? false) {
            if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        } else {
            cameraModel?.capture(delegate: self)
        }
        
    }
}

extension PhotoLibraryVC:AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: (any Error)?) {
        guard let imgData = photo.fileDataRepresentation(),
              let image = UIImage(data:imgData),
              error == nil
        else {
            return
        }
        didSelectImage?(image)
    }
}

extension PhotoLibraryVC:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        didDismiss?()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return}
        didSelectImage?(image)
    }
}

class CameraModel {

    var session:AVCaptureSession!
    var output:AVCapturePhotoOutput!
    var layer:AVCaptureVideoPreviewLayer?
    
    init(view:UIView) {
        session = .init()
        output = AVCapturePhotoOutput()
        session.sessionPreset = .photo
        let device = AVCaptureDevice.default(for: .video)
        if let device = device,
           let input = try? AVCaptureDeviceInput(device: device),
           session.canAddInput(input)
        {
            session.addInput(input)
            if session.canAddOutput(output) {
                session.addOutput(output)
                layer = AVCaptureVideoPreviewLayer(session: session)
                layer?.videoGravity = .resizeAspectFill
                layer?.frame = view.frame
                view.layer.addSublayer(layer!)
            }
        }
    }

    deinit {
        stop()
        session = nil
        output = nil
        layer = nil
    }
    
    func updateFrame(_ newFrame:CGRect) {
        layer?.frame = newFrame
    }
    
    func capture(delegate:AVCapturePhotoCaptureDelegate) {
        let settings = AVCapturePhotoSettings()
        guard let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first else {
            return
        }
        let previewFormat:[String:Any] = [
            kCVPixelBufferPixelFormatTypeKey as String:previewPixelType,
            kCVPixelBufferWidthKey as String: 160,
            kCVPixelBufferHeightKey as String: 160
        ]
        settings.previewPhotoFormat = previewFormat
        self.output.capturePhoto(with: settings, delegate: delegate)
    }
    
    func stop() {
        if session.isRunning {
            DispatchQueue(label: "camera", qos: .userInitiated).async { [weak self] in
                self?.session.stopRunning()
            }
        }
    }
    
    func resume() {
        if !session.isRunning {
            DispatchQueue(label: "camera", qos: .userInitiated).async { [self] in
                self.session.startRunning()
            }
        }
    }
    
    var isCameraAvalible:Bool {
        if let _ = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .unspecified) {
            return isCameraAuthorized
        }
        return false
    }
    
    var isCameraAuthorized:Bool {
        AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }
}
