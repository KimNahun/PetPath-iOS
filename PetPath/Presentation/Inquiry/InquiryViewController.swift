//
//  InquiryViewController.swift
//  PetPath
//
//  Created by 김나훈 on 7/2/25.
//

import Combine
import UIKit

final class InquiryViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: InquiryViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    private let scrollView = UIScrollView()
    
    private let messageLabel = UILabel().then {
        $0.text = "궁금하신 점이 있으신가요?"
    }
    
    private let subMessageLabel = UILabel().then {
        $0.text = "질문 유형을 선택해 주세요."
    }
    
    private lazy var inquryTypeCollectionView: InquryTypeCollectionView = {
        let layout = FixedSpacingFlowLayout(spacing: 8)
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.sectionInset = .zero
        let collectionView = InquryTypeCollectionView(
            frame: .zero,
            collectionViewLayout: layout, viewModel: viewModel
        )
        return collectionView
    }()
    
    private lazy var inquryContentTableView = InquryContentTableView(viewModel: viewModel)
    
    private let helpLabel = UILabel().then {
        $0.text = "아직 도움이 필요하신가요?"
    }
    
    private let kakaoImageView = AspectFitImageView().then {
        $0.image = UIImage(named: "kakao")
    }
    
    private let inquryLabel = UILabel().then {
        $0.text = "펫패스 고객센터에 문의하기"
    }
    
    private let inquryTimeLabel = UILabel().then {
        $0.text = "운영시간 06:00-24:00"
    }
    
    private let backgroundView = UIView().then {
        $0.backgroundColor = ColorSet.fromHex("#FFF8D6")
    }
    
    private let tipLabel = UILabel().then {
        $0.text = "TIP"
    }
    
    private let clearView = UIView().then {
        $0.backgroundColor = .clear
        $0.isUserInteractionEnabled = true
    }
    
    private let tipContentLabel = UILabel().then {
        $0.text = "아이콘 터치 시 카카오톡으로 자동으로 이동됩니다."
    }
    
    init(viewModel: InquiryViewModel) {
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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(clearViewTapped))
        clearView.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationTitle("문의하기")
    }
    
    // MARK: - Bind
    
    private func bind() {
        viewModel.$selectedSection.receive(on: DispatchQueue.main).sink { [weak self] _ in
            guard let self = self else { return }
            inquryTypeCollectionView.snp.updateConstraints {
                $0.height.equalTo(self.inquryTypeCollectionView.calculateDynamicHeight())
            }
        }.store(in: &subscriptions)
        
    }
}

extension InquiryViewController {
    @objc private func clearViewTapped() {
        guard let url = URL(string: "https://pf.kakao.com/_QvPFn") else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

extension InquiryViewController {
    
    private func setupLayOuts() {
        view.addSubview(scrollView)
        [messageLabel, subMessageLabel, inquryTypeCollectionView, inquryContentTableView, helpLabel, kakaoImageView, inquryLabel, inquryTimeLabel, backgroundView, clearView].forEach {
            scrollView.addSubview($0)
        }
        [tipLabel, tipContentLabel].forEach {
            backgroundView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        messageLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(30)
            $0.leading.equalToSuperview().offset(16)
        }
        subMessageLabel.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(38)
            $0.leading.equalToSuperview().offset(16)
        }
        inquryTypeCollectionView.snp.makeConstraints {
            $0.top.equalTo(subMessageLabel.snp.bottom).offset(15)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(1)
        }
        inquryContentTableView.snp.makeConstraints {
            $0.top.equalTo(inquryTypeCollectionView.snp.bottom).offset(21)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(270)
        }
        helpLabel.snp.makeConstraints {
            $0.top.equalTo(inquryContentTableView.snp.bottom)
            $0.leading.equalToSuperview().offset(16)
        }
        clearView.snp.makeConstraints {
            $0.top.leading.bottom.equalTo(kakaoImageView)
            $0.trailing.equalTo(backgroundView)
        }
        kakaoImageView.snp.makeConstraints {
            $0.top.equalTo(helpLabel.snp.bottom).offset(22)
            $0.leading.equalToSuperview().offset(16)
            $0.size.equalTo(55)
        }
        inquryLabel.snp.makeConstraints {
            $0.top.equalTo(kakaoImageView.snp.top).offset(7.5)
            $0.leading.equalTo(kakaoImageView.snp.trailing).offset(12)
        }
        inquryTimeLabel.snp.makeConstraints {
            $0.top.equalTo(inquryLabel.snp.bottom).offset(6)
            $0.leading.equalTo(kakaoImageView.snp.trailing).offset(12)
        }
        backgroundView.snp.makeConstraints {
            $0.top.equalTo(kakaoImageView.snp.bottom).offset(22)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.horizontalEdges.equalTo(view).inset(16)
            $0.height.equalTo(71)
            $0.bottom.equalToSuperview().offset(-50)
        }
        tipLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(16)
        }
        tipContentLabel.snp.makeConstraints {
            $0.bottom.leading.equalToSuperview().inset(16)
        }
    }
    
    private func setupComponents() {
        messageLabel.textColor = .dark
        messageLabel.font = FontSet.pretendardBold(size: 24)
        subMessageLabel.textColor = .dark
        subMessageLabel.font = FontSet.pretendardBold(size: 18)
        helpLabel.textColor = .dark
        helpLabel.font = FontSet.pretendardBold(size: 18)
        inquryLabel.textColor = .dark
        inquryLabel.font = FontSet.pretendardBold(size: 14)
        inquryTimeLabel.textColor = .dark
        inquryTimeLabel.font = FontSet.pretendardMedium(size: 12)
        tipLabel.textColor = ColorSet.fromHex("918130")
        tipLabel.font = FontSet.pretendardBold(size: 14)
        tipContentLabel.textColor = ColorSet.fromHex("918130")
        tipContentLabel.font = FontSet.pretendardMedium(size: 12)
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        setupComponents()
        self.view.backgroundColor = .systemBackground
    }
}

