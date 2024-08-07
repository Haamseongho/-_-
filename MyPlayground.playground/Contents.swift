import UIKit

struct Point {
    var x = 0.0, y = 0.0
    mutating func moveBy(deltaX: Double, deltaY: Double) {
        x += deltaX
        y += deltaY
    }
}

var somePoint = Point(x: 1.0, y: 1.0)
somePoint.moveBy(deltaX: 2.0, deltaY: 3.0) // → somePoint 의 값 : (3.0, 4.0)

class Point2 {
    var x = 0.0
    var y = 0.0
    
    init(x: Double = 0.0, y: Double = 0.0) {
        self.x = x
        self.y = y
    }
    func moveBy(deltaX: Double, deltaY: Double){
        x += deltaX
        y += deltaY
    }
}

var somePoint2 = Point2(x: 1.0, y: 1.0)
somePoint2.moveBy(deltaX: 5.0, deltaY: 7.0)
print("somePoint.x = \(somePoint.x) somePoint.y = \(somePoint.y)")
print("somePoint2.x = \(somePoint2.x) somePoint2.y = \(somePoint2.y)")
