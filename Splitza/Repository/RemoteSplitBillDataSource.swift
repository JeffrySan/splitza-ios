//
//  RemoteSplitBillDataSource.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 10/08/25.
//

import RxSwift

final class RemoteSplitBillDataSource: SplitBillDataSource {
	
	private let apiService: SplitBillAPIServiceable
	
	init(apiService: SplitBillAPIServiceable = SplitBillAPIService()) {
		self.apiService = apiService
	}
	
	func getAllSplitBills() -> Observable<[SplitBill]> {
		return apiService.getAllSplitBills(page: 1, limit: 100, sortBy: "date", sortOrder: "desc")
			.map { response in
				response.data
			}
	}
	
	func getSplitBill(email: String, name: String) -> Observable<[SplitBill]> {
		return Observable.just([])
	}
	
	func searchSplitBills(query: String) -> Observable<[SplitBill]> {
		return apiService.searchSplitBills(query: query, page: 1, limit: 100)
			.map { response in
				response.data
			}
	}
	
	func createSplitBill(_ splitBill: SplitBill) -> Observable<SplitBill> {
		let request = splitBill.toCreateRequest()
		return apiService.createSplitBill(request)
			.map { response in
				response.data
			}
	}
	
	func updateSplitBill(_ splitBill: SplitBill) -> Observable<SplitBill> {
		let request = splitBill.toUpdateRequest()
		return apiService.updateSplitBill(id: splitBill.id, request: request)
			.map { response in
				response.data
			}
	}
	
	func deleteSplitBill(id: String) -> Observable<Void> {
		return apiService.deleteSplitBill(id: id)
	}
	
	func settleSplitBill(id: String) -> Observable<SplitBill> {
		return apiService.settleSplitBill(id: id)
			.map { response in
				response.data
			}
	}
}
