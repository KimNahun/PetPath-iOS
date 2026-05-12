//
//  CouponViewController.swift
//  PetPath
//
//  Created by 김나훈 on 3/31/25.
//

import Combine
import UIKit

final class CouponViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: CouponViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    private let titleLabel = UILabel()
    
    private let fetchTypeButton = UIButton()
    
    private lazy var couponListCollectionView = CouponListTableView(viewModel: viewModel)
    
    private let noCouponLabel = UILabel().then {
        $0.isHidden = true
    }
    
    init(viewModel: CouponViewModel) {
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
        viewModel.getCouponList()
        fetchTypeButton.addTarget(self, action: #selector(fetchTypeButtonTapped), for: .touchUpInside)
    }
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            setNavigationTitle("쿠폰")
    }
    // MARK: - Bind
    
    private func bind() {
        viewModel.$couponList.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] response in
            guard let strongSelf = self else { return }
            self?.noCouponLabel.isHidden = !response.isEmpty
            self?.noCouponLabel.text = strongSelf.viewModel.fetchType == .active ? "사용할 수 있는 쿠폰이 없어요" : "만료된 쿠폰이 없어요"
            if strongSelf.viewModel.fetchType == .active {
                self?.titleLabel.text = "보유 중인 쿠폰 \(response.count)장"
                self?.fetchTypeButton.setTitle("지난 쿠폰 내역", for: .normal)
            } else {
                self?.titleLabel.text = "지난 쿠폰 내역"
                self?.fetchTypeButton.setTitle("쿠폰 보관함", for: .normal)
            }
        }.store(in: &subscriptions)

    }
}

extension CouponViewController {
    @objc private func fetchTypeButtonTapped(sender: UIButton) {
        if viewModel.fetchType == .active {
            viewModel.fetchType = .used
        } else {
            viewModel.fetchType = .active
        }
       
    }
}

extension CouponViewController {
    
    private func setupLayOuts() {
        [titleLabel, fetchTypeButton, couponListCollectionView, noCouponLabel].forEach {
            view.addSubview($0)
        }
        
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(17)
        }
        fetchTypeButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.width.equalTo(73)
            $0.height.equalTo(15)
        }
        couponListCollectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        noCouponLabel.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
    }
    
    private func setupComponents() {
        titleLabel.textColor = .dark
        titleLabel.font = FontSet.pretendardMedium(size: 14)
        fetchTypeButton.setTitleColor(ColorSet.neutral7, for: .normal)
        fetchTypeButton.titleLabel?.font = FontSet.pretendardRegular(size: 12)
        fetchTypeButton.contentHorizontalAlignment = .right
        noCouponLabel.textColor = .neutral8
        noCouponLabel.font = FontSet.pretendardBold(size: 14)
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        setupComponents()
        self.view.backgroundColor = .systemBackground
    }
}
