//
//  MainThreadWatchdog.swift
//  Splitza
//
//  Created to detect main thread stalls > threshold.
//
//  This lightweight utility periodically pings the main thread. If the main
//  thread doesn't service the ping within the threshold, a warning is logged.
//  You can extend this to capture a stack trace or integrate with os_signpost.
//

import Foundation

final class Watchdog: Thread {
	
	static let shared = Watchdog()
	
	private let threshold: TimeInterval
	private var lastPing = Date()
	private var semaphore = DispatchSemaphore(value: 0)
	
	init(threshold: TimeInterval = 0.2) {
		self.threshold = threshold
	}
	
	override func main() {
		
		while !isCancelled {
			
			lastPing = Date()
			
			DispatchQueue.global(qos: .userInteractive).async {  [weak self] in
				
				guard let self else {
					return
				}
				
				let delta = Date().timeIntervalSince(self.lastPing)
				
				if delta > self.threshold {
					let rounded = String(format: "%.2f", delta)
					print("⚠️ Main thread blocked ~\(rounded)s (threshold: \(self.threshold)s)")
				}
				
				lastPing = Date()
				self.semaphore.signal()
			}
			
			_ = semaphore.wait(timeout: .distantFuture)
		}
	}
}
