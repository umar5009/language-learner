import Foundation
import UIKit

/// Builds a printable weekly prep PDF from the study pack + week content.
enum StudyPDFExporter {
    static func makePDF(
        courseName: String,
        institute: String,
        languageId: String,
        week: CourseWeek
    ) -> Data {
        let pack = week.resolvedStudyPack
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792) // US Letter
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        return renderer.pdfData { context in
            var y: CGFloat = 0
            let margin: CGFloat = 48
            let width = pageRect.width - margin * 2

            func newPage() {
                context.beginPage()
                y = margin
            }

            func ensureSpace(_ needed: CGFloat) {
                if y + needed > pageRect.height - margin {
                    newPage()
                }
            }

            func drawText(_ text: String, font: UIFont, color: UIColor = .black, spacing: CGFloat = 8) {
                let paragraph = NSMutableParagraphStyle()
                paragraph.lineBreakMode = .byWordWrapping
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: color,
                    .paragraphStyle: paragraph
                ]
                let bounding = (text as NSString).boundingRect(
                    with: CGSize(width: width, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: attrs,
                    context: nil
                )
                ensureSpace(bounding.height + spacing)
                text.draw(in: CGRect(x: margin, y: y, width: width, height: bounding.height), withAttributes: attrs)
                y += bounding.height + spacing
            }

            func heading(_ text: String) {
                y += 6
                drawText(text, font: .boldSystemFont(ofSize: 14), color: .darkGray, spacing: 10)
            }

            newPage()
            drawText(courseName, font: .boldSystemFont(ofSize: 20), spacing: 4)
            drawText(institute, font: .systemFont(ofSize: 11), color: .darkGray, spacing: 4)
            drawText(pack.title, font: .boldSystemFont(ofSize: 16), spacing: 4)
            drawText(pack.instituteSource, font: .italicSystemFont(ofSize: 10), color: .gray, spacing: 12)
            drawText("Level: \(pack.level)  ·  Week \(week.week)", font: .systemFont(ofSize: 11), spacing: 14)

            heading("Learning objectives")
            for (i, item) in pack.learningObjectives.enumerated() {
                drawText("\(i + 1). \(item)", font: .systemFont(ofSize: 11), spacing: 4)
            }

            heading("Can-do statements (\(pack.level))")
            for item in pack.canDoStatements {
                drawText("• \(item)", font: .systemFont(ofSize: 11), spacing: 4)
            }

            heading("Reading passage — \(pack.readingPassage.title)")
            drawText(pack.readingPassage.body, font: .systemFont(ofSize: 11), spacing: 6)
            if let focus = pack.readingPassage.focusWords {
                drawText("Focus words: \(focus)", font: .italicSystemFont(ofSize: 10), color: .darkGray, spacing: 4)
            }
            drawText(pack.readingPassage.sourceNote, font: .italicSystemFont(ofSize: 9), color: .gray, spacing: 10)

            heading("Grammar deep dive — \(pack.grammarDeepDive.title)")
            drawText(pack.grammarDeepDive.explanation, font: .systemFont(ofSize: 11), spacing: 4)
            drawText("Example: \(pack.grammarDeepDive.example)", font: .italicSystemFont(ofSize: 11), spacing: 4)
            drawText(pack.grammarDeepDive.practiceHint, font: .systemFont(ofSize: 10), color: .darkGray, spacing: 10)

            heading("Key phrases / vocabulary")
            for phrase in pack.keyPhrases {
                drawText("\(phrase.phrase) — \(phrase.meaning)", font: .boldSystemFont(ofSize: 11), spacing: 2)
                drawText(phrase.usage, font: .italicSystemFont(ofSize: 10), color: .darkGray, spacing: 6)
            }

            heading("Worksheet")
            for (i, item) in pack.worksheet.enumerated() {
                drawText("Task \(i + 1) [\(item.type)]", font: .boldSystemFont(ofSize: 11), spacing: 2)
                drawText(item.prompt, font: .systemFont(ofSize: 11), spacing: 2)
                drawText("Model answer: \(item.answer)", font: .italicSystemFont(ofSize: 10), color: .darkGray, spacing: 8)
            }

            heading("Prep checklist")
            for item in pack.prepChecklist {
                drawText("☐  \(item)", font: .systemFont(ofSize: 11), spacing: 4)
            }

            heading("Exam tips")
            for tip in pack.examTips {
                drawText("• \(tip)", font: .systemFont(ofSize: 11), spacing: 4)
            }

            heading("6-day self-study plan")
            drawText(pack.selfStudyPlan, font: .systemFont(ofSize: 11), spacing: 12)

            drawText(
                "Generated in LinguaPath for personal study. Content is pedagogically aligned with \(institute) frameworks; it is not an official exam paper.",
                font: .italicSystemFont(ofSize: 8),
                color: .gray,
                spacing: 4
            )
        }
    }

    static func suggestedFileName(courseId: String, week: Int) -> String {
        "\(courseId)_week\(week)_prep_pack.pdf"
    }
}
