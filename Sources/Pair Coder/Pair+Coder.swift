public import Coder
public import Either
public import Pair
public import Parser
public import Parser_Product
public import Serializer

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
    public consuming func coder() -> Parser::Parser.Product<First, Second, Either<First.Failure, Second.Failure>> {
        .init(first, second, { .left($0) }, { .right($0) })
    }

    @inlinable
    public consuming func coder() -> Parser::Parser.Product<First, Second, First.Failure>
    where First.Failure == Second.Failure {
        .init(first, second, { $0 }, { $0 })
    }
}
