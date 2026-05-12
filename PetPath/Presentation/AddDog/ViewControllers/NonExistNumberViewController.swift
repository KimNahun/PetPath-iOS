//
//  NonExistNumberViewController.swift
//  PetPath
//
//  Created by 김나훈 on 3/17/25.
//

import Combine
import UIKit

final class NonExistNumberViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: AddDogViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    private let backgroundView = UIView().then {
        $0.backgroundColor = .secondary50
        $0.layer.cornerRadius = 5
        $0.layer.masksToBounds = true
    }
    
    private let textLabel = UILabel().then {
        $0.textColor = .secondary700
        $0.numberOfLines = 0
        $0.text = "동물 등록번호 안내\n\n동물 등록을 하지 않으면 산책 중 발생하는 사고에 대해서 대처가 어려울 수 있습니다.\n동물 등록은 2개월 이상의 강아지에 대해서 의무 사항입니다.\n동물 등록을 하지 않는 경우 과태료가 부과될 수 있습니다."
        $0.font = FontSet.pretendardMedium(size: 12)
    }
    
    private let speciesTextField = BindableTextFieldView(title: "견종").then {
        $0.setPlaceHolder(text: "견종")
    }
    
    private let nameTextField = BindableTextFieldView(title: "강아지 이름").then {
        $0.setPlaceHolder(text: "강아지 이름")
    }
    
    private let birthdayLabel = UILabel().then {
        $0.text = "강아지 생일"
        $0.font = FontSet.pretendardBold(size: 12)
        $0.textColor = .neutral6
    }
    
    private let yearDropdownButton = DropdownButton(
        placeholder: "년 선택",
        font: FontSet.pretendardMedium(size: 14),
        selectedTextColor: .dark
    )
    
    private let monthDropdownButton = DropdownButton(
        placeholder: "월 선택",
        font: FontSet.pretendardMedium(size: 14),
        selectedTextColor: .dark
    )
    
    private let genderLabel = UILabel().then {
        $0.text = "강아지 성별"
        $0.font = FontSet.pretendardBold(size: 12)
        $0.textColor = .neutral6
    }
    
    private let maleButton = UIButton().then {
        $0.setTitle("남", for: .normal)
    }
    
    private let femaleButton = UIButton().then {
        $0.setTitle("여", for: .normal)
    }
    
    private let neuterLabel = UILabel().then {
        $0.text = "강아지 중성화 여부"
        $0.font = FontSet.pretendardBold(size: 12)
        $0.textColor = .neutral6
    }
    
    private let neuterButton = UIButton().then {
        $0.setTitle("네", for: .normal)
    }
    
    private let nonNeuterButton = UIButton().then {
        $0.setTitle("아니오", for: .normal)
    }
    
    private let nextButton = BottomPlacedButton().then {
        $0.setTitle("다음", for: .normal)
    }
    
    // MARK: - Init
    init(viewModel: AddDogViewModel) {
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
        setupDropdownItems()
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        maleButton.addTarget(self, action: #selector(genderButtonTapped), for: .touchUpInside)
        femaleButton.addTarget(self, action: #selector(genderButtonTapped), for: .touchUpInside)
        neuterButton.addTarget(self, action: #selector(neuterButtonTapped), for: .touchUpInside)
        nonNeuterButton.addTarget(self, action: #selector(neuterButtonTapped), for: .touchUpInside)
        hideKeyboardWhenTappedAround()
    }

    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            setNavigationTitle("강아지 등록")
    }
    // MARK: - Bind
    
    private func bind() {
        speciesTextField.textPublisher.sink { [weak self] text in
            self?.viewModel.registRequest.species = text
        }.store(in: &subscriptions)
        
        nameTextField.textPublisher.sink { [weak self] text in
            self?.viewModel.registRequest.dogName = text
        }.store(in: &subscriptions)
        
        yearDropdownButton.selectedItemPublisher.sink { [weak self] item in
            self?.viewModel.registRequest.birthYear = item.title.replacingOccurrences(of: "년", with: "")
        }.store(in: &subscriptions)
        
        monthDropdownButton.selectedItemPublisher.sink { [weak self] item in
            self?.viewModel.registRequest.birthMonth = item.title.replacingOccurrences(of: "월", with: "")
        }.store(in: &subscriptions)
        
        viewModel.$primaryNextButtonEnabled.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] isEnabled in
            self?.nextButton.setupButtonStatus(isSelected: isEnabled)
        }.store(in: &subscriptions)
    }
}

extension NonExistNumberViewController {
    private func setupDropdownItems() {
        let currentYear = Calendar.current.component(.year, from: Date())
        let yearItems = (2000...currentYear).map { DropdownItem(id: nil, title: "\($0)년") }.reversed()
        let monthItems = (1...12).map { DropdownItem(id: nil, title: "\($0)월") }
        
        yearDropdownButton.setDropdown(items: Array(yearItems))
        monthDropdownButton.setDropdown(items: monthItems)
    }
    @objc private func genderButtonTapped(_ sender: UIButton) {
        [maleButton, femaleButton].forEach { button in
            button.isSelected = (button == sender) ? !button.isSelected : false
        }
        viewModel.registRequest.gender = maleButton.isSelected ? .male :
        femaleButton.isSelected ? .female : nil
        updateButtonStyles()
    }
    
    @objc private func neuterButtonTapped(_ sender: UIButton) {
        [neuterButton, nonNeuterButton].forEach { button in
            button.isSelected = (button == sender) ? !button.isSelected : false
        }
        viewModel.registRequest.isNeuter = neuterButton.isSelected ? true :
        nonNeuterButton.isSelected ? false : nil
        updateButtonStyles()
    }
    
    // MARK: - 버튼 스타일 업데이트
    private func updateButtonStyles() {
        let allButtons = [maleButton, femaleButton, neuterButton, nonNeuterButton]
        
        allButtons.forEach {
            if $0.isSelected {
                $0.backgroundColor = .secondary300
                $0.setTitleColor(.neutral1, for: .normal)
                $0.layer.borderWidth = 0
            } else {
                $0.setTitleColor(.neutral6, for: .normal)
                $0.layer.borderWidth = 2
                $0.backgroundColor = .clear
            }
        }
    }
    @objc private func nextButtonTapped() {
        let viewController = DogInfoViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
}

extension NonExistNumberViewController {
    
    private func setupLayOuts() {
        [
            backgroundView, textLabel, speciesTextField, nameTextField,
            birthdayLabel, yearDropdownButton, monthDropdownButton,
            genderLabel, maleButton, femaleButton,
            neuterLabel, neuterButton, nonNeuterButton,
            nextButton
        ].forEach {
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        backgroundView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(110)
        }
        textLabel.snp.makeConstraints {
            $0.top.equalTo(backgroundView.snp.top).offset(16)
            $0.horizontalEdges.equalTo(backgroundView).inset(16)
        }
        speciesTextField.snp.makeConstraints {
            $0.top.equalTo(backgroundView.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(57)
        }
        nameTextField.snp.makeConstraints {
            $0.top.equalTo(speciesTextField.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(57)
        }
        birthdayLabel.snp.makeConstraints {
            $0.top.equalTo(nameTextField.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(16)
        }
        yearDropdownButton.snp.makeConstraints {
            $0.top.equalTo(birthdayLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalTo(view.snp.centerX).inset(4)
            $0.height.equalTo(40)
        }
        monthDropdownButton.snp.makeConstraints {
            $0.bottom.equalTo(yearDropdownButton)
            $0.leading.equalTo(yearDropdownButton.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(40)
        }
        genderLabel.snp.makeConstraints {
            $0.top.equalTo(yearDropdownButton.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(16)
        }
        maleButton.snp.makeConstraints {
            $0.top.equalTo(genderLabel.snp.bottom).offset(6)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalTo(view.snp.centerX).inset(4)
            $0.height.equalTo(37)
        }
        femaleButton.snp.makeConstraints {
            $0.top.equalTo(genderLabel.snp.bottom).offset(6)
            $0.leading.equalTo(view.snp.centerX).offset(4)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(37)
        }
        neuterLabel.snp.makeConstraints {
            $0.top.equalTo(femaleButton.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(16)
        }
        neuterButton.snp.makeConstraints {
            $0.top.equalTo(neuterLabel.snp.bottom).offset(6)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalTo(view.snp.centerX).inset(4)
            $0.height.equalTo(37)
        }
        nonNeuterButton.snp.makeConstraints {
            $0.top.equalTo(neuterLabel.snp.bottom).offset(6)
            $0.leading.equalTo(view.snp.centerX).offset(4)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(37)
        }
        nextButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(41)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
    }
    private func setupComponents() {
        backgroundView.backgroundColor = .secondary50
        textLabel.font = FontSet.pretendardMedium(size: 12)
        
        [maleButton, femaleButton, neuterButton, nonNeuterButton].forEach {
            $0.titleLabel?.font = FontSet.pretendardMedium(size: 14)
            $0.layer.borderColor = ColorSet.neutral6.cgColor
            $0.layer.borderWidth = 2
            $0.setTitleColor(.neutral6, for: .normal)
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = 8
        }
        [genderLabel, neuterLabel].forEach {
            $0.font = FontSet.pretendardBold(size: 12)
            $0.textColor = .neutral6
        }
        [yearDropdownButton, monthDropdownButton].forEach {
            $0.layer.borderWidth = 2
            $0.layer.cornerRadius = 8
            $0.layer.borderColor = ColorSet.neutral6.cgColor
        }
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        setupComponents()
        self.view.backgroundColor = .systemBackground
    }
}
