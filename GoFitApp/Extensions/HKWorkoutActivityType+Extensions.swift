//
//  HealthKitActivityType+Extensions.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 15/01/2022.
//

import Foundation
import HealthKit

extension HKWorkoutActivityType {

    /*
     Simple mapping of available workout types to a human readable name.
     */
    var name: String {
        switch self {
        case .americanFootball:             return "American Football"
        case .archery:                      return "Archery"
        case .australianFootball:           return "Australian Football"
        case .badminton:                    return "Badminton"
        case .baseball:                     return "Baseball"
        case .basketball:                   return "Basketball"
        case .bowling:                      return "Bowling"
        case .boxing:                       return "Boxing"
        case .climbing:                     return "Climbing"
        case .crossTraining:                return "Cross Training"
        case .curling:                      return "Curling"
        case .cycling:                      return "Cycling"
        case .dance:                        return "Dance"
        case .danceInspiredTraining:        return "Dance Inspired Training"
        case .elliptical:                   return "Elliptical"
        case .equestrianSports:             return "Equestrian Sports"
        case .fencing:                      return "Fencing"
        case .fishing:                      return "Fishing"
        case .functionalStrengthTraining:   return "Functional Strength Training"
        case .golf:                         return "Golf"
        case .gymnastics:                   return "Gymnastics"
        case .handball:                     return "Handball"
        case .hiking:                       return "Hiking"
        case .hockey:                       return "Hockey"
        case .hunting:                      return "Hunting"
        case .lacrosse:                     return "Lacrosse"
        case .martialArts:                  return "Martial Arts"
        case .mindAndBody:                  return "Mind and Body"
        case .mixedMetabolicCardioTraining: return "Mixed Metabolic Cardio Training"
        case .paddleSports:                 return "Paddle Sports"
        case .play:                         return "Play"
        case .preparationAndRecovery:       return "Preparation and Recovery"
        case .racquetball:                  return "Racquetball"
        case .rowing:                       return "Rowing"
        case .rugby:                        return "Rugby"
        case .running:                      return "Running"
        case .sailing:                      return "Sailing"
        case .skatingSports:                return "Skating Sports"
        case .snowSports:                   return "Snow Sports"
        case .soccer:                       return "Soccer"
        case .softball:                     return "Softball"
        case .squash:                       return "Squash"
        case .stairClimbing:                return "Stair Climbing"
        case .surfingSports:                return "Surfing Sports"
        case .swimming:                     return "Swimming"
        case .tableTennis:                  return "Table Tennis"
        case .tennis:                       return "Tennis"
        case .trackAndField:                return "Track and Field"
        case .traditionalStrengthTraining:  return "Traditional Strength Training"
        case .volleyball:                   return "Volleyball"
        case .walking:                      return "Walking"
        case .waterFitness:                 return "Water Fitness"
        case .waterPolo:                    return "Water Polo"
        case .waterSports:                  return "Water Sports"
        case .wrestling:                    return "Wrestling"
        case .yoga:                         return "Yoga"

        // iOS 10
        case .barre:                        return "Barre"
        case .coreTraining:                 return "Core Training"
        case .crossCountrySkiing:           return "Cross Country Skiing"
        case .downhillSkiing:               return "Downhill Skiing"
        case .flexibility:                  return "Flexibility"
        case .highIntensityIntervalTraining:    return "High Intensity Interval Training"
        case .jumpRope:                     return "Jump Rope"
        case .kickboxing:                   return "Kickboxing"
        case .pilates:                      return "Pilates"
        case .snowboarding:                 return "Snowboarding"
        case .stairs:                       return "Stairs"
        case .stepTraining:                 return "Step Training"
        case .wheelchairWalkPace:           return "Wheelchair Walk Pace"
        case .wheelchairRunPace:            return "Wheelchair Run Pace"

        // iOS 11
        case .taiChi:                       return "Tai Chi"
        case .mixedCardio:                  return "Mixed Cardio"
        case .handCycling:                  return "Hand Cycling"

        // iOS 13
        case .discSports:                   return "Disc Sports"
        case .fitnessGaming:                return "Fitness Gaming"

        // Catch-all
        default:                            return "Other"
        }
    }

}

extension String {
    var hkWorkoutActivityType: HKWorkoutActivityType {
        switch self {
        case "americanFootball":            return .americanFootball
        case "archery":                     return .archery
        case "australianFootball":          return .australianFootball
        case "badminton":                   return .badminton
        case "baseball":                    return .baseball
        case "basketball":                  return .basketball
        case "bowling":                     return .bowling
        case "boxing":                      return .boxing
        case "climbing":                    return .climbing
        case "crossTraining":               return .crossTraining
        case "curling":                     return .curling
        case "cycling":                     return .cycling
        case "dance":                       return .socialDance
        case "danceInspiredTraining":       return .cardioDance
        case "elliptical":                  return .elliptical
        case "equestrianSports":            return .equestrianSports
        case "fencing":                     return .fencing
        case "fishing":                     return .fishing
        case "functionalStrengthTraining":  return .functionalStrengthTraining
        case "golf":                        return .golf
        case "gymnastics":                  return .gymnastics
        case "handball":                    return .handball
        case "hiking":                      return .hiking
        case "hockey":                      return .hockey
        case "hunting":                     return .hunting
        case "lacrosse":                    return .lacrosse
        case "martialArts":                 return .martialArts
        case "mindAndBody":                 return .mindAndBody
        case "paddleSports":                return .paddleSports
        case "play":                        return .play
        case "preparationAndRecovery":       return .preparationAndRecovery
        case "racquetball":                  return .racquetball
        case "rowing":                       return .rowing
        case "rugby":                        return .rugby
        case "running":                      return .running
        case "sailing":                      return .sailing
        case "skatingSports":                return .skatingSports
        case "snowSports":                   return .snowSports
        case "soccer":                       return .soccer
        case "softball":                     return .softball
        case "squash":                       return .squash
        case "stairClimbing":                return .stairClimbing
        case "surfingSports":                return .surfingSports
        case "swimming":                     return .swimming
        case "tableTennis":                  return .tableTennis
        case "tennis":                       return .tennis
        case "trackAndField":                return .trackAndField
        case "traditionalStrengthTraining":  return .traditionalStrengthTraining
        case "volleyball":                   return .volleyball
        case "walking":                      return .walking
        case "waterFitness":                 return .waterFitness
        case "waterPolo":                    return .waterPolo
        case "waterSports":                  return .waterSports
        case "wrestling":                    return .wrestling
        case "yoga":                         return .yoga
            
        // iOS 10
        case "barre":                        return .barre
        case "coreTraining":                 return .coreTraining
        case "crossCountrySkiing":           return .crossCountrySkiing
        case "downhillSkiing":               return .downhillSkiing
        case "flexibility":                  return .flexibility
        case "highIntensityIntervalTraining":    return .highIntensityIntervalTraining
        case "jumpRope":                     return .jumpRope
        case "kickboxing":                   return .kickboxing
        case "pilates":                      return .pilates
        case "snowboarding":                 return .snowboarding
        case "stairs":                       return .stairs
        case "stepTraining":                 return .stepTraining
        case "wheelchairWalkPace":           return .wheelchairWalkPace
        case "wheelchairRunPace":            return .wheelchairRunPace

        // iOS 11
        case "taiChi":                       return .taiChi
        case "mixedCardio":                  return .mixedCardio
        case "handCycling":                  return .handCycling

        // iOS 13
        case "discSports":                  return .discSports
        case "fitnessGaming":               return .fitnessGaming

        // Catch-all
        default:                            return .other
        }
    }
}
