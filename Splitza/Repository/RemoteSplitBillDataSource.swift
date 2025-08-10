//
//  RemoteSplitBillDataSource.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 10/08/25.
//

import Combine

final class RemoteSplitBillDataSource: SplitBillDataSource {
	
	private let apiService: SplitBillAPIServiceProtocol
	
	init(apiService: SplitBillAPIServiceProtocol = SplitBillAPIService()) {
		self.apiService = apiService
	}
	
	func getAllSplitBills() -> AnyPublisher<[SplitBill], Error> {
		return apiService.getAllSplitBills(page: 1, limit: 100, sortBy: "date", sortOrder: "desc")
			.map { response in
				response.data
			}
			.mapError { $0 as Error }
			.eraseToAnyPublisher()
	}
	
	func getSplitBill(id: String) -> AnyPublisher<SplitBill, Error> {
		return apiService.getSplitBill(id: id)
			.map { response in
				response.data
			}
			.mapError { $0 as Error }
			.eraseToAnyPublisher()
	}
	
	func searchSplitBills(query: String) -> AnyPublisher<[SplitBill], Error> {
		return apiService.searchSplitBills(query: query, page: 1, limit: 100)
			.map { response in
				response.data
			}
			.mapError { $0 as Error }
			.eraseToAnyPublisher()
	}
	
	func createSplitBill(_ splitBill: SplitBill) -> AnyPublisher<SplitBill, Error> {
		let request = splitBill.toCreateRequest()
		return apiService.createSplitBill(request)
			.map { response in
				response.data
			}
			.mapError { $0 as Error }
			.eraseToAnyPublisher()
	}
	
	func updateSplitBill(_ splitBill: SplitBill) -> AnyPublisher<SplitBill, Error> {
		let request = splitBill.toUpdateRequest()
		return apiService.updateSplitBill(id: splitBill.id, request: request)
			.map { response in
				response.data
			}
			.mapError { $0 as Error }
			.eraseToAnyPublisher()
	}
	
	func deleteSplitBill(id: String) -> AnyPublisher<Void, Error> {
		return apiService.deleteSplitBill(id: id)
			.mapError { $0 as Error }
			.eraseToAnyPublisher()
	}
	
	func settleSplitBill(id: String) -> AnyPublisher<SplitBill, Error> {
		return apiService.settleSplitBill(id: id)
			.map { response in
				response.data
			}
			.mapError { $0 as Error }
			.eraseToAnyPublisher()
	}
}
