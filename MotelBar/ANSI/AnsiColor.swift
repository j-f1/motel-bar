import AppKit

public enum AnsiColor: Equatable {
  case black // 0
  case red // 1
  case green // 2
  case yellow // 3
  case blue // 4
  case magenta // 5
  case cyan // 6
  case white // 7
  case rgb(Int, Int, Int) // 48, 38
  case index(Int)
  case `default`

  public func toNSColor() -> NSColor {
    switch self {
    case .red: return .systemRed
    case .white: return .textBackgroundColor
    case .black: return .textColor
    case .blue: return .systemBlue
    case .green: return .systemGreen
    case .yellow: return .systemYellow
    case let .rgb(red, green, blue):
        return NSColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1)
    case let .index(color):
        let red = color / (16 * 16);
        let green = color / 16 - red * 16
        let blue = color - green * 16
        return NSColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1)
    case .default:
      // TODO: What's the default color?
        return NSColor.textColor
    default:
      /* TODO ... */
        return NSColor.textColor
    }
  }

  public static func == (lhs: AnsiColor, rhs: AnsiColor) -> Bool {
    switch (lhs, rhs) {
    case (let .rgb(r1, g1, b1), let .rgb(r2, g2, b2)):
      return r1 == r2 && g1 == g2 && b1 == b2
    case (let .index(i1), let .index(i2)):
      return i1 == i2
    default:
      return String(describing: lhs) == String(describing: rhs)
    }
  }
}
