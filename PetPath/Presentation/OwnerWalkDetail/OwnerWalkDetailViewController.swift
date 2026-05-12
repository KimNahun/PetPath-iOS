//
//  OwnerWalkDetailViewController.swift
//  PetPath
//
//  Created by 김나훈 on 3/31/25.
//

import Combine
import NMapsMap
import WebKit
import UIKit

final class OwnerWalkDetailViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
    
    // MARK: - Properties
    private let viewModel: OwnerWalkDetailViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    private let spinner = UIActivityIndicatorView(style: .large)
    
    private let scrollView = UIScrollView()
    
    private let reportView = ReportView().then {
        $0.isHidden = true
    }
    
    private lazy var reportModalViewController = ReportModalViewController(viewModel: viewModel).then {
        $0.modalPresentationStyle = .overFullScreen
        $0.modalTransitionStyle = .crossDissolve
    }
    
    private let dogWalkDetailView = DogWalkDetailView()
    
    private let mapGuideLabel = UILabel().then {
        $0.text = "지도"
    }
    
    private let mapClearView = UIView().then {
        $0.isUserInteractionEnabled = true
    }
    private lazy var mapView: WKWebView = {
        let config = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        contentController.add(LeakAvoider(delegate: self), name: "WebViewBridge")
        config.userContentController = contentController
        return WKWebView(frame: .zero, configuration: config)
    }()
    
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
    
    private lazy var appliedWalkerCollectionView: AppliedWalkerCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 9
        layout.minimumInteritemSpacing = 0
        let collectionView = AppliedWalkerCollectionView(
            frame: .zero,
            collectionViewLayout: layout,
            viewModel: viewModel
        )
        collectionView.isHidden = true
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private lazy var matchedWalkerView = MatchedWalkerView(viewModel: viewModel).then {
        $0.isHidden = true
    }
    
    private lazy var ownerPaymentView = OwnerPaymentView(viewModel: viewModel).then {
        $0.isHidden = true
    }
    
    private lazy var ownerRefundView = OwnerRefundView(viewModel: viewModel).then {
        $0.isHidden = true
    }
    
    private lazy var cancelWalkContentViewController = CancelWalkContentViewController(viewModel: viewModel)
    
    private lazy var cancelMatchedWalkContentViewContrller = CancelMatchedWalkContentViewController(viewModel: viewModel)
    
    private lazy var selectWalkContentViewController = SelectedWalkerContentViewController(viewModel: viewModel)
    
    private lazy var matchWalkerContentViewController = MatchWalkerContentViewController(viewModel: viewModel)
    
    private let cancelButton = DangerButton().then {
        $0.setTitle("산책 취소하기", for: .normal)
        $0.isHidden = true
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
    
    init(viewModel: OwnerWalkDetailViewModel) {
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
        setupUI()
        bind()
        mapView.navigationDelegate = self
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(mapTapped))
        mapClearView.addGestureRecognizer(tapGesture)
        Timer.publish(every: 60, on: .main, in: .common).autoconnect().sink { [weak self] _ in
            self?.viewModel.getWalkDetail()
        }.store(in: &subscriptions)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getWalkDetail()
        setNavigationTitle("산책 상세")
    }
    
    // MARK: - Bind
    
    private func bind() {
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
        
        ownerRefundView.showMessageButtonPublisher.sink { [weak self] message in
            let viewController = CancelReasonModalViewController(reason: message)
            self?.present(viewController, animated: true)
        }.store(in: &subscriptions)
        
        viewModel.matchSuccessPublisher.receive(on: DispatchQueue.main).sink { [weak self] in
            ToastMessenger.shared.showToast(message: "매칭에 성공했습니다.")
            self?.dismiss(animated: true)
            self?.viewModel.getWalkDetail()
        }.store(in: &subscriptions)
        
        viewModel.cancelSuccessPublisher.receive(on: DispatchQueue.main).sink { [weak self] in
            ToastMessenger.shared.showToast(message: "산책이 취소되었습니다.")
            self?.dismiss(animated: true)
            self?.viewModel.getWalkDetail()
        }.store(in: &subscriptions)
        
        viewModel.$walkDetailResponse.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] response in
            guard let response = response else { return }
            guard let strongSelf = self else { return }
            self?.dogWalkDetailView.configure(title: response.title, location: response.pickupAddress, startAt: response.startAt, endAt: response.endAt, price: response.price, status: response.status)
            
            self?.mapLocationLabel.text = response.pickupAddress
            self?.locationDetailLabel.text = response.pickupDetail
            self?.requireLabel.text = response.request.isEmpty ? "-" : response.request
            self?.collectionView.setDogList(item: response.dogs)
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
            
            if let url = URL(string: "\(UrlManager.baseUrl.urlString)/app/walk/position?walkId=\(response.pk)"),
               strongSelf.mapView.url != url {
                self?.mapView.load(URLRequest(url: url))
            }
            strongSelf.collectionView.snp.updateConstraints {
                $0.height.equalTo(strongSelf.collectionView.calculateDynamicHeight())
            }
            self?.setupStatus(status: response.status)
            self?.setupNavigationBar(walkStatus: response.status)
        }.store(in: &subscriptions)
        
        appliedWalkerCollectionView.reloadPublisher.sink { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.appliedWalkerCollectionView.snp.updateConstraints {
                $0.height.equalTo(strongSelf.appliedWalkerCollectionView.calculateDynamicHeight())
            }
            UIView.animate(withDuration: 0.3) {
                strongSelf.view.layoutIfNeeded()
            }
        }.store(in: &subscriptions)
        
        viewModel.$showingWalker.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] walker in
            guard let walker = walker else { return }
            guard let strongSelf = self else { return }
            self?.selectWalkContentViewController.configure(item: walker)
            let viewController = BottomSheetViewController(contentViewController: strongSelf.selectWalkContentViewController, defaultHeight: 329 + 16 +  strongSelf.additionalSafeAreaInsets.bottom, cornerRadius: 20, isPannedable: false)
            viewController.modalPresentationStyle = .overFullScreen
            viewController.modalTransitionStyle = .crossDissolve
            self?.present(viewController, animated: true)
        }.store(in: &subscriptions)
        
        selectWalkContentViewController.selectPublisher.sink { [weak self] in
            guard let strongSelf = self else { return }
            self?.dismiss(animated: true)
            strongSelf.matchWalkerContentViewController = MatchWalkerContentViewController(viewModel: strongSelf.viewModel)
            let viewController = BottomSheetViewController(contentViewController: strongSelf.matchWalkerContentViewController, defaultHeight: 420 + 16 +  strongSelf.additionalSafeAreaInsets.bottom, cornerRadius: 20, isPannedable: false)
            viewController.modalPresentationStyle = .overFullScreen
            viewController.modalTransitionStyle = .crossDissolve
            self?.present(viewController, animated: true)
        }.store(in: &subscriptions)
    }
}

extension OwnerWalkDetailViewController {
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
    
    @objc private func cancelButtonTapped() {
        if viewModel.walkDetailResponse?.status == .findWalker {
            let viewController = BottomSheetViewController(contentViewController: cancelWalkContentViewController, defaultHeight: 145 + 16 +  additionalSafeAreaInsets.bottom, cornerRadius: 20, isPannedable: false)
            viewController.modalPresentationStyle = .overFullScreen
            viewController.modalTransitionStyle = .crossDissolve
            present(viewController, animated: true)
        } else if viewModel.walkDetailResponse?.status == .tobeWalk {
            let viewController = BottomSheetViewController(contentViewController: cancelMatchedWalkContentViewContrller, defaultHeight: 370 + 16 +  additionalSafeAreaInsets.bottom, cornerRadius: 20, isPannedable: false)
            viewController.modalPresentationStyle = .overFullScreen
            viewController.modalTransitionStyle = .crossDissolve
            present(viewController, animated: true)
        }
    }
    
    private func setupStatus(status: WalkStatus) {
        
        [appliedWalkerCollectionView, matchedWalkerView, ownerPaymentView, ownerRefundView, cancelButton].forEach {
            $0.isHidden = true
        }
        mapGuideLabel.snp.remakeConstraints {
            $0.top.equalTo(dogWalkDetailView.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        cancelButton.isHidden = !(status == .findWalker || status == .tobeWalk)
        switch status {
        case .findWalker:
            appliedWalkerCollectionView.isHidden = false
            cancelButton.isHidden = false
            appliedWalkerCollectionView.snp.remakeConstraints {
                $0.top.equalTo(dogWalkDetailView.snp.bottom)
                $0.horizontalEdges.equalToSuperview()
                $0.height.equalTo(1)
            }
            mapGuideLabel.snp.remakeConstraints {
                $0.top.equalTo(appliedWalkerCollectionView.snp.bottom).offset(8)
                $0.horizontalEdges.equalToSuperview().inset(16)
            }
            viewModel.getApplyWalkerList()
        case .tobeWalk, .walking, .endWalking:
            if status == .tobeWalk {
                viewModel.calcCancelWalkPenalty()
            }
            ownerPaymentView.isHidden = false
            matchedWalkerView.isHidden = false
            collectionView.snp.remakeConstraints {
                $0.top.equalTo(dogCountLabel.snp.bottom).offset(16)
                $0.horizontalEdges.equalTo(mapGuideLabel)
                $0.height.equalTo(collectionView.calculateDynamicHeight())
            }
            ownerPaymentView.snp.remakeConstraints {
                $0.top.equalTo(collectionView.snp.bottom).offset(8)
                $0.horizontalEdges.equalToSuperview()
                $0.bottom.equalTo(scrollView).offset(-50)
            }
            matchedWalkerView.snp.remakeConstraints {
                $0.top.equalTo(separator2.snp.bottom).offset(8)
                $0.horizontalEdges.equalToSuperview()
            }
            requireGuideLabel.snp.remakeConstraints {
                $0.top.equalTo(matchedWalkerView.snp.bottom).offset(16)
                $0.leading.equalTo(mapGuideLabel)
            }
            viewModel.getWalkPaymentInfo()
            viewModel.getMatchedWalkerInfo()
        case .ownerCancel, .ownerNoShow, .walkerCancel, .walkerNoShow:
            if status == .ownerCancel && viewModel.walkDetailResponse?.walker == nil { return }
            ownerRefundView.isHidden = false
            matchedWalkerView.isHidden = false
            collectionView.snp.remakeConstraints {
                $0.top.equalTo(dogCountLabel.snp.bottom).offset(16)
                $0.horizontalEdges.equalTo(mapGuideLabel)
                $0.height.equalTo(collectionView.calculateDynamicHeight())
            }
            ownerRefundView.snp.remakeConstraints {
                $0.top.equalTo(collectionView.snp.bottom).offset(8)
                $0.horizontalEdges.equalToSuperview()
                $0.bottom.equalTo(scrollView).offset(-50)
            }
            matchedWalkerView.snp.remakeConstraints {
                $0.top.equalTo(separator2.snp.bottom).offset(8)
                $0.horizontalEdges.equalToSuperview()
            }
            requireGuideLabel.snp.remakeConstraints {
                $0.top.equalTo(matchedWalkerView.snp.bottom).offset(16)
                $0.leading.equalTo(mapGuideLabel)
            }
            viewModel.getWalkPaymentInfo()
            viewModel.getMatchedWalkerInfo()
        case .walkerNotMatch: return
        case .unknown: return
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    private func setupNavigationBar(walkStatus: WalkStatus) {
        if self.navigationController?.topViewController === self {
            setNavigationTitle("산책 상세", status: walkStatus)
        }
        switch walkStatus {
        case .findWalker, .ownerCancel, .ownerNoShow, .walkerCancel, .walkerNoShow, .walkerNotMatch:
            setNavigationRightButtons(keys: ["three"])
        case .tobeWalk, .walking:
            setNavigationRightButtons(keys: ["qr", "chat", "three"])
        case .endWalking:
            setNavigationRightButtons(keys: ["chat", "three"])
        case .unknown:
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
                navigationController?.pushViewController(QrCodeViewController(viewModel: viewModel), animated: true)
            }.store(in: &subscriptions)
    }
}

extension OwnerWalkDetailViewController {
    
    private func setupLayOuts() {
        [scrollView, cancelButton, timeCalculateLabel, startWalkQrImageView, endWalkQrImageView, reportView].forEach {
            view.addSubview($0)
        }
        [dogWalkDetailView, appliedWalkerCollectionView, mapGuideLabel, mapView, mapClearView, mapLocationImageView, mapLocationLabel, locationDetailLabel, separator2, requireGuideLabel, requireLabel, separator3, dogCountLabel, collectionView].forEach {
            scrollView.addSubview($0)
        }
        [appliedWalkerCollectionView, matchedWalkerView, ownerPaymentView, ownerRefundView].forEach {
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
        cancelButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(41)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-8)
        }
        
        matchedWalkerView.snp.makeConstraints {
            $0.top.equalTo(dogWalkDetailView.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(400)
        }
        ownerPaymentView.snp.makeConstraints {
            $0.top.equalTo(matchedWalkerView.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
        }
        ownerRefundView.snp.makeConstraints {
            $0.top.equalTo(ownerPaymentView.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(400)
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
        setupLayOuts()
        setupConstraints()
        setupComponents()
        self.view.backgroundColor = .systemBackground
    }
}
