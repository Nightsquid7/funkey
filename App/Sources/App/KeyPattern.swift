enum KeyPattern {
  case sequence([Int64])
  case combination([Int64])

  var count: Int {
  switch self {
    case .sequence(let values):
      return values.count
    case .combination(let values):
      return values.count
    }
  }
}

