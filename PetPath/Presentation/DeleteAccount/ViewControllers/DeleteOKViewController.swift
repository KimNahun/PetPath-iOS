//
//  DeleteOKViewController.swift
//  PetPath
//
//  Created by 김나훈 on 4/21/25.
//

import Combine
import UIKit

final class DeleteOKViewController: UIViewController {
    
    // MARK: - Properties
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
  
    private let messageLabel = UILabel().then {
        $0.setTitleBold(text: "회원 탈퇴 요청이\n성공적으로 처리되었습니다.")
        $0.numberOfLines = 2
    }
    
    private let subMessageLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.text = "7일 이내에 로그인이 없는 경우 자동 탈퇴 처리됩니다.\n그동안 우리 커뮤니티의 일원이 되어주셔서 감사합니다."
        $0.font = FontSet.pretendardMedium(size: 14)
        $0.textColor = .dark
    }
    
    private let imageView = AspectFitImageView().then {
        $0.image = UIImage(named: "checkCircleFill")
    }
    
    private let backLoginButton = BottomPlacedButton(isSelected: true).then {
        $0.setTitle("처음으로", for: .normal)
    }
    
    init() {
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
        backLoginButton.addTarget(self, action: #selector(backLoginButtonTapped), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationTitle("회원탈퇴")
    }
    
    // MARK: - Bind
    
    private func bind() {
        
    }
}

extension DeleteOKViewController {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        navigationController.setViewControllers([SignInViewController(viewModel: SignInViewModel())], animated: false)
       
    }
    @objc private func backLoginButtonTapped() {
        navigationController?.setViewControllers([SignInViewController(viewModel: SignInViewModel())], animated: false)
    }
}

extension DeleteOKViewController {
    
    private func setupLayOuts() {
        [messageLabel, subMessageLabel, imageView, backLoginButton].forEach {
            view.addSubview($0)
        }
        
    }
    
    private func setupConstraints() {
        messageLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(63)
        }
        subMessageLabel.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(17)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        imageView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.size.equalTo(167)
        }
        backLoginButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(41)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
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
