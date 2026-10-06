import Foundation
import Speech
import AVFoundation

/// On-device speech recognition for speaking exams.
@MainActor
final class SpeechPracticeEngine: ObservableObject {
    @Published var transcript = ""
    @Published var isRecording = false
    @Published var authorizationError: String?
    @Published var accuracyPercent: Int?

    private var recognizer: SFSpeechRecognizer?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    func configure(courseId: String) {
        let locale = VoiceCoach.shared.speechLocale(forCourseId: courseId)
        recognizer = SFSpeechRecognizer(locale: locale) ?? SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    }

    func requestPermissions() async -> Bool {
        let speechOk: Bool = await withCheckedContinuation { cont in
            SFSpeechRecognizer.requestAuthorization { status in
                cont.resume(returning: status == .authorized)
            }
        }
        guard speechOk else {
            authorizationError = "speech"
            return false
        }

        let micOk: Bool = await withCheckedContinuation { cont in
            AVAudioSession.sharedInstance().requestRecordPermission { cont.resume(returning: $0) }
        }
        if !micOk {
            authorizationError = "mic"
            return false
        }
        authorizationError = nil
        return true
    }

    func start(autoStopOnFinal: Bool = true) throws {
        stop()
        guard let recognizer, recognizer.isAvailable else {
            throw NSError(domain: "SpeechPractice", code: 1, userInfo: [NSLocalizedDescriptionKey: "Recognizer unavailable"])
        }

        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .duckOthers])
        try session.setActive(true, options: .notifyOthersOnDeactivation)

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        // On-device recognition is often unavailable for exam locales (e.g. en-GB) and fails immediately.
        request.requiresOnDeviceRecognition = false
        self.request = request

        let input = audioEngine.inputNode
        var format = input.outputFormat(forBus: 0)
        if format.sampleRate == 0 || format.channelCount == 0 {
            format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)
                ?? format
        }
        input.removeTap(onBus: 0)
        input.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            request.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()
        isRecording = true
        transcript = ""

        task = recognizer.recognitionTask(with: request) { [weak self] result, error in
            Task { @MainActor in
                guard let self else { return }
                if let result {
                    self.transcript = result.bestTranscription.formattedString
                }
                if error != nil {
                    self.stopRecordingEngine()
                    return
                }
                if autoStopOnFinal, result?.isFinal == true {
                    self.stopRecordingEngine()
                }
            }
        }
    }

    /// Ends capture but keeps the latest transcript.
    func stop() {
        stopRecordingEngine()
        task?.cancel()
        task = nil
        request = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func stopRecordingEngine() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        request?.endAudio()
        isRecording = false
    }

    /// Compares spoken text to expected target-language line; returns 0…100.
    func score(against expected: String) -> Int {
        let score = Self.similarity(transcript, expected)
        accuracyPercent = score
        return score
    }

    nonisolated static func similarity(_ a: String, _ b: String) -> Int {
        let left = normalize(a)
        let right = normalize(b)
        guard !left.isEmpty, !right.isEmpty else { return 0 }
        if left == right { return 100 }

        let leftTokens = Set(left.split(separator: " ").map(String.init))
        let rightTokens = Set(right.split(separator: " ").map(String.init))
        let intersection = leftTokens.intersection(rightTokens).count
        let union = leftTokens.union(rightTokens).count
        let jaccard = union == 0 ? 0.0 : Double(intersection) / Double(union)

        let distance = levenshtein(left, right)
        let maxLen = max(left.count, right.count)
        let edit = maxLen == 0 ? 1.0 : 1.0 - (Double(distance) / Double(maxLen))

        let combined = (jaccard * 0.55) + (edit * 0.45)
        return Int((combined * 100).rounded())
    }

    nonisolated private static func normalize(_ s: String) -> String {
        s.lowercased()
            .folding(options: .diacriticInsensitive, locale: .current)
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    nonisolated private static func levenshtein(_ a: String, _ b: String) -> Int {
        let aChars = Array(a)
        let bChars = Array(b)
        var prev = Array(0...bChars.count)
        var cur = Array(repeating: 0, count: bChars.count + 1)
        for i in 1...aChars.count {
            cur[0] = i
            for j in 1...bChars.count {
                let cost = aChars[i - 1] == bChars[j - 1] ? 0 : 1
                cur[j] = min(prev[j] + 1, cur[j - 1] + 1, prev[j - 1] + cost)
            }
            prev = cur
        }
        return prev[bChars.count]
    }
}
