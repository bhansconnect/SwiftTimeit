import Dispatch
import Foundation

public struct Timer {
    private var start: DispatchTime
    private var end = DispatchTime(uptimeNanoseconds: 0)

    public init () {
        start = DispatchTime.now()
    }

    public mutating func stop(){
        end = DispatchTime.now()
    }

    public func getTime() -> UInt64 {
        if end.uptimeNanoseconds == 0 {
            print("Warning Timer.stop() never called")
	}
        return end.uptimeNanoseconds - start.uptimeNanoseconds
    }

    public func getTimeAsString() -> String {
        return formatTime(Double(getTime()))
    }
}

public func formatTime(precision: Int = 3,_ nanoseconds: Double) -> String {
    assert(precision > 0)

    if nanoseconds >= 60e9{
        let seconds = UInt64(nanoseconds/1e9)
        let parts:[(String, UInt64)] = [("d", 60*60*24),("h", 60*60),("min", 60), ("s", 1)]
        var time: [String] = []
        var leftover = seconds
        for (suffix, length) in parts{
            let value = leftover / length
            if value > 0{
                leftover = leftover % length
                time.append("\(value)\(suffix)")
            }
            if leftover < 1{
                break
            }
        }
        return time.joined(separator: " ")
    }

    if nanoseconds < 1e3 {
        return String(format: "%.\(precision)g ns", nanoseconds)
    } else if nanoseconds < 1e6 {
        return String(format: "%.\(precision)g µs", nanoseconds/1e3)
    } else if nanoseconds < 1e9 {
        return String(format: "%.\(precision)g ms", nanoseconds/1e6)
    } else {
        return String(format: "%.\(precision)g s", nanoseconds/1e9)
    }
}

public struct TimeitResult: CustomStringConvertible {
    var loops: Int
    var repititions: Int
    var allRuns: [UInt64]
    private var precision: Int
    var timings: [Double]

    public init(loops: Int, repititions: Int, allRuns: [UInt64], precision: Int){
        assert(allRuns.count == repititions)
        assert(allRuns.count > 0)
        self.loops = loops
        self.repititions = repititions
        self.allRuns = allRuns
        self.precision = precision
        self.timings = allRuns.map{ Double($0) / Double(loops)}
    }

    public var best: Double {
        return Double(allRuns.min()!)/Double(loops)
    }

    public var worst: Double {
        return Double(allRuns.max()!)/Double(loops)
    }

    public var average: Double{
        return timings.reduce(0,+)/Double(timings.count)
    }

    public var stdev: Double{
        return sqrt(timings.map{pow(($0 - average), 2)}.reduce(0,+)/Double(timings.count-1))
    }

    public var description: String {
        return "\(formatTime(precision: precision, average)) ± \( formatTime(precision: precision, stdev)) per loop (mean ± std. dev. of \(repititions) runs, \(loops) loops each)"
    }
}

private func getAverageExecutionTime(loops: Int, f: () -> ()) -> UInt64{
    f()
    var timer = Timer()
    for _ in 0..<loops{
        f()
    }
    timer.stop()
    return timer.getTime()
}

/**
Times the execution of a function multiple times.
Good for measuring very fast functions.


Example:
```
timeit {
    2 + 2
}
timeit(loops: 100, repititions: 10){
    2 + 2
}
```
- Parameter:
    - loops: Number of times to execute the function in a loop. If loops is not
        provided, loops is determined so as to get sufficient accuracy.
    - repititions: Number of repitions of loops of the function to average.
    - precision: How many digits of precision to print
    - f: The function to time
 */
public func timeit(loops: Int = 0, repititions: Int = 7, precision: Int = 3,_ f: ()->()){
    var number = loops
    if number == 0{
        for index in 0..<10{
            number = Int(pow(10.0, Double(index)))
            let time_number = getAverageExecutionTime(loops: number, f: f)
            if Double(time_number) >= 0.2*1e9{
                break
            }
        }
    }
    let allRuns: [UInt64] = (0..<repititions).map({_ in getAverageExecutionTime(loops: number,f: f)})
    let result = TimeitResult(loops: number, repititions: repititions, allRuns: allRuns, precision: precision)
    let worst = result.worst
    let best = result.best
    if worst > 4 * best && best > 0 && worst > 1e-6{
            print(String(format: """
                The slowest run took %0.2f times longer than the \
                fastest. This could mean that an intermediate result is being cached.
                """, worst / best))
    }
    print(result)
}

/**
Times the execution of a function once.
Only good for timing long functions.
Use timeit for short functions or more accuracy.

Example:
```
time {
    2 + 2
}
```
- Parameter:
    - precision: How many digits of precision to print
    - f: The function to time
 */
public func time(precision: Int = 3, _ f: ()->()){
    // Function run once for warmup
    f()
    var timer = Timer()
    f()
    timer.stop()
    print("Execution Time: \(formatTime(precision: precision, Double(timer.getTime())))")
}