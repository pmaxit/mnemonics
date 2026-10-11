import Foundation

public enum ReviewRating: String, Codable, CaseIterable, Sendable { case hard, medium, easy }

public struct SpacedRepetitionResult: Equatable, Sendable {
    public let nextReview: Date
    public let interval: Int
    public let repetitions: Int
    public let easeFactor: Double
}

/// Exact port of `SpacedRepetitionManager` (SM-2). easy=5, medium=3, hard=1.
public enum SpacedRepetition {
    public static func calculateNextReview(now: Date, rating: ReviewRating, currentInterval: Int,
                                           repetitions: Int, easeFactor: Double,
                                           calendar: Calendar = .current) -> SpacedRepetitionResult {
        let quality: Int = switch rating { case .easy: 5; case .medium: 3; case .hard: 1 }
        var reps = repetitions
        let interval: Int
        if quality >= 3 {
            switch repetitions {
            case 0: interval = 1
            case 1: interval = 6
            default: interval = Int((Double(currentInterval) * easeFactor).rounded())
            }
            reps += 1
        } else {
            reps = 0
            interval = 1
        }
        let q = Double(5 - quality)
        let ef = max(1.3, easeFactor + (0.1 - q * (0.08 + q * 0.02)))
        let next = calendar.date(byAdding: .day, value: interval, to: now) ?? now.addingTimeInterval(Double(interval) * 86_400)
        return SpacedRepetitionResult(nextReview: next, interval: interval, repetitions: reps, easeFactor: ef)
    }

    /// Port of `_updateUserWordData` in learning_session_provider.dart.
    public static func apply(rating: ReviewRating, to existing: UserWordData?, word: String,
                             now: Date = Date()) -> UserWordData {
        var d = existing ?? UserWordData(word: word)
        let correct = rating != .hard
        if existing == nil {
            d.reviewCount = 1; d.lastReviewedAt = now; d.firstLearnedAt = now
            d.correctAnswers = correct ? 1 : 0; d.totalAnswers = 1
            d.learningStage = .learning; d.hasBeenTested = true
        } else {
            d.reviewCount += 1; d.lastReviewedAt = now; d.totalAnswers += 1; d.hasBeenTested = true
            if d.firstLearnedAt == nil { d.firstLearnedAt = now }
            if correct { d.correctAnswers += 1 }
            if d.accuracyRate >= 0.8 && d.reviewCount >= 3 {
                d.learningStage = .mastered; d.isLearned = true
            } else if d.reviewCount > 0 {
                d.learningStage = .learning
            }
        }
        let r = calculateNextReview(now: now, rating: rating, currentInterval: d.interval,
                                    repetitions: d.repetitions, easeFactor: d.easeFactor)
        d.nextReview = r.nextReview; d.interval = r.interval
        d.repetitions = r.repetitions; d.easeFactor = r.easeFactor
        return d
    }
}
