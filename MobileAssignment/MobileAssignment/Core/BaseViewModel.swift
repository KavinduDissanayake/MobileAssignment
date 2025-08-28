//
//  BaseViewModel.swift
//  MobileAssignment
//
//  Created by KavinduDissanayake on 2025-08-28.
//


import SwiftUI

class BaseViewModel<ActionId: ActionIdType, UIAction: UIActionType>: ObservableObject {
    /// Tracks loading states for each action
    @Published private(set) var loadingStates: [ActionId: Bool] = [:]
    
    /// Stores error messages for each action
    @Published private(set) var errorMessages: [ActionId: String] = [:]
    
    /// General error message for UI display (can be bound to alerts, etc.)
    @Published var errorMessage: String? = nil
    
    /// Optional hook for observing errors (used in tests or subclass logic)
    var onErrorSet: (() -> Void)?
    
    /// Sets the loading state for a specific action
    func setLoading(_ isLoading: Bool, for actionId: ActionId) {
        loadingStates[actionId] = isLoading
        onStatusUpdate(actionId: actionId, isLoading: isLoading)
    }
    
    /// Returns the current loading state of a specific action
    func isLoading(for actionId: ActionId) -> Bool {
        return loadingStates[actionId] ?? false
    }
    
    /// Returns the error message associated with a specific actionId, if any.
    func error(for actionId: ActionId) -> String? {
        return errorMessages[actionId]
    }
    
    /// Dispatches an async task associated with an actionId
    func dispatch<T>(
        actionId: ActionId,
        task: @escaping () async throws -> T,
        onFinished: ((T?) -> Void)? = nil
    ) {
        setLoading(true, for: actionId)
        
        Task {
            do {
                let result = try await task()
                await MainActor.run {
                    self.onSuccess(actionId: actionId, result: result)
                    onFinished?(result)
                    self.setLoading(false, for: actionId)
                }
            } catch {
                await MainActor.run {
                    self.onError(actionId: actionId, error: error)
                    onFinished?(nil)
                    self.setLoading(false, for: actionId)
                }
            }
        }
    }
    
    /// Dispatches multiple async tasks in parallel, tracking each action individually.
    func dispatchGroup<T>(
        _ actionsWithTasks: [(ActionId, () async throws -> T)],
        onFinishedAll: @escaping (_ success: [ActionId], _ failure: [ActionId]) -> Void
    ) {
        let group = DispatchGroup()
        var successActions: [ActionId] = []
        var failedActions: [ActionId] = []
        let lock = NSLock()
        
        for (actionId, task) in actionsWithTasks {
            group.enter()
            dispatch(actionId: actionId, task: task) { result in
                lock.lock()
                if result != nil {
                    successActions.append(actionId)
                } else {
                    failedActions.append(actionId)
                }
                lock.unlock()
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            onFinishedAll(successActions, failedActions)
        }
    }
    
    // MARK: - Overridable Methods
    
    /// Called when the async task completes successfully
    func onSuccess<T>(actionId: ActionId, result: T) {}
    
    /// Called when the async task fails with an error
    func onError(actionId: ActionId, error: Error) {
        errorMessages[actionId] = error.localizedDescription
        errorMessage = error.localizedDescription
        onErrorSet?()
    }
    
    /// Optional hook for reacting to loading state changes per action
    func onStatusUpdate(actionId: ActionId, isLoading: Bool) {}
    
    // MARK: - Helper Methods
    
    /// Wraps an async throwing task to ignore its result and return `Void`.
    func wrap<T>(_ asyncThrowing: @escaping () async throws -> T) -> () async throws -> Void {
        return {
            _ = try await asyncThrowing()
        }
    }
    
    // MARK: - UI Action Tracking
    
    /// Centralized UI action tracking (non-fetch)
    func dispatchUIAction(_ action: UIAction) {
        onUIAction(action)
        logUIAction(action)
    }
    
    /// Button clicks should trigger this inorder to dispatch the action
    func triggerUIAction(actionId: UIAction) {
        dispatchUIAction(actionId)
    }
    
    /// Optional override to let subclasses respond to UI actions
    func onUIAction(_ action: UIAction) {}
    
    /// Analytics/logging layer for UI actions
    func logUIAction(_ action: UIAction) {
        print("[Analytics] UIAction: \(action.analyticsEventInfo.name) \(action.analyticsEventInfo.timeStamp)")
        // Plug into Firebase, Mixpanel, etc.
    }
}
