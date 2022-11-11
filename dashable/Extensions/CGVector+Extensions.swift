import Foundation
import CoreGraphics
import SpriteKit

extension CGVector: AdditiveArithmetic {
  // Vector addition
  public static func + (left: CGVector, right: CGVector) -> CGVector {
    return CGVector(dx: left.dx + right.dx, dy: left.dy + right.dy)
  }
  
  // Vector subtraction
  public static func - (left: CGVector, right: CGVector) -> CGVector {
    return left + (-right)
  }
  
  // Vector addition assignment
  public static func += (left: inout CGVector, right: CGVector) {
    left = left + right
  }
  
  // Vector subtraction assignment
  public static func -= (left: inout CGVector, right: CGVector) {
    left = left - right
  }
  
  // Vector negation
  public static prefix func - (vector: CGVector) -> CGVector {
    return CGVector(dx: -vector.dx, dy: -vector.dy)
  }
}

infix operator * : MultiplicationPrecedence
infix operator / : MultiplicationPrecedence
infix operator • : MultiplicationPrecedence

extension CGVector {
  // Scalar-vector multiplication
  public static func * (left: CGFloat, right: CGVector) -> CGVector {
    return CGVector(dx: right.dx * left, dy: right.dy * left)
  }
  
  public static func * (left: CGVector, right: CGFloat) -> CGVector {
    return CGVector(dx: left.dx * right, dy: left.dy * right)
  }
  
  // Vector-scalar division
  public static func / (left: CGVector, right: CGFloat) -> CGVector {
    guard right != 0 else { fatalError("Division by zero") }
    return CGVector(dx: left.dx / right, dy: left.dy / right)
  }
  
  // Vector-scalar division assignment
  public static func /= (left: inout CGVector, right: CGFloat) -> CGVector {
    guard right != 0 else { fatalError("Division by zero") }
    return CGVector(dx: left.dx / right, dy: left.dy / right)
  }
  
  // Scalar-vector multiplication assignment
  public static func *= (left: inout CGVector, right: CGFloat) {
    left = left * right
  }
  
  public static func random(_ range: ClosedRange<CGFloat>) -> CGVector {
    return CGVector(dx: CGFloat.random(in: range), dy: CGFloat.random(in: range))
  }
  public static func random(_ range: Range<CGFloat>) -> CGVector {
    return CGVector(dx: CGFloat.random(in: range), dy: CGFloat.random(in: range))
  }
}

extension CGVector {
  // Vector magnitude (length)
  public var magnitude: CGFloat {
    return sqrt(dx*dx + dy*dy)
  }
  
  // Distance between two vectors
  public func distance(to vector: CGVector) -> CGFloat {
    return (self - vector).magnitude
  }
  
  // Vector normalization
  public var normalized: CGVector {
    return CGVector(dx: dx / magnitude, dy: dy / magnitude)
  }
  
  // Dot product of two vectors
  public static func • (left: CGVector, right: CGVector) -> CGFloat {
    return left.dx * right.dx + left.dy * right.dy
  }
  
  public func dot(_ right: CGVector) -> CGFloat {
    return self • right
  }
  
  // Angle between two vectors
  // θ = acos(AB)
  public func angle(to vector: CGVector) -> CGFloat {
    return acos(self.normalized • vector.normalized)
  }
  
  // Performs a linear interpolation between two CGVector values.
  public func lerp(start: CGVector, end: CGVector, t: CGFloat) -> CGVector {
    return start + (end - start) * t
  }
}

extension CGPoint {
  
  public var magnitude: CGFloat {
    return sqrt(x*x + y*y)
  }
  
  public var normalized: CGPoint {
    return CGPoint(x: x / magnitude, y: y / magnitude)
  }
  
  // Dot product of two vectors
  public static func • (left: CGPoint, right: CGPoint) -> CGFloat {
    return left.x * right.x + left.y * right.y
  }
  
  public static func * (left: CGPoint, right: CGFloat) -> CGPoint {
    return CGPoint(x: left.x * right, y: left.y * right)
  }
  public static func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
  }
  public static func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
  }
  
  
  public static func random(_ range: ClosedRange<CGFloat>) -> CGPoint {
    return CGPoint(x: CGFloat.random(in: range), y: CGFloat.random(in: range))
  }
  public static func random(_ range: Range<CGFloat>) -> CGPoint {
    return CGPoint(x: CGFloat.random(in: range), y: CGFloat.random(in: range))
  }
  
  public func angle(to point: CGPoint) -> CGFloat {
    return acos(self.normalized • point.normalized)
  }
  
  public func distance(to point: CGPoint) -> CGFloat {
    return (self - point).magnitude
  }
  public func difference(with point: CGPoint) -> CGPoint {
    return (self - point)
  }
}

extension CGSize {
  public static func * (left: CGSize, right: CGFloat) -> CGSize {
    return CGSize(width: left.width * right, height: left.height * right)
  }
}

// MARK: - Init
extension CGVector {
  init(_ point: CGPoint) {
    self.init(dx: point.x, dy: point.y)
  }
}

extension CGPoint {
  init(xy: CGFloat) {
    self.init(x: xy, y: xy)
  }
  init(_ point: float2) {
    self.init(x: CGFloat(point.x), y: CGFloat(point.y))
  }
}
extension float2 {
  init(_ point: CGPoint) {
    self.init(x: Float(point.x), y: Float(point.y))
  }
}

extension CGPoint {
  var direction: CGPoint {
    CGPoint(x: self.x > 0 ? 1 : -1, y: self.y > 0 ? 1 : -1)
  }
  static func pointOnCircle(center: CGPoint, radius: CGFloat, angle: CGFloat) -> CGPoint {
    let x = center.x + radius * cos(angle)
    let y = center.y + radius * sin(angle)
    
    return CGPoint(x: x, y: y)
  }
  
  static func angleBetweenThreePoints(center: CGPoint, firstPoint: CGPoint, secondPoint: CGPoint) -> CGFloat {
    let firstAngle = atan2(firstPoint.y - center.y, firstPoint.x - center.x)
    let secondAnlge = atan2(secondPoint.y - center.y, secondPoint.x - center.x)
    var angleDiff = firstAngle - secondAnlge
    
    if angleDiff < 0 {
      angleDiff *= -1
    }
    
    return angleDiff
  }
  
  func angleBetweenPoints(firstPoint: CGPoint, secondPoint: CGPoint) -> CGFloat {
    return CGPoint.angleBetweenThreePoints(center: self, firstPoint: firstPoint, secondPoint: secondPoint)
  }
  
  func angleToPoint(pointOnCircle: CGPoint) -> CGFloat {
    
    let originX = pointOnCircle.x - self.x
    let originY = pointOnCircle.y - self.y
    var radians = atan2(originY, originX)
    
    while radians < 0 {
      radians += CGFloat(2 * Double.pi)
    }
    
    return radians
  }
  
  static func pointOnCircleAtArcDistance(center: CGPoint,
                                         point: CGPoint,
                                         radius: CGFloat,
                                         arcDistance: CGFloat,
                                         clockwise: Bool) -> CGPoint {
    
    var angle = center.angleToPoint(pointOnCircle: point);
    
    if clockwise {
      angle = angle + (arcDistance / radius)
    } else {
      angle = angle - (arcDistance / radius)
    }
    
    return self.pointOnCircle(center: center, radius: radius, angle: angle)
    
  }
  
  func distanceToPoint(otherPoint: CGPoint) -> CGFloat {
    return sqrt(pow((otherPoint.x - x), 2) + pow((otherPoint.y - y), 2))
  }
  
  static func CGPointRound(_ point: CGPoint) -> CGPoint {
    return CGPoint(x: CoreGraphics.round(point.x), y: CoreGraphics.round(point.y))
  }
  
  static func intersectingPointsOfCircles(firstCenter: CGPoint, secondCenter: CGPoint, firstRadius: CGFloat, secondRadius: CGFloat ) -> (firstPoint: CGPoint?, secondPoint: CGPoint?) {
    
    let distance = firstCenter.distanceToPoint(otherPoint: secondCenter)
    let m = firstRadius + secondRadius
    var n = firstRadius - secondRadius
    
    if n < 0 {
      n = n * -1
    }
    
    //no intersection
    if distance > m {
      return (firstPoint: nil, secondPoint: nil)
    }
    
    //circle is inside other circle
    if distance < n {
      return (firstPoint: nil, secondPoint: nil)
    }
    
    //same circle
    if distance == 0 && firstRadius == secondRadius {
      return (firstPoint: nil, secondPoint: nil)
    }
    
    let a = ((firstRadius * firstRadius) - (secondRadius * secondRadius) + (distance * distance)) / (2 * distance)
    let h = sqrt(firstRadius * firstRadius - a * a)
    
    var p = CGPoint.zero
    p.x = firstCenter.x + (a / distance) * (secondCenter.x - firstCenter.x)
    p.y = firstCenter.y + (a / distance) * (secondCenter.y - firstCenter.y)
    
    //only one point intersecting
    if distance == firstRadius + secondRadius {
      return (firstPoint: p, secondPoint: nil)
    }
    
    var p1 = CGPoint.zero
    var p2 = CGPoint.zero
    
    p1.x = p.x + (h / distance) * (secondCenter.y - firstCenter.y)
    p1.y = p.y - (h / distance) * (secondCenter.x - firstCenter.x)
    
    p2.x = p.x - (h / distance) * (secondCenter.y - firstCenter.y)
    p2.y = p.y + (h / distance) * (secondCenter.x - firstCenter.x)
    
    //return both points
    return (firstPoint: p1, secondPoint: p2)
  }
}
