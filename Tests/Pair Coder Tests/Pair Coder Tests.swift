import Coder
import Either
import Pair
import Pair_Coder
import Pair_Parser
import Parser
import Parser_Skip
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
        let coder: Pair<Constant, Constant>.Parser<Mismatch> = Pair(Constant("a="), Constant("1")).coder()
        var buffer: Substring = ""
        try coder.serialize(Pair("a=", "1"), into: &buffer)
        #expect(buffer == "a=1")
    }
}

extension `Pair Coder`.`Edge Case` {

    @Test
    func `a mismatching second child stops after the first child emitted`() {
        let coder: Pair<Constant, Constant>.Parser<Mismatch> = Pair(Constant("a="), Constant("1")).coder()
        var buffer: Substring = ""
        #expect(throws: Mismatch.mismatch) {
            try coder.serialize(Pair("a=", "2"), into: &buffer)
        }
        #expect(buffer == "a=")
    }
}

extension `Pair Coder`.Integration {

    @Test
    func `a coder body with two values round-trips through a Pair`() throws(any Swift.Error) {
        var buffer: Substring = ""
        try KeyValue().serialize(Pair("k", "v"), into: &buffer)
        #expect(buffer == "k=v")
        var cursor = buffer
        let parsed = try KeyValue().parse(&cursor)
        #expect(parsed.first == "k")
        #expect(parsed.second == "v")
        #expect(cursor.isEmpty)
    }

    @Test
    func `a pair round-trips through parse and serialize`() throws(any Swift.Error) {
        let coder: Pair<Constant, Constant>.Parser<Mismatch> = Pair(Constant("user/"), Constant("7")).coder()
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

private struct Marker: Coder.`Protocol` {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    func parse(_ input: inout Substring) throws(Mismatch) {
        guard input.hasPrefix(text) else { throw .mismatch }
        input = input.dropFirst(text.count)
    }

    func serialize(_ output: Void, into buffer: inout Substring) throws(Mismatch) {
        buffer.append(contentsOf: text)
    }
}

private struct KeyValue: Coder.`Protocol` {
    typealias Failure = Mismatch

    var body: some Coder.`Protocol`<Substring, Pair<String, String>, Substring, Mismatch> {
        Constant("k")
        Marker("=")
        Constant("v")
    }
}
