import Coder
import Either
import Pair
import Pair_Coder
import Parser
import Parser_Product
import Serializer
import Testing

@Suite
struct `Pair Coder` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
}

private enum Mismatch: Swift.Error, Equatable {
    case mismatch
}

private struct Constant: Coder.`Protocol` {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    func parse(_ input: inout Substring) throws(Mismatch) -> String {
        guard input.hasPrefix(text) else { throw .mismatch }
        input = input.dropFirst(text.count)
        return text
    }

    func serialize(_ output: String, into buffer: inout Substring) throws(Mismatch) {
        guard output == text else { throw .mismatch }
        buffer.append(contentsOf: text)
    }
}

extension `Pair Coder`.Unit {

    @Test
    func `a pair of coders serializes children in forward order`() throws(any Swift.Error) {
        let coder: Parser.Product<Constant, Constant, Mismatch> = Pair(Constant("a="), Constant("1")).coder()
        var buffer: Substring = ""
        try coder.serialize(Pair("a=", "1"), into: &buffer)
        #expect(buffer == "a=1")
    }
}

extension `Pair Coder`.`Edge Case` {

    @Test
    func `a mismatching second child stops after the first child emitted`() {
        let coder: Parser.Product<Constant, Constant, Mismatch> = Pair(Constant("a="), Constant("1")).coder()
        var buffer: Substring = ""
        #expect(throws: Mismatch.mismatch) {
            try coder.serialize(Pair("a=", "2"), into: &buffer)
        }
        #expect(buffer == "a=")
    }
}

extension `Pair Coder`.Integration {

    @Test
    func `a pair round-trips through parse and serialize`() throws(any Swift.Error) {
        let coder: Parser.Product<Constant, Constant, Mismatch> = Pair(Constant("user/"), Constant("7")).coder()
        var buffer: Substring = ""
        try coder.serialize(Pair("user/", "7"), into: &buffer)
        #expect(buffer == "user/7")

        var cursor = buffer
        let parsed = try coder.parse(&cursor)
        #expect(parsed.first == "user/")
        #expect(parsed.second == "7")
        #expect(cursor.isEmpty)
    }
}
