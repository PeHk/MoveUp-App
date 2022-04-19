//
//  RecommendationCoreManager.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 17/04/2022.
//

import Foundation
import CoreData
import Combine
import UIKit

extension RecommendationsManager {
    
    public func fetchCurrentRecommendations() {
        self.getRecommendations()
            .sink { completion in
                return
            } receiveValue: { recommendations in
                if recommendations.count >= 3 {
                    self.recommendation.send(Array(recommendations[0...2]))
                    self.recommendationLock.send(())
                } else {
                    self.recommendation.send(recommendations)
                    self.recommendationLock.send(())
                }
            }
            .store(in: &subscription)
    }
    
    // MARK: Get activities
    public func getRecommendations() -> AnyPublisher<CoreDataFetchResultsPublisher<ActivityRecommendation>.Output, NetworkError> {
        let request = NSFetchRequest<ActivityRecommendation>(entityName: ActivityRecommendation.entityName)
        let sort = NSSortDescriptor(key: "created_at", ascending: false)
        request.sortDescriptors = [sort]
        
        return coreDataStore
            .publicher(fetch: request)
            .mapError({ error in
            .init(initialError: nil, backendError: nil, error)
            })
            .eraseToAnyPublisher()
    }
    
    // MARK: Save activity
    public func saveRecommendations(newRecommendations: [ActivityRecommendationResource]) -> AnyPublisher<CoreDataSaveModelPublisher.Output, NetworkError> {
        let action: Action = {
            for recommendation in newRecommendations {
                let _ = self.getRecommendationObject(data: recommendation)
            }
        }
        
        return coreDataStore
            .publicher(save: action)
            .mapError({ error in
            .init(initialError: nil, backendError: nil, error)
            })
            .eraseToAnyPublisher()
    }
    
    private func getRecommendationObject(data: ActivityRecommendationResource) -> ActivityRecommendation {
        let recommendation: ActivityRecommendation = self.coreDataStore.createEntity()
        recommendation.created_at = data.created_at
        recommendation.start_time = data.start_time
        recommendation.end_time = data.end_time
        recommendation.sport = data.sport
        recommendation.uuid = UUID()
        return recommendation
    }
    
    // MARK: Delete sports
    public func deleteRecommendations() -> AnyPublisher<CoreDataDeleteModelPublisher.Output, NetworkError> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: ActivityRecommendation.entityName)
        request.predicate = NSPredicate(format: "created_at != nil")
        
        self.recommendation.send([])
        
        return coreDataStore
            .publicher(delete: request)
            .mapError({ error in
            .init(initialError: nil, backendError: nil, error)
            })
            .eraseToAnyPublisher()
    }
    
    public func updateSyncRecommendations(rec: [ActivityRecommendation]) {
        for r in rec {
            updateSync(recommendation: r).sink { _ in
                ()
            } receiveValue: { _ in
                ()
            }
            .store(in: &subscription)
        }
    }
    
    private func updateSync(recommendation: ActivityRecommendation) -> AnyPublisher<CoreDataSaveModelPublisher.Output, NetworkError> {
        let action: Action = {
            recommendation.alreadySent = true
        }
        
        return coreDataStore
            .publicher(save: action)
            .mapError({ error in
            .init(initialError: nil, backendError: nil, error)
            })
            .eraseToAnyPublisher()
    }
    
}
