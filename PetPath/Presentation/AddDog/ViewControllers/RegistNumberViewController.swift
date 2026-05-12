//
//  RegistNumberViewController.swift
//  PetPath
//
//  Created by 김나훈 on 3/17/25.
//

import Combine
import UIKit

final class RegistNumberViewController: UIViewController {
    
    // MARK: - Properties
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    private let existNumberView = RegisterNumberView(title: "강아지 등록번호가 있어요", imageName: "checkGreen")
    
    private let nonExistNumberView = RegisterNumberView(title: "강아지 등록번호가 없어요", imageName: "cancelRed")
    
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
        let existTapGesture = UITapGestureRecognizer(target: self, action: #selector(existNumberViewTapped))
        let nonExistTapGesture = UITapGestureRecognizer(target: self, action: #selector(nonExistNumberViewTapped))
        
        existNumberView.addGestureRecognizer(existTapGesture)
        nonExistNumberView.addGestureRecognizer(nonExistTapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            setNavigationTitle("강아지 등록")
    }
    // MARK: - Bind
    
    private func bind() {
        
    }
}

extension RegistNumberViewController {
    @objc private func existNumberViewTapped() {
        let viewController = ExistNumberViewController(viewModel: AddDogViewModel())
        navigationController?.pushViewController(viewController, animated: true)
    }
    @objc private func nonExistNumberViewTapped() {
        let viewController = NonExistNumberViewController(viewModel: AddDogViewModel())
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    
}

extension RegistNumberViewController {
    
    private func setupLayOuts() {
        [existNumberView, nonExistNumberView].forEach {
            view.addSubview($0)
        }
        
    }
    
    private func setupConstraints() {
        existNumberView.snp.makeConstraints {
            $0.bottom.equalTo(view.snp.centerY).inset(9)
            $0.height.equalTo(109)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        nonExistNumberView.snp.makeConstraints {
            $0.top.equalTo(view.snp.centerY).offset(9)
            $0.height.equalTo(109)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        self.view.backgroundColor = .systemBackground
    }
}
