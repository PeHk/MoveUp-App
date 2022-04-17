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
                } else {
                    self.recommendation.send(recommendations)
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
        return recommendation
    }
}
