import Foundation
import AVFoundation

/// On-device AI tutor voice using system speech synthesis.
@MainActor
final class VoiceCoach: NSObject, ObservableObject {
    static let shared = VoiceCoach()

    @Published private(set) var isSpeaking = false

    private let synthesizer = AVSpeechSynthesizer()
    private var pendingFinish: (() -> Void)?
    private var pendingUtteranceCount = 0
    /// Bumped on every new speak/stop so stale didCancel/didFinish cannot wipe a newer session.
    private var session = 0
    private var finishSession = 0

    override private init() {
        super.init()
        synthesizer.delegate = self
    }

    func speechLocale(forCourseId id: String) -> Locale {
        switch id {
        case "ielts_english": return Locale(identifier: "en-GB")
        case "german": return Locale(identifier: "de-DE")
        case "spanish": return Locale(identifier: "es-ES")
        case "french": return Locale(identifier: "fr-FR")
        case "japanese": return Locale(identifier: "ja-JP")
        case "korean": return Locale(identifier: "ko-KR")
        case "czech": return Locale(identifier: "cs-CZ")
        case "finnish": return Locale(identifier: "fi-FI")
        default: return Locale(identifier: "en-US")
        }
    }

    /// Call when a listening/speaking screen appears so the first tap is not silent.
    func preparePlayback() {
        activatePlayback()
    }

    func speak(_ text: String, courseId: String, rate: Float = 0.47, onFinish: (() -> Void)? = nil) {
        enqueue(lines: [text], courseId: courseId, rate: rate, pause: 0, onFinish: onFinish)
    }

    func speakLines(_ lines: [String], courseId: String, pause: TimeInterval = 0.35, onFinish: (() -> Void)? = nil) {
        enqueue(lines: lines, courseId: courseId, rate: 0.47, pause: pause, onFinish: onFinish)
    }

    func stop() {
        session += 1
        pendingFinish = nil
        pendingUtteranceCount = 0
        finishSession = 0
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        isSpeaking = false
    }

    private func enqueue(lines: [String], courseId: String, rate: Float, pause: TimeInterval, onFinish: (() -> Void)?) {
        let cleaned = lines.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        session += 1
        let id = session
        pendingFinish = onFinish
        pendingUtteranceCount = cleaned.count
        finishSession = id

        if cleaned.isEmpty {
            isSpeaking = false
            let finish = pendingFinish
            pendingFinish = nil
            finish?()
            return
        }

        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        isSpeaking = true
        Task { @MainActor in
            // stopSpeaking(.immediate) can swallow utterances queued in the same turn.
            try? await Task.sleep(nanoseconds: 80_000_000)
            guard id == self.session else { return }
            self.activatePlayback()
            self.isSpeaking = true
            for (index, line) in cleaned.enumerated() {
                let utterance = self.makeUtterance(line, courseId: courseId, rate: rate)
                if index > 0 {
                    utterance.preUtteranceDelay = pause
                }
                self.synthesizer.speak(utterance)
            }
        }
    }

    private func activatePlayback() {
        let audio = AVAudioSession.sharedInstance()
        do {
            try audio.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try audio.setActive(true, options: [])
        } catch {
            try? audio.setCategory(.playback, mode: .default, options: [.duckOthers])
            try? audio.setActive(true)
        }
    }

    private func makeUtterance(_ text: String, courseId: String, rate: Float) -> AVSpeechUtterance {
        let utterance = AVSpeechUtterance(string: text)
        let locale = speechLocale(forCourseId: courseId)
        utterance.voice = AVSpeechSynthesisVoice(language: locale.identifier)
            ?? AVSpeechSynthesisVoice(language: String(locale.identifier.prefix(2)))
            ?? AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = rate
        utterance.pitchMultiplier = 1.05
        utterance.preUtteranceDelay = 0.12
        utterance.postUtteranceDelay = 0.08
        return utterance
    }

    private func handleUtteranceEnded() {
        pendingUtteranceCount = max(0, pendingUtteranceCount - 1)
        if pendingUtteranceCount == 0 && !synthesizer.isSpeaking {
            isSpeaking = false
            let finish = pendingFinish
            pendingFinish = nil
            finish?()
        }
    }
}

extension VoiceCoach: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            guard self.session == self.finishSession else { return }
            self.handleUtteranceEnded()
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            // A newer speak() may already be queued; never wipe that session.
            guard self.session == self.finishSession else { return }
            guard !self.synthesizer.isSpeaking else { return }
            self.pendingFinish = nil
            self.pendingUtteranceCount = 0
            self.isSpeaking = false
        }
    }
}
