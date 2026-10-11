import Foundation
import Observation
import MnemonicsCore

enum LearningPhase { case setup, countdown, active, paused, completed }

struct SessionError: LocalizedError { let message: String; var errorDescription: String? { message } }

/// Port of the `LearningSession` Riverpod notifier (learning_session_provider.dart).
@Observable @MainActor
final class LearningSessionModel {
    var phase: LearningPhase = .setup
    var duration: SessionDuration = .ten
    var mode: SessionMode = .dueForReview
    private(set) var words: [VocabularyWord] = []
    private(set) var index = 0
    private(set) var revealed = false
    private(set) var reviews: [SessionWordReview] = []
    private(set) var countdown = 3
    private(set) var remaining: TimeInterval = 0
    private(set) var startedAt: Date?
    private(set) var endedAt: Date?

    private var ticker: Task<Void, Never>?
    private var remainingAtPause: TimeInterval = 0
    private var lastResume: Date?
    private var cardShownAt = Date()

    var currentWord: VocabularyWord? { words.indices.contains(index) ? words[index] : nil }
    var progress: Double { words.isEmpty ? 0 : Double(index + 1) / Double(words.count) }
    var summary: LearningSessionSummary { .make(reviews: reviews, start: startedAt, end: endedAt) }

    func start(model: AppModel) async throws {
        var list = mode.select(from: model.words, progress: model.progress)
        if list.isEmpty {
            phase = .completed
            throw SessionError(message: "No words available for the selected mode. Try practicing other words first!")
        }
        list.shuffle()
        words = list; index = 0; revealed = false; reviews = []; endedAt = nil
        startedAt = Date(); phase = .countdown; countdown = 3
        ticker?.cancel()
        ticker = Task { [weak self] in
            for n in stride(from: 3, through: 1, by: -1) {
                await MainActor.run { self?.countdown = n }
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                if Task.isCancelled { return }
            }
            await MainActor.run { self?.beginActive() }
        }
    }

    private func beginActive() {
        phase = .active
        startedAt = Date()
        remainingAtPause = TimeInterval(duration.minutes * 60)
        remaining = remainingAtPause
        lastResume = Date(); cardShownAt = Date()
        runClock()
    }

    private func runClock() {
        ticker?.cancel()
        ticker = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 250_000_000)
                await MainActor.run {
                    guard let self, self.phase == .active, let r = self.lastResume else { return }
                    self.remaining = max(0, self.remainingAtPause - Date().timeIntervalSince(r))
                    if self.remaining <= 0 { self.complete() }
                }
            }
        }
    }

    func pause() {
        guard phase == .active, let r = lastResume else { return }
        remainingAtPause = max(0, remainingAtPause - Date().timeIntervalSince(r))
        remaining = remainingAtPause; phase = .paused
    }
    func resume() {
        guard phase == .paused else { return }
        lastResume = Date(); phase = .active
    }

    func flip() { if !revealed { revealed = true } }

    func rate(_ rating: ReviewDifficultyRating, model: AppModel) async {
        guard let w = currentWord else { return }
        let spent = Date().timeIntervalSince(cardShownAt)
        reviews.append(SessionWordReview(word: w.word, rating: rating, reviewedAt: Date(), timeSpent: spent))
        _ = await model.review(w.word, rating: ReviewRating(rawValue: rating.rawValue) ?? .medium)
        next()
    }

    func skip() {
        guard let w = currentWord else { return }
        reviews.append(SessionWordReview(word: w.word, rating: .hard, reviewedAt: Date(), timeSpent: Date().timeIntervalSince(cardShownAt), wasSkipped: true))
        next()
    }

    /// When the list runs out it restarts with the same set (as Flutter).
    private func next() {
        index = index < words.count - 1 ? index + 1 : 0
        revealed = false; cardShownAt = Date()
    }

    func complete() {
        ticker?.cancel(); endedAt = Date(); phase = .completed
    }

    func reset() {
        ticker?.cancel(); phase = .setup; words = []; reviews = []; index = 0; revealed = false; startedAt = nil; endedAt = nil
    }
}
