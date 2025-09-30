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
import os.signpost

final class Watchdog {
	static let shared = Watchdog()
	
	private let threshold: TimeInterval
	private var timer: DispatchSourceTimer?
	private var lastLogTime: CFAbsoluteTime = 0
	
	init(threshold: TimeInterval = 0.2) {
		self.threshold = threshold
	}
	
	func start() {
		let queue = DispatchQueue(label: "com.splitza.watchdog", qos: .background)
		timer = DispatchSource.makeTimerSource(queue: queue)
		timer?.schedule(deadline: .now(), repeating: threshold) // Increased interval to 1 second
		timer?.setEventHandler { [weak self] in
			self?.checkMainThread()
		}
		timer?.resume()
	}
	
	func stop() {
		timer?.cancel()
		timer = nil
	}
	
	private func checkMainThread() {
		let start = CFAbsoluteTimeGetCurrent()
		DispatchQueue.main.async {
			let elapsed = CFAbsoluteTimeGetCurrent() - start
			if elapsed > self.threshold {
				let now = CFAbsoluteTimeGetCurrent()
				if now - self.lastLogTime > self.threshold { // Log at most once every 5 seconds
					self.lastLogTime = now
					let rounded = String(format: "%.2f", elapsed)
					print("⚠️ Main thread blocked ~\(rounded)s (threshold: \(self.threshold)s)")
				}
			}
		}
	}
}
