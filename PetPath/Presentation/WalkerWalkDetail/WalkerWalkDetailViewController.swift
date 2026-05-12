//
//  WalkerWalkDetailViewController.swift
//  PetPath
//
//  Created by 김나훈 on 3/29/25.
//

import Combine
import WebKit
import UIKit

//TODO: 디코딩 에러나도 뭔가 토스트 메시지 안뜨는듯
//TODO: require 5줄이상이면 '더보기 버튼'
final class WalkerWalkDetailViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
    
    // MARK: - Properties
    private var subscriptions: Set<AnyCancellable> = []
    private let viewModel: WalkerWalkDetailViewModel
    
    private let scrollView = UIScrollView()
    
    private let dogWalkDetailView = DogWalkDetailView()
    
    private let mapGuideLabel = UILabel().then {
        $0.text = "지도"
    }
    
    private let spinner = UIActivityIndicatorView(style: .large)
    
    private lazy var mapView: WKWebView = {
        let config = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        contentController.add(LeakAvoider(delegate: self), name: "WebViewBridge")
        config.userContentController = contentController
        return WKWebView(frame: .zero, configuration: config)
    }()
    
    private let mapClearView = UIView().then {
        $0.isUserInteractionEnabled = true
    }
    
    private let mapLocationImageView = AspectFitImageView().then {
        $0.image = UIImage(named: "marker")
    }
    
    private let mapLocationLabel = UILabel()
    
    private let locationDetailLabel = UILabel()
    
    private let separator2 = UIView()
    
    private let requireGuideLabel = UILabel().then {
        $0.text = "요청사항"
    }
    
    private let requireLabel = UILabel()
    
    private let separator3 = UIView()
    
    private let dogCountLabel = UILabel().then {
        $0.text = "강아지"
    }
    
    private let collectionView: WalkDogInfoCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        let collectionView = WalkDogInfoCollectionView(frame: .zero, collectionViewLayout: flowLayout)
        return collectionView
    }()
    
    private let applyButton = BottomPlacedButton(isSelected: true).then {
        $0.setTitle("산책 지원하기", for: .normal)
        $0.isHidden = true
    }
    
    private let cancelButton = DangerButton().then {
        $0.isHidden = true
    }
    
    private lazy var applyWalkContentViewController = ApplyWalkContentViewController(viewModel: viewModel)
    
    private lazy var walkerCancelWalkModalViewController = WalkerCancelWalkModalViewController(viewModel: viewModel).then {
        $0.modalPresentationStyle = .overFullScreen
        $0.modalTransitionStyle = .crossDissolve
    }
    
    private lazy var walkerPayoutView = WalkerPayoutView(viewModel: viewModel).then {
        $0.isHidden = true
    }
    
    private let reportView = ReportView().then {
        $0.isHidden = true
    }
    
    private lazy var reportModalViewController = ReportModalViewController(viewModel: viewModel).then {
        $0.modalPresentationStyle = .overFullScreen
        $0.modalTransitionStyle = .crossDissolve
    }
    
    private let startWalkQrImageView = AspectFitImageView().then {
        $0.image = UIImage(named: "startWalkQr")
        $0.isHidden = true
    }
    
    private let endWalkQrImageView = AspectFitImageView().then {
        $0.image = UIImage(named: "endWalkQr")
        $0.isHidden = true
    }
    
    private let timeCalculateLabel = PaddingLabel(padding: .init(top: 5, left: 12, bottom: 5, right: 12)).then {
        $0.isHidden = true
    }
    
    private lazy var cancelApplyContentViewController = CancelApplyContentViewController(viewModel: viewModel).then {
        $0.modalPresentationStyle = .overFullScreen
        $0.modalTransitionStyle = .crossDissolve
    }
    
    private let trainFailModalViewController = FailMessageModalViewController(message: "산책 지원 불가", subMessage: WalkApplyNotAvailableCase.walkerTrainNotComplete.message, buttonMessage: WalkApplyNotAvailableCase.walkerTrainNotComplete.buttonText)
    
    private let payMethodFailModalViewController = FailMessageModalViewController(message: "산책 지원 불가", subMessage: WalkApplyNotAvailableCase.payMethodNotFound.message, buttonMessage: WalkApplyNotAvailableCase.payMethodNotFound.buttonText)
    
    private let penaltyFailModalViewController = FailMessageModalViewController(message: "산책 지원 불가", subMessage: WalkApplyNotAvailableCase.penaltyNotPaid.message, buttonMessage: WalkApplyNotAvailableCase.penaltyNotPaid.buttonText)
    
    private let appliedWalkView = AppliedWalkerView().then {
        $0.isHidden = true
    }
    
    // MARK: - Init
    init(viewModel: WalkerWalkDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(mapTapped))
        mapClearView.addGestureRecognizer(tapGesture)
        applyButton.addTarget(self, action: #selector(applyButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        Timer.publish(every: 60, on: .main, in: .common).autoconnect().sink { [weak self] _ in
            self?.viewModel.getWalkDetail()
        }.store(in: &subscriptions)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getWalkDetail()
    }
    
    private func bind() {
        viewModel.$applyFailReason.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] reason in
            guard let self = self, let reason = reason else { return }
            dismiss(animated: true)
            switch reason {
            case .walkerTrainNotComplete: present(trainFailModalViewController, animated: true)
            case .payMethodNotFound: present(payMethodFailModalViewController, animated: true)
            case .penaltyNotPaid: present(penaltyFailModalViewController, animated: true)
            case .unknown: break
            }
        }.store(in: &subscriptions)
        
        trainFailModalViewController.buttonTapPublisher.sink { [weak self] in
            self?.dismiss(animated: true)
            self?.navigationController?.pushViewController(TrainListViewController(viewModel: TrainViewModel()), animated: true)
        }.store(in: &subscriptions)
        
        payMethodFailModalViewController.buttonTapPublisher.sink { [weak self] in
            self?.dismiss(animated: true)
            self?.navigationController?.pushViewController(CardListViewController(viewModel: CardListViewModel()), animated: true)
        }.store(in: &subscriptions)
        
        penaltyFailModalViewController.buttonTapPublisher.sink { [weak self] in
            self?.dismiss(animated: true)
            self?.navigationController?.setViewControllers([WalkerMainPageViewController(viewModel: MainPageViewModel())], animated: false)
        }.store(in: &subscriptions)
        
        viewModel.reportSuccessPublisher.receive(on: DispatchQueue.main).sink { [weak self] in
            self?.dismiss(animated: true)
            ToastMessenger.shared.showToast(message: "신고가 완료되었습니다.")
        }.store(in: &subscriptions)
        
        reportView.tapPublisher.sink { [weak self] in
            guard let self = self else { return }
            reportView.isHidden = true
            let viewController = BottomSheetViewController(contentViewController: reportModalViewController, defaultHeight: 395 + view.safeAreaInsets.bottom, cornerRadius: 20, isPannedable: false)
            present(viewController, animated: true)
        }.store(in: &subscriptions)
        
        walkerPayoutView.showMessageButtonPublisher.sink { [weak self] message in
            let viewController = CancelReasonModalViewController(reason: message)
            self?.present(viewController, animated: true)
        }.store(in: &subscriptions)
        
        viewModel.cancelSuccessPublisher.receive(on: DispatchQueue.main).sink { [weak self] in
            ToastMessenger.shared.showToast(message: "산책이 취소되었습니다.")
            self?.dismiss(animated: true)
            self?.viewModel.getWalkDetail()
        }.store(in: &subscriptions)
        viewModel.$walkDetailResponse.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] response in
            guard let response = response else { return }
            guard let strongSelf = self else { return }
            self?.viewModel.getWalkerWalkApplied(status: response.status)
            self?.startWalkQrImageView.isHidden = response.status != .tobeWalk
            self?.endWalkQrImageView.isHidden = response.status != .walking
            
            if response.status == .tobeWalk || response.status == .walking {
                self?.timeCalculateLabel.isHidden = false
                if response.status == .tobeWalk {
                    let timeDiff = TimeWorker.shared.calculateTimeDiff(from: TimeWorker.shared.getCurrentLocalTime(), to: response.startAt)
                    self?.timeCalculateLabel.text = "산책까지 남은 시간 : \(timeDiff)"
                } else if response.status == .walking {
                    let timeDiff = TimeWorker.shared.calculateTimeDiff(from: TimeWorker.shared.getCurrentLocalTime(), to: response.endAt)
                    self?.timeCalculateLabel.text = "산책 종료까지 남은 시간 : \(timeDiff)"
                }
            } else {
                self?.timeCalculateLabel.isHidden = true
            }
            
            self?.dogWalkDetailView.configure(title: response.title, location: response.pickupAddress, startAt: response.startAt, endAt: response.endAt, price: response.price, status: response.status)
            
            self?.mapLocationLabel.text = response.pickupAddress
            self?.locationDetailLabel.text = response.pickupDetail
            self?.requireLabel.text = response.request.isEmpty ? "-" : response.request
            self?.collectionView.setDogList(item: response.dogs)
            
            if let url = URL(string: "\(UrlManager.baseUrl.urlString)/app/walk/position?walkId=\(response.pk)"),
               strongSelf.mapView.url != url {
                self?.mapView.load(URLRequest(url: url))
            }
            strongSelf.collectionView.snp.updateConstraints {
                $0.height.equalTo(strongSelf.collectionView.calculateDynamicHeight())
            }
            self?.setupNavigationBar(walkStatus: response.status)
            
            
            strongSelf.walkerPayoutView.isHidden = response.status == .findWalker
            
            if response.status == .findWalker {
                strongSelf.dogCountLabel.snp.remakeConstraints {
                    $0.top.equalTo(strongSelf.separator3.snp.bottom).offset(8)
                    $0.leading.equalTo(strongSelf.mapGuideLabel)
                }
            } else {
                strongSelf.collectionView.snp.remakeConstraints {
                    $0.top.equalTo(strongSelf.dogCountLabel.snp.bottom).offset(16)
                    $0.horizontalEdges.equalTo(strongSelf.mapGuideLabel)
                    $0.height.equalTo(strongSelf.collectionView.calculateDynamicHeight())
                }
                strongSelf.walkerPayoutView.snp.remakeConstraints {
                    $0.top.equalTo(strongSelf.collectionView.snp.bottom).offset(8)
                    $0.horizontalEdges.equalToSuperview()
                    $0.bottom.equalTo(strongSelf.scrollView).offset(-50)
                }
            }
            UIView.animate(withDuration: 0.3) {
                self?.view.layoutIfNeeded()
            }
        }.store(in: &subscriptions)
        
        viewModel.$walkerAppliedResponse.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] response in
            guard let self = self else { return }
            if let response = response,
               viewModel.walkDetailResponse?.status != .tobeWalk, viewModel.walkDetailResponse?.status != .walking {
                appliedWalkView.configure(price: response.price, description: response.description)
                appliedWalkView.isHidden = false
                requireGuideLabel.snp.remakeConstraints {
                    $0.top.equalTo(self.appliedWalkView.snp.bottom).offset(16)
                    $0.leading.equalTo(self.mapGuideLabel)
                }
            } else {
                appliedWalkView.isHidden = true
                requireGuideLabel.snp.makeConstraints {
                    $0.top.equalTo(self.separator2.snp.bottom).offset(16)
                    $0.leading.equalTo(self.mapGuideLabel)
                }
            }
        }.store(in: &subscriptions)
        
        viewModel.popPublisher.receive(on: DispatchQueue.main).sink { [weak self] in
            self?.viewModel.getWalkDetail()
        }.store(in: &subscriptions)
        
        viewModel.appliedPublisher.receive(on: DispatchQueue.main).sink { [weak self] response in
            guard let self else { return }
            if response.status == .findWalker {
                cancelButton.setTitle("지원 취소", for: .normal)
                cancelButton.isHidden = !response.applied
                applyButton.isHidden = response.applied
            } else if response.status == .tobeWalk {
                cancelButton.setTitle("산책 취소", for: .normal)
                applyButton.isHidden = true
                if response.applied {
                    cancelButton.isHidden = false
                }
            } else {
                cancelButton.isHidden = true
                applyButton.isHidden = true
            }
        }.store(in: &subscriptions)
    }
}
extension WalkerWalkDetailViewController {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "WebViewBridge",
              let jsonString = message.body as? String else { return }
        handleDispatch(jsonString: jsonString)
    }
    
    private func handleDispatch(jsonString: String) {
        do {
            guard let data = jsonString.data(using: .utf8),
                  let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let method = json["method"] as? String,
                  let args = json["args"] as? [Any],
                  let callbackId = json["callbackId"] as? String else { return }
            
            handleBridgeMethod(method: method, args: args) { result in
                let safeResult = result.replacingOccurrences(of: "'", with: "\\'")
                let js = "onNativeCallback('\(callbackId)', '\(safeResult)')"
                DispatchQueue.main.async {
                    self.mapView.evaluateJavaScript(js, completionHandler: nil)
                }
            }
        } catch {
            print("⚠️ JS Bridge Error: \(error)")
        }
    }
    
    private func handleBridgeMethod(method: String, args: [Any], completion: @escaping (String) -> Void) {
        switch method {
        case "getUserToken":
            completion(KeychainWorker.shared.read(key: .access) ?? "")
        default:
            completion("unknown method")
        }
    }
    @objc private func mapTapped() {
        guard let walkDetail = viewModel.walkDetailResponse else { return }
        navigationController?.pushViewController(WalkDetailMapViewController(walkId: walkDetail.pk, status: walkDetail.status, viewModel: viewModel), animated: true)
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        spinner.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        spinner.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        spinner.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        spinner.stopAnimating()
    }
    @objc private func applyButtonTapped() {
        requestPermissionsIfNeeded([.notification]) { [weak self] isPermit in
            guard let self = self else { return }
            if isPermit {
                let viewController = BottomSheetViewController(contentViewController: applyWalkContentViewController, defaultHeight: 482 + view.safeAreaInsets.bottom, cornerRadius: 20, isPannedable: false)
                viewController.modalPresentationStyle = .overFullScreen
                viewController.modalTransitionStyle = .crossDissolve
                present(viewController, animated: true)
            } else {
                present(PermissionBlockModalViewController(message: "산책 관련 알림을 받기 위해서는 권한이 필요합니다.\n설정으로 이동해서 알림 권한을 활성화 해주세요"), animated: true)
            }
        }
    }
    @objc private func cancelButtonTapped() {
        
        if viewModel.walkDetailResponse?.status == .findWalker {
            let viewController = BottomSheetViewController(contentViewController: cancelApplyContentViewController, defaultHeight: 145 + 16 +  additionalSafeAreaInsets.bottom, cornerRadius: 20, isPannedable: false)
            viewController.modalPresentationStyle = .overFullScreen
            viewController.modalTransitionStyle = .crossDissolve
            present(viewController, animated: true)
        } else if viewModel.walkDetailResponse?.status == .tobeWalk {
            viewModel.calcCancelWalkPenalty()
            present(walkerCancelWalkModalViewController, animated: true)
        }
    }
    private func setupNavigationBar(walkStatus: WalkStatus) {
        if self.navigationController?.topViewController === self {
            setNavigationTitle("산책 상세", status: walkStatus)
        }
        switch walkStatus {
        case .findWalker:
            setNavigationRightButtons(keys: ["three"])
        case .tobeWalk, .walking:
            setNavigationRightButtons(keys: ["qr", "chat", "three"])
        case .endWalking:
            setNavigationRightButtons(keys: ["chat", "three"])
        case .ownerCancel, .ownerNoShow, .walkerCancel, .walkerNoShow:
            setNavigationRightButtons(keys: ["chat", "three"])
        case .unknown, .walkerNotMatch:
            break
        }
        navigationButtonPublisher(for: "three")
            .sink { [weak self] in
                self?.reportView.isHidden.toggle()
            }.store(in: &subscriptions)
        
        navigationButtonPublisher(for: "chat")
            .sink { [weak self] in
                guard let self = self, let item = viewModel.walkDetailResponse else { return }
                navigationController?.pushViewController(ChatWebViewController(id: String(item.pk), viewModel: .init()), animated: true)
            }.store(in: &subscriptions)
        navigationButtonPublisher(for: "qr")
            .sink { [weak self] in
                guard let self = self else { return }
                requestPermissionsIfNeeded([.camera, .location]) { [weak self] isPermit in
                    guard let self = self else { return }
                    if isPermit {
                        navigationController?.pushViewController(QrCameraViewController(viewModel: viewModel), animated: true)
                    } else {
                        present(PermissionBlockModalViewController(message: "산책 시작 QR코드를 촬영하기 위해 카메라, 위치 권한이 필요합니다.\n설정으로 이동해서 카메라, 위치 권한을 활성화 해주세요."), animated: true)
                    }
                }
            }.store(in: &subscriptions)
    }
}
extension WalkerWalkDetailViewController {
    
    private func setupLayouts() {
        [scrollView, applyButton, cancelButton, timeCalculateLabel, startWalkQrImageView, endWalkQrImageView, reportView].forEach {
            view.addSubview($0)
        }
        
        [dogWalkDetailView, mapGuideLabel, mapView, mapClearView, mapLocationImageView, mapLocationLabel, locationDetailLabel, separator2, requireGuideLabel, requireLabel, walkerPayoutView, separator3, dogCountLabel, collectionView, appliedWalkView].forEach {
            scrollView.addSubview($0)
        }
        mapView.addSubview(spinner)
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        reportView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.trailing.equalToSuperview().offset(-7)
            $0.width.equalTo(102)
            $0.height.equalTo(36)
        }
        dogWalkDetailView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.width.equalTo(view.snp.width)
            $0.height.equalTo(165)
        }
        mapGuideLabel.snp.makeConstraints {
            $0.top.equalTo(dogWalkDetailView.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        mapView.snp.makeConstraints {
            $0.top.equalTo(mapGuideLabel.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(140)
        }
        mapClearView.snp.makeConstraints {
            $0.edges.equalTo(mapView)
        }
        mapLocationImageView.snp.makeConstraints {
            $0.top.equalTo(mapView.snp.bottom).offset(8)
            $0.leading.equalTo(mapGuideLabel)
            $0.size.equalTo(16)
        }
        mapLocationLabel.snp.makeConstraints {
            $0.leading.equalTo(mapLocationImageView.snp.trailing).offset(8)
            $0.centerY.equalTo(mapLocationImageView)
            $0.height.equalTo(mapLocationImageView)
        }
        locationDetailLabel.snp.makeConstraints {
            $0.top.equalTo(mapLocationLabel.snp.bottom).offset(8)
            $0.leading.equalTo(mapGuideLabel)
        }
        separator2.snp.makeConstraints {
            $0.top.equalTo(locationDetailLabel.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(8)
        }
        appliedWalkView.snp.makeConstraints {
            $0.top.equalTo(separator2.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview()
        }
        requireGuideLabel.snp.makeConstraints {
            $0.top.equalTo(separator2.snp.bottom).offset(16)
            $0.leading.equalTo(mapGuideLabel)
        }
        requireLabel.snp.makeConstraints {
            $0.top.equalTo(requireGuideLabel.snp.bottom).offset(8)
            $0.horizontalEdges.equalTo(mapGuideLabel)
        }
        separator3.snp.makeConstraints {
            $0.top.equalTo(requireLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(8)
        }
        walkerPayoutView.snp.makeConstraints {
            $0.top.equalTo(separator3.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview()
        }
        dogCountLabel.snp.makeConstraints {
            $0.top.equalTo(separator3.snp.bottom).offset(8)
            $0.leading.equalTo(mapGuideLabel)
        }
        collectionView.snp.makeConstraints {
            $0.top.equalTo(dogCountLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalTo(mapGuideLabel)
            $0.height.equalTo(1)
            $0.bottom.equalTo(scrollView).offset(-50)
        }
        applyButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(41)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-8)
        }
        cancelButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(41)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-8)
        }
        spinner.snp.makeConstraints {
            $0.size.equalTo(20)
            $0.centerY.centerX.equalToSuperview()
        }
        startWalkQrImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.trailing.equalToSuperview().offset(-61)
            $0.width.equalTo(227)
            $0.height.equalTo(59)
        }
        endWalkQrImageView.snp.makeConstraints {
            $0.edges.equalTo(startWalkQrImageView)
        }
        timeCalculateLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(cancelButton.snp.top).offset(-10)
        }
    }
    
    private func setupComponents() {
        [mapGuideLabel, requireGuideLabel, dogCountLabel].forEach {
            $0.textColor = .dark
            $0.font = FontSet.pretendardBold(size: 18)
        }
        [mapLocationLabel, locationDetailLabel, requireLabel].forEach {
            $0.textColor = .dark
            $0.font = FontSet.pretendardMedium(size: 14)
        }
        requireLabel.numberOfLines = 0
        
        [separator2, separator3].forEach {
            $0.backgroundColor = .neutral3
        }
        timeCalculateLabel.textColor = .neutral3
        timeCalculateLabel.font = FontSet.pretendardBold(size: 14)
        timeCalculateLabel.backgroundColor = ColorSet.fromHex("5E5E5E").withAlphaComponent(0.8)
        timeCalculateLabel.layer.masksToBounds = true
        timeCalculateLabel.layer.cornerRadius = 10
    }
    
    private func setupUI() {
        setupLayouts()
        setupConstraints()
        setupComponents()
        view.backgroundColor = .systemBackground
    }
    
}
