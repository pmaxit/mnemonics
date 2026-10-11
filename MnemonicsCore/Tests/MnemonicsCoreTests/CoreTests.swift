import Testing
import Foundation
@testable import MnemonicsCore

private let now = Date(timeIntervalSince1970: 1_735_732_800)
private var cal: Calendar { var c = Calendar(identifier: .gregorian); c.timeZone = TimeZone(identifier: "UTC")!; return c }

@Suite struct SpacedRepetitionTests {
    @Test func firstEasyIsOneDay() {
        let r = SpacedRepetition.calculateNextReview(now: now, rating: .easy, currentInterval: 0, repetitions: 0, easeFactor: 2.5, calendar: cal)
        #expect(r.interval == 1); #expect(r.repetitions == 1)
        #expect(abs(r.easeFactor - 2.6) < 1e-9)
        #expect(r.nextReview == cal.date(byAdding: .day, value: 1, to: now))
    }
    @Test func secondIsSixDays() {
        let r = SpacedRepetition.calculateNextReview(now: now, rating: .easy, currentInterval: 1, repetitions: 1, easeFactor: 2.6, calendar: cal)
        #expect(r.interval == 6); #expect(r.repetitions == 2)
    }
    @Test func thirdMultipliesByEase() {
        let r = SpacedRepetition.calculateNextReview(now: now, rating: .easy, currentInterval: 6, repetitions: 2, easeFactor: 2.7, calendar: cal)
        #expect(r.interval == Int((6 * 2.7).rounded())); #expect(r.repetitions == 3)
    }
    @Test func hardResets() {
        let r = SpacedRepetition.calculateNextReview(now: now, rating: .hard, currentInterval: 20, repetitions: 5, easeFactor: 2.5, calendar: cal)
        #expect(r.interval == 1); #expect(r.repetitions == 0); #expect(r.easeFactor >= 1.3)
    }
    @Test func easeFloor() {
        let r = SpacedRepetition.calculateNextReview(now: now, rating: .hard, currentInterval: 1, repetitions: 0, easeFactor: 1.3, calendar: cal)
        #expect(abs(r.easeFactor - 1.3) < 1e-9)
    }
}

@Suite struct ProgressStoreTests {
    @Test func reviewSchedulesAndBecomesDue() async {
        let store = ProgressStore(fileURL: nil)
        let t0 = Date()
        let d = await store.review(word: "lucid", rating: .easy, now: t0)
        #expect(d.interval == 1)
        #expect(await store.dueWords(now: t0).isEmpty)
        #expect(await store.dueWords(now: t0.addingTimeInterval(2 * 86_400)).map(\.word) == ["lucid"])
    }
    @Test func masteryAfterThreeGoodReviews() async {
        let store = ProgressStore(fileURL: nil)
        var t = Date()
        for _ in 0..<3 { _ = await store.review(word: "x", rating: .easy, now: t); t = t.addingTimeInterval(86_400 * 10) }
        let d = await store.get("x")
        #expect(d?.learningStage == .mastered); #expect(d?.isLearned == true)
    }
    @Test func startLearningSchedulesTomorrow() async {
        let store = ProgressStore(fileURL: nil)
        let t0 = Date()
        let d = await store.startLearning(word: "gregarious", now: t0)
        #expect(d.nextReview != nil)
        #expect(await store.dueWords(now: t0.addingTimeInterval(3600)).isEmpty)
        #expect(await store.dueWords(now: t0.addingTimeInterval(86_400 + 60)).count == 1)
    }
    @Test func persistenceRoundTrip() async {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".json")
        let a = ProgressStore(fileURL: url)
        _ = await a.review(word: "lucid", rating: .medium)
        let b = ProgressStore(fileURL: url)
        #expect(await b.get("lucid")?.reviewCount == 1)
    }
}

@Suite struct ModelTests {
    @Test func flutterDateAndProgressJSON() throws {
        let json = #"{"word":"a","notes":"","isLearned":false,"nextReview":"2025-01-02T12:00:00.000","reviewCount":1,"learningStage":"learning","easeFactor":2.6,"interval":1,"repetitions":1,"hasBeenTested":true}"#
        let d = try JSONDecoder().decode(UserWordData.self, from: Data(json.utf8))
        #expect(d.nextReview != nil); #expect(d.learningStage == .learning)
    }
    @Test func vocabularyBundledAndAPIShapes() throws {
        let a = #"{"word":"lucid","meaning":"clear","mnemonic":"m","image":"i","example":"e","synonyms":["a","b"],"antonyms":["c"],"difficulty":"intermediate","category":"common","setIds":["sat"]}"#
        let w = try JSONDecoder().decode(VocabularyWord.self, from: Data(a.utf8))
        #expect(w.imageURL == "i"); #expect(w.synonyms == ["a", "b"])
        let b = #"{"word":"x","meaning":"y","synonyms":"p, q","phrases":"[\"one\",\"two\"]","exampleSentences":"[[\"s1\",\"s2\"]]","imageUrl":"u"}"#
        let v = try JSONDecoder().decode(VocabularyWord.self, from: Data(b.utf8))
        #expect(v.synonyms == ["p", "q"]); #expect(v.phrases == ["one", "two"])
        #expect(v.exampleSentences == [["s1", "s2"]]); #expect(v.imageURL == "u")
    }
    @Test func recommendationFillsFromNearestDifficulty() {
        let ws = [VocabularyWord(word: "a", meaning: "", difficulty: .basic),
                  VocabularyWord(word: "b", meaning: "", difficulty: .intermediate),
                  VocabularyWord(word: "c", meaning: "", difficulty: .advanced)]
        let r = WordRecommendation.recommend(available: ws, learned: ["a"], levels: [1], limit: 2)
        #expect(r.map(\.word) == ["b", "c"])
    }
}

@Suite struct ContextTests {
    @Test func contextSentencesSkipFiller() {
        let w = VocabularyWord(word: "abstain", meaning: "m", example: "Considered a health nut, Jessica abstained from anything containing sugar—even chocolate.",
                               exampleSentences: [["Several board members chose to abstain from the vote on the merger."], ["He abstained from alcohol for a full year."]])
        #expect(w.contextSentences.count == 3)
    }
    @Test func aiInsightsSentences() {
        let w = VocabularyWord(word: "lucid", meaning: "c", aiInsights: #"{"example_sentences":["Her lucid explanation helped everyone understand the topic.","After the fever broke, he remained lucid and answered every question."]}"#, example: "No example available")
        #expect(w.contextSentences.count == 2)
    }
    @Test func phraseUsagesMatchCollocations() {
        let w = VocabularyWord(word: "obfuscate", meaning: "m", example: "No example available", phrases: ["obfuscate the truth", "obfuscate the code"],
                               exampleSentences: [["The politician used complex jargon to obfuscate the truth during the debate."], ["Software developers often obfuscate their code to protect it from being copied."]])
        #expect(w.phraseUsages.map(\.useCase) == ["Obfuscate the truth", "Obfuscate the code"])
    }
}

@Suite struct StatsTests {
    @Test func emptyStats() {
        let s = StatisticsCalculator.calculate(vocab: [], userData: [], activities: [])
        #expect(s.streak == 0); #expect(s.milestones.count == 20)
    }
    @Test func streakAndAccuracy() {
        var d = UserWordData(word: "a"); d.hasBeenTested = true; d.lastReviewedAt = Date(); d.totalAnswers = 2; d.correctAnswers = 1
        let s = StatisticsCalculator.calculate(vocab: [], userData: [d], activities: [ReviewActivity(word: "a", reviewedAt: Date(), rating: .easy)])
        #expect(s.streak == 1); #expect(s.learnedToday == 1); #expect(abs(s.averageAccuracy - 0.5) < 1e-9)
        #expect(s.weeklyProgress.count == 7)
    }
    @Test func longestStreakAcrossGap() {
        let cal = Calendar.current, today = cal.startOfDay(for: Date())
        func day(_ n: Int) -> ReviewActivity { ReviewActivity(word: "a", reviewedAt: cal.date(byAdding: .day, value: -n, to: today)!, rating: .easy) }
        let s = StatisticsCalculator.calculate(vocab: [], userData: [], activities: [day(0), day(1), day(5), day(6), day(7), day(8)])
        #expect(s.streak == 2); #expect(s.longestStreak == 4)
    }
    @Test func breakdownGroupsByCategory() {
        let v = [VocabularyWord(word: "a", meaning: "", category: "x"), VocabularyWord(word: "b", meaning: "", category: "y")]
        var da = UserWordData(word: "a"); da.isLearned = true; da.learningStage = .mastered
        var db = UserWordData(word: "b"); db.learningStage = .learning
        let items = StatisticsCalculator.join(vocab: v, userData: [da, db])
        let b = StatisticsCalculator.breakdown(items, byCategory: true).sorted { $0.name < $1.name }
        #expect(b.map(\.name) == ["x", "y"]); #expect(b[0].masteredCount == 1); #expect(b[1].learningCount == 1)
    }
}

@Suite struct SessionTests {
    let v = [VocabularyWord(word: "a", meaning: ""), VocabularyWord(word: "b", meaning: "")]
    @Test func unreviewedWordsAreDue() { #expect(SessionMode.dueForReview.select(from: v, progress: [:]).count == 2) }
    @Test func strugglingNeedsLowAccuracy() {
        var d = UserWordData(word: "a"); d.hasBeenTested = true; d.totalAnswers = 4; d.correctAnswers = 1
        #expect(SessionMode.strugglingWords.select(from: v, progress: ["a": d]).map(\.word) == ["a"])
    }
    @Test func summaryNumbers() {
        let now = Date()
        let r = [SessionWordReview(word: "a", rating: .easy, reviewedAt: now, timeSpent: 4), SessionWordReview(word: "b", rating: .hard, reviewedAt: now, timeSpent: 6)]
        let s = LearningSessionSummary.make(reviews: r, start: now, end: now.addingTimeInterval(120))
        #expect(s.accuracyRate == 0.5); #expect(s.strugglingWords == ["b"]); #expect(s.masteredWords == ["a"]); #expect(s.wordsPerMinute == 1)
    }
}

@Suite struct PlanTests {
    @Test func studyPlanModel() {
        let plan = StudyPlan(json: ["id": "p", "user_id": "u", "title": "t", "total_words": 10, "num_days": 2, "words_per_day": 5, "start_date": "2025-01-01",
                                    "days": [["day_number": 1, "words": ["a"], "status": "done"], ["day_number": 2, "words": ["b"]]]])
        #expect(plan.completedDays == 1); #expect(plan.progress == 0.5); #expect(plan.unlockedBadges.contains(.halfway))
    }
    @Test func onboardingLevels() {
        #expect(Onboarding.assessedLevel(correct: 0) == 1); #expect(Onboarding.assessedLevel(correct: 2) == 2); #expect(Onboarding.assessedLevel(correct: 5) == 3)
        #expect(Onboarding.plan(forLevel: 1).numDays == 15); #expect(Onboarding.plan(forLevel: 3).totalWords == 100)
    }
}

@Suite struct NotificationTests {
    @Test func inboxDedupesAndCaps() {
        var inbox = NotificationInbox()
        #expect(inbox.add(title: "a", message: "m", sourceKey: "k") != nil)
        #expect(inbox.add(title: "a", message: "m", sourceKey: "k") == nil)
        for i in 0..<60 { inbox.add(title: "t\(i)", message: "m") }
        #expect(inbox.items.count == NotificationInbox.maxSize)
        #expect(inbox.unreadCount == 50); inbox.markAllRead(); #expect(inbox.unreadCount == 0)
    }
    @Test func pollerSkipsOldOnFirstLaunchAndOtherUsers() {
        let now = Date()
        let items = [AdminNotification(id: "old", title: "", body: "", targetUserId: nil, sentAt: now.addingTimeInterval(-3600)),
                     AdminNotification(id: "new", title: "", body: "", targetUserId: nil, sentAt: now),
                     AdminNotification(id: "other", title: "", body: "", targetUserId: "someone", sentAt: now)]
        let r = AdminNotificationFeed.select(items: items, seen: [], userId: "me", now: now)
        #expect(r.fresh.map(\.id) == ["new"]); #expect(r.seen.contains("old")); #expect(r.seen.contains("other"))
    }
}

@Suite struct TreeTests {
    @Test func levelsAndHealth() {
        #expect(KnowledgeTree.levelName(totalLearned: 0) == "Seed"); #expect(KnowledgeTree.levelName(totalLearned: 100) == "Oak")
        #expect(KnowledgeTree.healthFactor(daysSincePractice: 0) == 1); #expect(KnowledgeTree.healthFactor(daysSincePractice: 9) == 0.2)
        #expect(KnowledgeTree.branches(learnedWords: ["a", "b", "c"], wordToCategory: ["a": "speech", "b": "speech", "c": "change"]).first?.category == "speech")
    }
}
