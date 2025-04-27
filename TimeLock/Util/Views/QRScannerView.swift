//
//  QRScannerView.swift
//  TimeLock
//
//  Created by Misha Vakhrushin on 24.04.2025.
//

import UIKit
import AVFoundation

class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var closeButton = UIButton()
    var onQRCodeScanned: ((String, Data) -> Void)?
    var onShowError: ((String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        checkCameraPermission()
        setupUI()
    }

    private func checkCameraPermission() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch authStatus {
        case .authorized:
            setupCaptureSession()
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { response in
                DispatchQueue.main.async {
                    if response {
                        self.setupCaptureSession()
                    } else {
                        self.showCameraError()
                    }
                }
            }
            
        case .denied, .restricted:
            showCameraError()
        @unknown default:
            showCameraError()
        }
    }

    private func setupCaptureSession() {
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              captureSession.canAddInput(videoInput) else {
            showCameraError()
            return
        }

        captureSession.addInput(videoInput)

        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            showCameraError()
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(previewLayer, at: 0)

        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }

    private func setupUI() {
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .white
        closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        closeButton.layer.cornerRadius = 25
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 50),
            closeButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        let frameView = UIView()
        frameView.layer.borderColor = UIColor(named: "AccentColor")?.cgColor
        frameView.layer.borderWidth = 2
        frameView.layer.cornerRadius = 12
        frameView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(frameView)

        NSLayoutConstraint.activate([
            frameView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            frameView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            frameView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            frameView.heightAnchor.constraint(equalTo: frameView.widthAnchor)
        ])
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    private func showCameraError() {
        let alert = UIAlertController(
            title: "Camera access denied",
            message: "Please enable camera access in Settings",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.dismiss(animated: true)
        })
        present(alert, animated: true)
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            if let metadataObject = metadataObjects.first,
               let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
               let stringValue = readableObject.stringValue {
                
                Logger.shared.log("Scanned QR Code: \(stringValue)")
                handleScannedQRCode(stringValue)
                dismiss(animated: true)
            }
        }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }
    
    private func handleScannedQRCode(_ code: String) {
        if let url = URL(string: code),
           let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {

            var secret: String?
            var name: String?

            for item in queryItems {
                if item.name == "secret" {
                    secret = item.value
                }
                if item.name == "issuer" {
                    name = item.value
                }
            }

            if let secret = secret, let name = name {
                Logger.shared.log("Scanned QR Code - Name: \(name), Secret: \(secret)")

                if let secretData = Data(base32Encoded: secret) {
                    if TOTPGenerator.shared.contains(secret: secretData) {
                        dismiss(animated: true) {
                            self.onShowError?("Такой ключ уже добавлен.")
                        }
                        return
                    }
                    
                    dismiss(animated: true) {
                        self.onQRCodeScanned?(name, secretData)
                    }
                } else {
                    self.onShowError?("Не удалось распознать формат секрета.")
                }
            } else {
                self.onShowError?("Не удалось извлечь данные из QR-кода.")
            }
        } else {
            self.onShowError?("Некорректный формат QR-кода.")
        }
    }
}
