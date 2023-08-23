import Cocoa

extension CGRect {
  // TODOY
  // x position should be separate
  // width should be separate
  // height should be separate..
  enum ScreenConfig {
    case full
    case rightHalf
    case leftHalf
    case leftTwoThirds
    case leftThreeFourths
    case topHalf
    case bottomHalf
  }

  func rect(for config: ScreenConfig) -> CGRect {
    switch config {
    case .full:
      return self
    case .rightHalf:
      return CGRect(x: width/2, y: 0, width: width/2, height: height)
    case .leftHalf:
      return CGRect(x: 0, y: 0, width: width/2, height: height)
    case .leftTwoThirds:
      return CGRect(x: 0, y: 0, width: width/3 * 2, height: height)
    case .leftThreeFourths:
      return CGRect(x: 0, y: 0, width: width/4 * 3, height: height)
    case .topHalf:
      return CGRect(x: 0, y: 0, width: width, height: height/2)
    case .bottomHalf:
      return CGRect(x: 0, y: height/2, width: width, height: height/2)
    }

  }

}
