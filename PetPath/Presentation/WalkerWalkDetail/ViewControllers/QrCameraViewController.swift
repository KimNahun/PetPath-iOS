//
//  QrCameraViewController.swift
//  PetPath
//
//  Created by 김나훈 on 5/2/25.
//

import AVFoundation
import Combine
import UIKit
import SnapKit

final class QrCameraViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    // MARK: - Properties
    private var isQRCodeHandled = false
    private let viewModel: WalkerWalkDetailViewModel
    private var subscriptions: Set<AnyCancellable> = []
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?

    // MARK: - UI
    private let cameraPreviewView = UIView()

    private let messageLabel = UILabel().then {
        $0.text = "견주님 앱에 표시된 QR을 촬영해주세요"
        $0.font = FontSet.pretendardBold(size: 16)
        $0.textColor = .dark
    }
    
    private let subMessageLabel = UILabel().then {
        $0.text = "QR코드가 인식되어 카메라 화면이 꺼지면\n산책을 진행해주세요"
        $0.font = FontSet.pretendardMedium(size: 12)
        $0.textColor = .dark
        $0.textAlignment = .center
        $0.numberOfLines = 2
    }

    // MARK: - Init
    init(viewModel: WalkerWalkDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        checkCameraPermission()
        setupUI()
        bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationTitle(viewModel.walkDetailResponse?.title ?? "", status: viewModel.walkDetailResponse?.status ?? .unknown)
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession?.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession?.stopRunning()
        }
    }

    // MARK: - Permissions
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    granted ? self.setupCamera() : self.showPermissionDeniedAlert()
                }
            }
        default:
            showPermissionDeniedAlert()
        }
    }

    private func showPermissionDeniedAlert() {
        let alert = UIAlertController(
            title: "카메라 접근 불가",
            message: "QR 코드를 인식하려면 카메라 권한이 필요합니다.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "설정으로 이동", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }


    // MARK: - Bind
    private func bind() {
        viewModel.startOfEndSuccessPublisher.receive(on: DispatchQueue.main).sink { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }.store(in: &subscriptions)
    }
}

extension QrCameraViewController {
    private func handleScannedQRCode(_ code: String) {
        
            guard let data = code.data(using: .utf8),
                  let qrInfo = try? JSONDecoder().decode(StartOrEndWalkRequest.self, from: data) else {
                print("❌ JSON 디코딩 실패")
                return
            }

        print("✅ key: \(qrInfo.key)")
        print("✅ type: \(qrInfo.type)")
        print("✅ walkId: \(qrInfo.walkId)")
       
//        SocketService.shared.emit(
//            event: "ListenWalkMessage",
//            with: ["walk": qrInfo.walkId]
//        )
        if viewModel.walkDetailResponse?.status == .tobeWalk {
            viewModel.startWalk(request: qrInfo)
        } else if viewModel.walkDetailResponse?.status == .walking {
            viewModel.endWalk(request: qrInfo)
        }
    }
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard !isQRCodeHandled,
              let metadata = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              metadata.type == .qr,
              let stringValue = metadata.stringValue else { return }

        isQRCodeHandled = true

        DispatchQueue.main.async {
            self.captureSession?.stopRunning()
            self.handleScannedQRCode(stringValue)
        }
    }
    private func setupCamera() {
        DispatchQueue.global(qos: .userInitiated).async {
            let session = AVCaptureSession()

            guard let device = AVCaptureDevice.default(for: .video),
                  let input = try? AVCaptureDeviceInput(device: device),
                  session.canAddInput(input) else { return }

            session.addInput(input)

            let output = AVCaptureMetadataOutput()
            if session.canAddOutput(output) {
                session.addOutput(output)
                output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                output.metadataObjectTypes = [.qr]
            }

            self.captureSession = session
            session.startRunning()

            DispatchQueue.main.async {
                let previewLayer = AVCaptureVideoPreviewLayer(session: session)
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.frame = self.cameraPreviewView.bounds
                self.cameraPreviewView.layer.addSublayer(previewLayer)
                self.previewLayer = previewLayer
            }
        }
    }
}

extension QrCameraViewController {
    private func setupLayOuts() {
        [cameraPreviewView, messageLabel, subMessageLabel].forEach {
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        cameraPreviewView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(40)
            $0.horizontalEdges.equalToSuperview().inset(22)
            $0.bottom.equalTo(messageLabel.snp.top).offset(-36)
        }
        messageLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(subMessageLabel.snp.top).offset(-15)
        }
        subMessageLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-77)
        }
    }
    
    private func setupComponents() {
      
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        setupComponents()
        self.view.backgroundColor = .systemBackground
    }
}
