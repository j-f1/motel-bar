import SwiftUI

struct SizedButton: View {
    let title: String
    let width: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title).frame(width: width)
        }
    }
}

struct SizedButton_Previews: PreviewProvider {
    static var previews: some View {
        SizedButton(title: "Hello, world!", width: 200) {
            print("hi")
        }
    }
}
