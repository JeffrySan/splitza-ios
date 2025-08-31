//
//  AddBillViewController.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 30/08/25.
//

import UIKit
import SnapKit
import RxSwift
import RxRelay

final class AddBillViewController: UIViewController {
	
	// MARK: - Properties
	private let viewModel: AddBillViewModel
	private let disposeBag = DisposeBag()
	private var selectedParticipantIndex: Int?
	
	// MARK: - UI Components
	
	private lazy var scrollView: UIScrollView = {
		let scrollView = UIScrollView()
		scrollView.showsVerticalScrollIndicator = false
		return scrollView
	}()
	
	private lazy var contentView: UIView = {
		let view = UIView()
		return view
	}()
	
	private lazy var headerView: AddBillHeaderView = AddBillHeaderView()
	private lazy var detailsView: AddBillDetailsView = AddBillDetailsView()
	private lazy var totalAmountView: AddBillTotalAmountView = AddBillTotalAmountView()
	private lazy var participantsView: AddBillParticipantsView = {
		let addBillParticipantsView = AddBillParticipantsView(frame: .zero, viewModel: viewModel)
		
		addBillParticipantsView.didSelectParticipants = { [weak self] index in
			
			guard let self else {
				return
			}
			
			self.selectedParticipantIndex = index
			
			let selectionVC = ParticipantSelectionViewController(viewModel: viewModel, indexCaller: index)
			let navController = UINavigationController(rootViewController: selectionVC)
			
			self.present(navController, animated: true)
		}
		
		return addBillParticipantsView
	}()
	
	private lazy var summaryView: AddBillSummaryView = AddBillSummaryView()
	
	// MARK: - Initialization
	
	init(viewModel: AddBillViewModel = AddBillViewModel()) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		self.viewModel = AddBillViewModel()
		super.init(coder: coder)
	}
	
	// MARK: - Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupUI()
		setupKeyboardHandling()
		
		DispatchQueue.global(qos: .background).async { [weak self] in
			self?.setupBindings()
		}
	}
	
	// MARK: - Setup
	
	private func setupUI() {
		view.backgroundColor = .systemGroupedBackground
		
		// Add subviews
		view.addSubview(headerView)
		view.addSubview(scrollView)
		scrollView.addSubview(contentView)
		
		contentView.addSubview(detailsView)
		contentView.addSubview(totalAmountView)
		contentView.addSubview(participantsView)
		contentView.addSubview(summaryView)
		
		setupConstraints()
		setupActions()
	}
	
	private func setupConstraints() {
		headerView.snp.makeConstraints { make in
			make.top.leading.trailing.equalToSuperview()
			make.height.equalTo(80)
		}
		
		scrollView.snp.makeConstraints { make in
			make.top.equalTo(headerView.snp.bottom)
			make.leading.trailing.bottom.equalToSuperview()
		}
		
		contentView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
			make.width.equalToSuperview()
		}
		
		detailsView.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(20)
			make.leading.trailing.equalToSuperview().inset(16)
		}
		
		totalAmountView.snp.makeConstraints { make in
			make.top.equalTo(detailsView.snp.bottom).offset(16)
			make.leading.trailing.equalToSuperview().inset(16)
		}
		
		participantsView.snp.makeConstraints { make in
			make.top.equalTo(totalAmountView.snp.bottom).offset(24)
			make.leading.trailing.equalToSuperview()
		}
		
		summaryView.snp.makeConstraints { make in
			make.top.equalTo(participantsView.snp.bottom).offset(24)
			make.leading.trailing.equalToSuperview().inset(16)
			make.bottom.equalToSuperview().offset(-24)
		}
	}
	
	private func setupActions() {
		headerView.onCancel = { [weak self] in
			self?.dismiss(animated: true)
		}
		
		headerView.onSave = { [weak self] in
			self?.viewModel.saveBill()
		}
		
		totalAmountView.onTotalAmountChanged = { [weak self] amount in
			self?.viewModel.manualTotalAmountRelay.accept(amount)
		}
	}
	
	private func setupBindings() {
		// Form bindings - Details View
		detailsView.titleRelay
			.bind(to: viewModel.titleRelay)
			.disposed(by: disposeBag)
		
		detailsView.locationRelay
			.bind(to: viewModel.locationRelay)
			.disposed(by: disposeBag)
		
		detailsView.descriptionRelay
			.bind(to: viewModel.descriptionRelay)
			.disposed(by: disposeBag)
		
		detailsView.currencyRelay
			.bind(to: viewModel.currencyRelay)
			.disposed(by: disposeBag)
		
		// Total Amount View bindings
		totalAmountView.totalAmountRelay
			.bind(to: viewModel.manualTotalAmountRelay)
			.disposed(by: disposeBag)
		
		// Currency synchronization
		viewModel.currencyRelay
			.bind(to: totalAmountView.currencyRelay)
			.disposed(by: disposeBag)
		
		viewModel.currencyRelay
			.bind(to: participantsView.currencyRelay)
			.disposed(by: disposeBag)
		
		// Participants binding
		viewModel.participantsRelay
			.observe(on: MainScheduler.instance)
			.subscribe(onNext: { [weak self] participants in
				self?.participantsView.updateParticipants(participants)
			})
			.disposed(by: disposeBag)
		
		// Update distributed amount in total amount view
		viewModel.distributedAmount
			.observe(on: MainScheduler.instance)
			.subscribe(onNext: { [weak self] distributedAmount in
				self?.totalAmountView.updateDistributedAmount(distributedAmount)
			})
			.disposed(by: disposeBag)
		
		// Form validation - Save button state
		viewModel.isFormValid
			.observe(on: MainScheduler.instance)
			.subscribe(onNext: { [weak self] isValid in
				self?.headerView.saveButton.isEnabled = isValid
				self?.updateSaveButtonAppearance(isValid)
			})
			.disposed(by: disposeBag)
		
		// Summary updates
		Observable.combineLatest(
			viewModel.manualTotalAmountRelay.asObservable(),
			viewModel.participantsRelay.asObservable(),
			viewModel.currencyRelay.asObservable(),
			viewModel.isAmountBalanced
		) { totalAmount, participants, currency, isBalanced in
			return (totalAmount, participants.count, currency, isBalanced)
		}
		.observe(on: MainScheduler.instance)
		.subscribe(onNext: { [weak self] (totalAmount, participantCount, currency, isBalanced) in
			self?.summaryView.updateSummary(
				totalAmount: totalAmount,
				participantCount: participantCount,
				currency: currency,
				isBalanced: isBalanced
			)
		})
		.disposed(by: disposeBag)
		
		// Loading state
		viewModel.isLoadingRelay
			.observe(on: MainScheduler.instance)
			.subscribe(onNext: { [weak self] isLoading in
				self?.headerView.saveButton.isEnabled = !isLoading
			})
			.disposed(by: disposeBag)
		
		// Success
		viewModel.successRelay
			.filter { _ in true }
			.observe(on: MainScheduler.instance)
			.subscribe(onNext: { [weak self] _ in
				self?.dismiss(animated: true)
			})
			.disposed(by: disposeBag)
		
		// Error handling
		viewModel.errorRelay
			.compactMap { $0 }
			.observe(on: MainScheduler.instance)
			.subscribe(onNext: { [weak self] error in
				self?.showErrorAlert(error: error)
			})
			.disposed(by: disposeBag)
	}
	
	private func setupKeyboardHandling() {
		NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
			.subscribe(onNext: { [weak self] notification in
				self?.handleKeyboardShow(notification)
			})
			.disposed(by: disposeBag)
		
		NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
			.subscribe(onNext: { [weak self] notification in
				self?.handleKeyboardHide(notification)
			})
			.disposed(by: disposeBag)
		
		let tapGesture = UITapGestureRecognizer()
		view.addGestureRecognizer(tapGesture)
		tapGesture.rx.event
			.subscribe(onNext: { [weak self] _ in
				self?.view.endEditing(true)
			})
			.disposed(by: disposeBag)
	}
	
	// MARK: - Helper Methods
	
	private func updateSaveButtonAppearance(_ isEnabled: Bool) {
		UIView.animate(withDuration: 0.3) {
			self.headerView.saveButton.alpha = isEnabled ? 1.0 : 0.6
		}
	}
	
	private func handleKeyboardShow(_ notification: Notification) {
		guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
			  let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
			return
		}
		
		let keyboardHeight = keyboardFrame.cgRectValue.height
		
		UIView.animate(withDuration: duration) {
			self.scrollView.contentInset.bottom = keyboardHeight
			self.scrollView.verticalScrollIndicatorInsets.bottom = keyboardHeight
		}
	}
	
	private func handleKeyboardHide(_ notification: Notification) {
		guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
			return
		}
		
		UIView.animate(withDuration: duration) {
			self.scrollView.contentInset.bottom = 0
			self.scrollView.verticalScrollIndicatorInsets.bottom = 0
		}
	}
	
	private func showErrorAlert(error: Error) {
		let alert = UIAlertController(
			title: "Error",
			message: error.localizedDescription,
			preferredStyle: .alert
		)
		
		alert.addAction(UIAlertAction(title: "OK", style: .default))
		present(alert, animated: true)
	}
}
