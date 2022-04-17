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
    private func getRecommendations() -> AnyPublisher<CoreDataFetchResultsPublisher<ActivityRecommendation>.Output, NetworkError> {
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
    public func saveRecommendations(newRecommendations: [RecommendationResource]) -> AnyPublisher<CoreDataSaveModelPublisher.Output, NetworkError> {
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
    
    private func getRecommendationObject(data: RecommendationResource) -> ActivityRecommendation? {
        if let sport = self.sportManager.currentSports.value.first(where: { $0.id == data.sport_id }) {
            let recommendation: ActivityRecommendation = self.coreDataStore.createEntity()
            recommendation.created_at = Helpers.getDateFromString(from: data.created_at)
            
            if let start = data.start_time, let end = data.end_time {
                recommendation.end_time = Helpers.getDateFromString(from: end)
                recommendation.start_time = Helpers.getDateFromString(from: start)
            }
            recommendation.sport = sport
            
            return recommendation
        } else { return nil }
    }
}
