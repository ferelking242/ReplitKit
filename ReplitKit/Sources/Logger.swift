import Foundation

final class Logger {
    static let shared = Logger()
    private let fileURL: URL
    private let queue = DispatchQueue(label: "com.AIVOS.ReplitKit.logger")

    private init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        fileURL = docs.appendingPathComponent("replitkit.log")
        log("=== ReplitKit Session Start \(Date()) ===")
    }

    func log(_ msg: String, level: String = "INFO") {
        let line = "[\(level)] \(timestamp()) \(msg)"
        print(line)
        queue.async {
            let data = (line + "\n").data(using: .utf8)!
            if FileManager.default.fileExists(atPath: self.fileURL.path),
               let fh = try? FileHandle(forWritingTo: self.fileURL) {
                fh.seekToEndOfFile()
                fh.write(data)
                fh.closeFile()
            } else {
                try? data.write(to: self.fileURL)
            }
        }
    }

    func error(_ msg: String) { log(msg, level: "ERROR") }
    func warn(_ msg: String)  { log(msg, level: "WARN") }
    func net(_ msg: String)   { log(msg, level: "NET") }
    func js(_ msg: String)    { log(msg, level: "JS") }

    private func timestamp() -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss.SSS"
        return f.string(from: Date())
    }

    var logPath: String { fileURL.path }
}
