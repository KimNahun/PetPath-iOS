//
//  CertificationViewController.swift
//  PetPath
//
//  Created by 김나훈 on 3/2/25.
//

import Combine
import UIKit
import WebKit

final class WebViewWithoutInputAccessory: WKWebView {
    override var inputAccessoryView: UIView? {
        return nil
    }
}

/// ✅ KG 이니시스 본인인증 전용 화면 (전체 화면 덮기)
final class CertificationViewController: UIViewController {
    
    // MARK: - Properties
    let resultPublisher = PassthroughSubject<(success: Bool, reason: GetCertResultErrorSpecific?), Never>()
    private let viewModel: CertificationViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    private let webView: WKWebView = {
        let config = WKWebViewConfiguration()
        let webView = WebViewWithoutInputAccessory(frame: .zero, configuration: config)
        return webView
    }()
    
    init(viewModel: CertificationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadCertificationPage()
        bind()
        webView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        webView.configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        webView.navigationDelegate = self
    }
    
    private func bind() {
        viewModel.errorPublisher.receive(on: DispatchQueue.main).sink { [weak self] error in
            if let error = error {
                // 에러가 있다면
                self?.resultPublisher.send((success: false, reason: error))
            } else {
                // 에러가 없다면
                self?.resultPublisher.send((success: true, reason: nil))
            }
        }.store(in: &subscriptions)
    }
    
    // MARK: - KG 이니시스 본인인증 페이지 로드
    private func loadCertificationPage() {
        guard let url = URL(string: "\(UrlManager.baseUrl.urlString)/certification/request") else { return }
        webView.load(URLRequest(url: url))
    }
    
}

// MARK: - WKNavigationDelegate (인증 성공 / 실패 처리)
extension CertificationViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let urlString = webView.url?.absoluteString,
              let urlComponents = URLComponents(string: urlString),
              let queryItems = urlComponents.queryItems else { return }
        
        var queryParams: [String: String] = [:]
        queryItems.forEach { queryParams[$0.name] = $0.value }
        /// ✅ 인증 성공 여부 확인
        if let successValue = queryParams["success"] {
            if successValue == "true", let impUid = queryParams["imp_uid"] {
                KeychainWorker.shared.create(key: .impUid, token: impUid)
                viewModel.getCertResult(impUid: impUid)
            } else if successValue == "false" {
                resultPublisher.send((success: false, reason: nil))
            } else {
                resultPublisher.send((success: false, reason: nil))
            }
        }
    }
    
}
extension CertificationViewController {
    private func setupLayOuts() {
         [webView].forEach {
             view.addSubview($0)
         }
     }
     
     private func setupConstraints() {
         webView.snp.makeConstraints {
             $0.top.bottom.equalTo(view.safeAreaLayoutGuide)
             $0.horizontalEdges.equalToSuperview()
         }
     }
     
     private func setupUI() {
         setupLayOuts()
         setupConstraints()
         self.view.backgroundColor = .systemBackground
     }
}
