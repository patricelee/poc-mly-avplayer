
class MathCalculator {
    static func weightedAverage(_ data: [WeightedData]) -> Double {
        if data.isEmpty {
            return 0
        }
        if data.count == 1 {
            return data.last!.value
        }
        var sum = 0.0
        var last = WeightedData()
        for datum in data {
            sum += datum.value * (datum.offset + last.offset) * (datum.offset - last.offset)
            last = datum
        }
        let offset = data.last!.offset
        return sum / (offset * offset)
    }
}

struct WeightedData {
    var offset: Double = 0
    var value: Double = 0
}
