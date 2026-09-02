import Coder
import Pair
import Pair_Coder
import Pair_Parser
import Parser
import Serializer
import Testing

@Suite
struct `Pair Coder` {

    struct Constant: Coder.`Protocol`, Parser.Bidirectional {

        typealias Body = Never

        let text: String

        init(_ text: String) {
            self.text = text
        }

        enum Failure: Swift.Error {
            case mismatch
        }

        func parse(_ input: inout Substring) throws(Failure) -> String {
            guard input.hasPrefix(text) else { throw .mismatch }
            input = input.dropFirst(text.count)
            return text
        }

        func serialize(_ output: String, into buffer: inout Substring) throws(Failure) {
            guard output == text else { throw .mismatch }
            buffer.append(contentsOf: text)
        }
    }

    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
}

extension `Pair Coder`.Unit {

    @Test
    func `a pair of serializers serializes children in forward order`() throws {
        let coder = Pair(
            `Pair Coder`.Constant("a="),
            `Pair Coder`.Constant("1")
        )
        var buffer: Substring = ""
        try coder.serialize(("a=", "1"), into: &buffer)
        #expect(buffer == "a=1")
    }
}

extension `Pair Coder`.`Edge Case` {

    @Test
    func `a mismatching second child stops after the first child emitted`() throws {
        let coder = Pair(
            `Pair Coder`.Constant("a="),
            `Pair Coder`.Constant("1")
        )
        var buffer: Substring = ""
        #expect(throws: (any Swift.Error).self) {
            try coder.serialize(("a=", "2"), into: &buffer)
        }
        #expect(buffer == "a=")
    }
}

extension `Pair Coder`.Integration {

    @Test
    func `a pair round-trips through parse and serialize`() throws {
        let coder = Pair(
            `Pair Coder`.Constant("user/"),
            `Pair Coder`.Constant("7")
        )
        var buffer: Substring = ""
        try coder.serialize(("user/", "7"), into: &buffer)
        #expect(buffer == "user/7")

        var cursor = buffer
        let parsed = try coder.parser().parse(&cursor)
        #expect(parsed.first == "user/")
        #expect(parsed.second == "7")
        #expect(cursor.isEmpty)
    }
}
