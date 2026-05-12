//
//  ChatWebViewController.swift
//  PetPath
//
//  Created by 김나훈 on 4/24/25.
//

import WebKit
import Combine
import SnapKit
import AVFoundation
// !!!: 이런 delegate를 사용해서 순환참조를 피할수있다!
final class LeakAvoider: NSObject, WKScriptMessageHandler {
    weak var delegate: WKScriptMessageHandler?
    
    init(delegate: WKScriptMessageHandler) {
        self.delegate = delegate
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        delegate?.userContentController(userContentController, didReceive: message)
    }
}

final class ChatWebViewController: UIViewController, WKScriptMessageHandler, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        contentController.add(LeakAvoider(delegate: self), name: "WebViewBridge")
        config.userContentController = contentController
        return WKWebView(frame: .zero, configuration: config)
    }()
    
    private let reportView = ReportView().then {
        $0.isHidden = true
    }
    
    private lazy var reportModalViewController = ReportModalViewController(viewModel: viewModel).then {
        $0.modalPresentationStyle = .overFullScreen
        $0.modalTransitionStyle = .crossDissolve
    }
    
    let id: String
    private var chatPhotoCompletion: ((String) -> Void)?
    private var subscriptions: Set<AnyCancellable> = []
    private let fileUploadUseCase = FileUploadUseCaseImpl(repository: UtilRepositoryImpl())
    private let viewModel: ChatViewModel
    private let spinner = UIActivityIndicatorView(style: .large)
    private var isCameraPresented = false
    
    // MARK: - Init
    init(id: String, viewModel: ChatViewModel) {
        self.id = id
        self.viewModel = viewModel
        self.viewModel.id = Int(id) ?? 0
        super.init(nibName: nil, bundle: nil)
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setNavigationRightButtons(keys: ["three"])
        bind()
        hideKeyboardWhenTappedAround()

        guard let url = URL(string: "\(UrlManager.baseUrl.urlString)/app/chat/chat?chatId=\(id)") else { return }
        webView.load(URLRequest(url: url))

        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    @objc private func didEnterBackground() {
        webView.evaluateJavaScript("window.disconnectSocket && window.disconnectSocket();", completionHandler: nil)
    }

    @objc private func willEnterForeground() {
        guard let url = URL(string: "\(UrlManager.baseUrl.urlString)/app/chat/chat?chatId=\(id)") else { return }
        webView.load(URLRequest(url: url))
        webView.evaluateJavaScript("window.reconnectSocket && window.reconnectSocket();", completionHandler: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isCameraPresented = false // reset after camera dismiss
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if !isCameraPresented {
            print("📡 disconnecting socket")
            webView.evaluateJavaScript("window.disconnectSocket && window.disconnectSocket();", completionHandler: nil)
        } else {
            print("📸 camera presented - skip disconnect")
        }
    }
    
    private func bind() {
        navigationButtonPublisher(for: "three")
            .sink { [weak self] in
                self?.reportView.isHidden.toggle()
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
        
        viewModel.$walkDetail.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] response in
            guard let self = self, let response = response else { return }
            setNavigationTitle(response.title, status: response.status)
        }.store(in: &subscriptions)
    }
    
    // MARK: - JS → Native
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "WebViewBridge",
              let jsonString = message.body as? String else { return }
        handleDispatch(jsonString: jsonString)
    }
}
extension ChatWebViewController {
    private func getChatPhoto(completion: @escaping (String) -> Void) {
        chatPhotoCompletion = completion

        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            completion("camera_unavailable")
            return
        }

        requestPermissionsIfNeeded([.camera]) { [weak self] granted in
            guard let self = self else { return }

            if granted {
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.delegate = self
                picker.allowsEditing = false
                self.isCameraPresented = true
                self.present(picker, animated: true)
            } else {
                completion("camera_unavailable")
                self.chatPhotoCompletion = nil
                self.present(PermissionBlockModalViewController(message: "사진을 촬영하기 위해서는 권한이 필요합니다.\n설정으로 이동해서 카메라 권한을 활성화 해주세요"), animated: true)
            }
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.originalImage] as? UIImage,
              let imageData = image.jpegData(compressionQuality: 0.8) else {
            chatPhotoCompletion?("error")
            chatPhotoCompletion = nil
            return
        }

        DispatchQueue.main.async { self.spinner.startAnimating() }

        Task {
            do {
                let token = try await fileUploadUseCase.execute(fileData: imageData, fileName: "chat_photo.jpg")
                DispatchQueue.main.async {
                    self.chatPhotoCompletion?(token)
                    self.chatPhotoCompletion = nil
                    self.spinner.stopAnimating()
                }
            } catch {
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                    self.chatPhotoCompletion?("upload_failed")
                    self.chatPhotoCompletion = nil
                }
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        spinner.stopAnimating()
        chatPhotoCompletion?("")
        chatPhotoCompletion = nil
    }
    func handleBridgeMethod(method: String, args: [Any], completion: @escaping (String) -> Void) {
        switch method {
        case "getUserToken":
            completion(KeychainWorker.shared.read(key: .access) ?? "")
        case "getChatPhoto":
            getChatPhoto(completion: completion)
        default:
            completion("unknown method")
        }
    }
    
    func handleDispatch(jsonString: String) {
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
                    self.webView.evaluateJavaScript(js, completionHandler: nil)
                }
            }
        } catch {
            print("❌ JSON 파싱 에러: \(error)")
        }
    }
}
extension ChatWebViewController {
    private func setupUI() {
        view.addSubview(webView)
        view.addSubview(spinner)
        view.addSubview(reportView)
    //    webView.scrollView.isScrollEnabled = false
        view.backgroundColor = .systemBackground
        webView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        spinner.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        reportView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.trailing.equalToSuperview().offset(-7)
            $0.width.equalTo(102)
            $0.height.equalTo(36)
        }
    }
}
