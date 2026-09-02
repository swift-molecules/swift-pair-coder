public import Coder
public import Either
public import Pair
public import Pair_Parser
public import Parser
public import Serializer

extension Pair::Pair.Parser: Serializer::Serializer.`Protocol`
where
    First: Serializer::Serializer.`Protocol`,
    Second: Serializer::Serializer.`Protocol`,
    First.Buffer == Second.Buffer,
    First.Input: ~Copyable & ~Escapable,
    Second.Input: ~Copyable & ~Escapable,
    First.Output: ~Copyable & Escapable,
    Second.Output: ~Copyable & Escapable,
    First.Buffer: ~Copyable & ~Escapable,
    Second.Buffer: ~Copyable & ~Escapable
{

    public typealias Buffer = First.Buffer

    @inlinable
    public borrowing func serialize(_ output: borrowing Output, into buffer: inout Buffer) throws(Failure) {
        do throws(First.Failure) {
            try first.serialize(output.first, into: &buffer)
        } catch {
            throw firstFailure(error)
        }
        do throws(Second.Failure) {
            try second.serialize(output.second, into: &buffer)
        } catch {
            throw secondFailure(error)
        }
    }
}

extension Pair::Pair.Parser: Coder::Coder.`Protocol`
where
    First: Coder::Coder.`Protocol`,
    Second: Coder::Coder.`Protocol`,
    First.Buffer == Second.Buffer,
    First.Input: ~Copyable & ~Escapable,
    Second.Input: ~Copyable & ~Escapable,
    First.Output: ~Copyable & Escapable,
    Second.Output: ~Copyable & Escapable,
    First.Buffer: ~Copyable & ~Escapable,
    Second.Buffer: ~Copyable & ~Escapable
{}

extension Pair::Pair
where
    First: Coder::Coder.`Protocol`,
    Second: Coder::Coder.`Protocol`,
    First.Input == Second.Input,
    First.Buffer == Second.Buffer,
    First.Input: ~Copyable & ~Escapable,
    Second.Input: ~Copyable & ~Escapable,
    First.Output: ~Copyable & Escapable,
    Second.Output: ~Copyable & Escapable,
    First.Buffer: ~Copyable & ~Escapable,
    Second.Buffer: ~Copyable & ~Escapable
{

    @inlinable
    public consuming func coder() -> Pair::Pair<First, Second>.Parser<Either<First.Failure, Second.Failure>> {
        .init(first, second, { .left($0) }, { .right($0) })
    }

    @inlinable
    public consuming func coder() -> Pair::Pair<First, Second>.Parser<First.Failure>
    where First.Failure == Second.Failure {
        .init(first, second, { $0 }, { $0 })
    }
}
