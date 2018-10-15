import Foundation

class AbiEncodingContainer : SingleValueEncodingContainer {
    var codingPath: [CodingKey] = []

    private var buffer: Array<UInt8>
    private var index: Int = 0

    private func ensureCapacity(_ capacity: Int) {
        if (buffer.count - index < capacity) {
            let temp = Array<UInt8>(repeating: 0, count: buffer.count * 2 + capacity)
            buffer = temp
        }
    }

    init(capacity: Int) {
        buffer = Array<UInt8>(repeating: 0, count: capacity)
    }

    func encodeNil() throws {
        fatalError("nil encoding is not supported")
    }

    func encode(_ value: Bool) throws {
        fatalError("Bool encoding is not supported")
    }

    /*
     putVariableUInt(value.length.toLong())
     putBytes(value.toByteArray())
    */
    func encode(_ value: String) throws {
        try encode(UInt64.init(value.count))
        encodeBytes(value: [UInt8](value.utf8))
    }

    func encode(_ value: Double) throws {
        fatalError("Double encoding is not supported")
    }

    func encode(_ value: Float) throws {
        fatalError("Float encoding is not supported")
    }

    func encode(_ value: Int) throws {
        try encode(Int64.init(value))
    }

    func encode(_ value: Int8) throws {
        fatalError("Int8 encoding is not supported")
    }

    func encode(_ value: Int16) throws {
        ensureCapacity(2)
        buffer[index+1] = UInt8.init((0xFF & value))
        buffer[index+1] = UInt8.init((0xFF & value >> 8))
    }

    func encode(_ value: Int32) throws {
        ensureCapacity(4)
        buffer[index+1] = UInt8.init((0xFF & value))
        buffer[index+1] = UInt8.init((0xFF & value >> 8))
        buffer[index+1] = UInt8.init((0xFF & value >> 16))
        buffer[index+1] = UInt8.init((0xFF & value >> 24))
    }

    func encode(_ value: Int64) throws {
        ensureCapacity(8)
        buffer[index+1] = UInt8.init((0xFF & value))
        buffer[index+1] = UInt8.init((0xFF & value >> 8))
        buffer[index+1] = UInt8.init((0xFF & value >> 16))
        buffer[index+1] = UInt8.init((0xFF & value >> 24))
        buffer[index+1] = UInt8.init((0xFF & value >> 32))
        buffer[index+1] = UInt8.init((0xFF & value >> 40))
        buffer[index+1] = UInt8.init((0xFF & value >> 48))
        buffer[index+1] = UInt8.init((0xFF & value >> 56))
    }

    func encode(_ value: UInt) throws {
        fatalError("UInt encoding is not supported")
    }

    func encode(_ value: UInt8) throws {
        ensureCapacity(1)
        buffer[index+1] = value
    }

    func encode(_ value: UInt16) throws {
        fatalError("UInt16 encoding is not supported")
    }

    func encode(_ value: UInt32) throws {
        fatalError("UInt32 encoding is not supported")
    }

    func encode(_ value: UInt64) throws {
        var copy: UInt64 = value

        repeat {
            var b: UInt8 = UInt8.init(copy & 0x7f)
            copy = copy >> 7
            b = b | UInt8.init(((copy > 0) ? 1 : 0) << 7)
            try encode(b)
        } while (copy != 0)
    }

    func encode<T>(_ value: T) throws where T : Encodable {
        switch value {
        case is NameWriter:
            try (value as! NameWriter).encode(writer: self)
        case is AccountNameWriter:
            let accountNameWriter = value as! AccountNameWriter
        case is BlockNumWriter:
            let blockNumWriter = value as! BlockNumWriter
        case is BlockPrefixWriter:
            let blockPrefixWriter = value as! BlockPrefixWriter
        case is PublicKeyWriter:
            let publicKeyWriter = value as! PublicKeyWriter
        case is AssetWriter:
            let assetWriter = value as! AssetWriter
        case is ChainIdWriter:
            let chainIdWriter = value as! ChainIdWriter
        case is DataWriter:
            let dataWriter = value as! DataWriter
        case is TimestampWriter:
            let timestampWriter = value as! TimestampWriter
        case is StringCollectionWriter:
            let stringCollectionWriter = value as! StringCollectionWriter
        case is HexCollectionWriter:
            let hexCollectionWriter = value as! HexCollectionWriter
        case is AccountNameCollectionWriter:
            let accountNameCollectionWriter = value as! AccountNameCollectionWriter
        default:
            fatalError("Generic encoding is not supported")
        }
    }

    private func encodeBytes(value: Array<UInt8>) {
        ensureCapacity(value.count)
        buffer[index...index+value.count] = value[0...value.count]
        index += value.count
    }
}
