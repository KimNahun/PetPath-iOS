//
//  AddCardViewController.swift
//  PetPath
//
//  Created by 김나훈 on 3/21/25.
//

import Combine
import UIKit

final class AddCardViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: AddCardViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    private lazy var cardNumberView = CardNumberView(viewModel: viewModel)
    
    private lazy var cardExpiryView = CardExpiryView(viewModel: viewModel).then {
        $0.isHidden = true
    }
    
    private lazy var cardPasswordView = CardPasswordView(viewModel: viewModel).then {
        $0.isHidden = true
    }
    
    private lazy var cardBirthdayView = CardBirthdayView(viewModel: viewModel).then {
        $0.isHidden = true
    }
    
    private let addButton = BottomPlacedButton().then {
        $0.setTitle("추가하기", for: .normal)
    }
    
    init(viewModel: AddCardViewModel) {
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
        hideKeyboardWhenTappedAround()
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationTitle("결제수단 등록")
    }
    
    // MARK: - Bind
    
    private func bind() {
        viewModel.successPublisher.receive(on: DispatchQueue.main).sink { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }.store(in: &subscriptions)
        
        viewModel.$addButtonEnabled.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] enabled in
            self?.addButton.setupButtonStatus(isSelected: enabled)
        }.store(in: &subscriptions)
        
        cardNumberView.finishPublisher.first().sink { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.cardExpiryView.isHidden = false
            strongSelf.cardExpiryView.snp.makeConstraints {
                $0.top.equalTo(strongSelf.view.safeAreaLayoutGuide.snp.top).offset(20)
                $0.horizontalEdges.equalToSuperview().inset(16)
                $0.height.equalTo(61)
            }
            strongSelf.cardNumberView.snp.remakeConstraints {
                $0.top.equalTo(strongSelf.cardExpiryView.snp.bottom).offset(16)
                $0.horizontalEdges.equalToSuperview().inset(16)
                $0.height.equalTo(147)
            }
            
            UIView.animate(withDuration: 0.3, animations: {
                strongSelf.view.layoutIfNeeded()
            }, completion: { _ in
                strongSelf.cardExpiryView.focusTextField()
            })
        }.store(in: &subscriptions)
        
        cardExpiryView.finishPublisher.first().sink { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.cardPasswordView.isHidden = false
            strongSelf.cardPasswordView.snp.makeConstraints {
                $0.top.equalTo(strongSelf.view.safeAreaLayoutGuide.snp.top).offset(20)
                $0.horizontalEdges.equalToSuperview().inset(16)
                $0.height.equalTo(61)
            }
            strongSelf.cardExpiryView.snp.remakeConstraints {
                $0.top.equalTo(strongSelf.cardPasswordView.snp.bottom).offset(16)
                $0.horizontalEdges.equalToSuperview().inset(16)
                $0.height.equalTo(61)
            }
            UIView.animate(withDuration: 0.3, animations: {
                strongSelf.view.layoutIfNeeded()
            }, completion: { _ in
                strongSelf.cardPasswordView.focusTextField()
            })
        }.store(in: &subscriptions)
        
        cardPasswordView.finishPublisher.first().sink { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.cardBirthdayView.isHidden = false
            strongSelf.cardBirthdayView.snp.makeConstraints {
                $0.top.equalTo(strongSelf.view.safeAreaLayoutGuide.snp.top).offset(20)
                $0.horizontalEdges.equalToSuperview().inset(16)
                $0.height.equalTo(61)
            }
            strongSelf.cardPasswordView.snp.remakeConstraints {
                $0.top.equalTo(strongSelf.cardBirthdayView.snp.bottom).offset(16)
                $0.horizontalEdges.equalToSuperview().inset(16)
                $0.height.equalTo(61)
            }
            UIView.animate(withDuration: 0.3, animations: {
                strongSelf.view.layoutIfNeeded()
            }, completion: { _ in
                strongSelf.cardBirthdayView.focusTextField()
            })
        }.store(in: &subscriptions)
        
        
    }
}

extension AddCardViewController {
    @objc private func addButtonTapped() {
        viewModel.addCard()
    }
    
}

extension AddCardViewController {
    
    private func setupLayOuts() {
        [cardNumberView, cardExpiryView, cardBirthdayView, cardPasswordView, addButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        cardNumberView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(147)
        }
        addButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(41)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        self.view.backgroundColor = .systemBackground
    }
}
