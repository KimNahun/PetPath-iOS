//
//  WalkDetailMapViewController.swift
//  PetPath
//
//  Created by 김나훈 on 5/16/25.
//

import Combine
import WebKit
import UIKit

final class WalkDetailMapViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {

    // MARK: - Properties
    private var subscriptions: Set<AnyCancellable> = []
    private let walkId: Int
    private let status: WalkStatus
    private let viewModel: Reportable

    // MARK: - UI Components

    private let spinner = UIActivityIndicatorView(style: .large)

    private lazy var mapView: WKWebView = {
        let config = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        contentController.add(LeakAvoider(delegate: self), name: "WebViewBridge")
        config.userContentController = contentController
        let webView = WKWebView(frame: .zero, configuration: config)
        return webView
    }()

    private let reportView = ReportView().then {
        $0.isHidden = true
    }

    private lazy var reportModalViewController = ReportModalViewController(viewModel: viewModel).then {
        $0.modalPresentationStyle = .overFullScreen
        $0.modalTransitionStyle = .crossDissolve
    }

    init(walkId: Int, status: WalkStatus, viewModel: Reportable) {
        self.walkId = walkId
        self.status = status
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
        setNavigationRightButtons(keys: ["chat", "three"])
        bind()
        mapView.navigationDelegate = self
        if let url = URL(string: "\(UrlManager.baseUrl.urlString)/app/walk/position?walkId=\(walkId)") {
            mapView.load(URLRequest(url: url))
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationTitle("산책 상세", status: status)
    }

    // MARK: - Bind

    private func bind() {
        navigationButtonPublisher(for: "three")
            .sink { [weak self] in
                self?.reportView.isHidden.toggle()
            }.store(in: &subscriptions)

        navigationButtonPublisher(for: "chat")
            .sink { [weak self] in
                guard let self = self else { return }
                navigationController?.pushViewController(ChatWebViewController(id: String(walkId), viewModel: .init()), animated: true)
            }.store(in: &subscriptions)

        viewModel.reportSuccessPublisher.receive(on: DispatchQueue.main).sink { [weak self] _ in
            self?.dismiss(animated: true)
            ToastMessenger.shared.showToast(message: "신고가 완료되었습니다.")
        }.store(in: &subscriptions)

        reportView.tapPublisher.sink { [weak self] in
            guard let self = self else { return }
            reportView.isHidden = true
            let viewController = BottomSheetViewController(contentViewController: reportModalViewController, defaultHeight: 395 + view.safeAreaInsets.bottom, cornerRadius: 20, isPannedable: false)
            present(viewController, animated: true)
        }.store(in: &subscriptions)
    }

    // MARK: - WebView Delegate

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

    // MARK: - WKScriptMessageHandler

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
            print("")
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
}

// MARK: - UI

extension WalkDetailMapViewController {
    private func setupLayOuts() {
        [mapView, reportView].forEach {
            view.addSubview($0)
        }
        mapView.addSubview(spinner)
    }

    private func setupConstraints() {
        spinner.snp.makeConstraints {
            $0.size.equalTo(20)
            $0.centerY.centerX.equalToSuperview()
        }
        mapView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        reportView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.trailing.equalToSuperview().offset(-7)
            $0.width.equalTo(102)
            $0.height.equalTo(36)
        }
    }

    private func setupComponents() {}

    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        setupComponents()
        self.view.backgroundColor = .systemBackground
    }
}
