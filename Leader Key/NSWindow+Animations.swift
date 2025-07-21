import Cocoa

extension NSWindow {
  func fadeIn(
    duration: TimeInterval = 0.05, callback: (() -> Void)? = nil
  ) {
    // Instantly show the window without animation
    alphaValue = 1
    callback?()
  }

  func fadeOut(
    duration: TimeInterval = 0.05, callback: (() -> Void)? = nil
  ) {
    // Instantly hide the window without animation
    alphaValue = 0
    callback?()
  }

  func fadeInAndUp(
    distance: CGFloat = 50, duration: TimeInterval = 0.125,
    callback: (() -> Void)? = nil
  ) {
    // Instantly move to final frame and appear
    alphaValue = 1
    callback?()
  }

  func fadeOutAndDown(
    distance: CGFloat = 50, duration: TimeInterval = 0.125,
    callback: (() -> Void)? = nil
  ) {
    // Instantly hide without movement
    alphaValue = 0
    callback?()
  }

  func shake() {
    let numberOfShakes = 3
    let durationOfShake = 0.4
    let vigourOfShake = 0.03
    let frame: CGRect = self.frame
    let shakeAnimation = CAKeyframeAnimation()

    let shakePath = CGMutablePath()
    shakePath.move(to: CGPoint(x: NSMinX(frame), y: NSMinY(frame)))

    for _ in 0...numberOfShakes - 1 {
      shakePath.addLine(
        to: CGPoint(
          x: NSMinX(frame) - frame.size.width * vigourOfShake, y: NSMinY(frame))
      )
      shakePath.addLine(
        to: CGPoint(
          x: NSMinX(frame) + frame.size.width * vigourOfShake, y: NSMinY(frame))
      )
    }

    shakePath.closeSubpath()
    shakeAnimation.path = shakePath
    shakeAnimation.duration = durationOfShake

    let animations = [NSAnimatablePropertyKey("frameOrigin"): shakeAnimation]

    self.animations = animations
    animator().setFrameOrigin(NSPoint(x: frame.minX, y: frame.minY))
  }
}
