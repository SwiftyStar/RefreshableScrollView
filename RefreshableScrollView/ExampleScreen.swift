//
//  


import SwiftUI

struct ExampleScreen: View {
    @State private var text = "Not Refreshed"
    
    var body: some View {
        RefreshableScrollView(showsIndicators: true) {
            VStack {
                Text(self.text)
                    .padding()
                Text(self.text)
                    .padding()
                Text(self.text)
                    .padding()
                Text(self.text)
                    .padding()
                Text(self.text)
                    .padding()
                Text(self.text)
                    .padding()
                Text(self.text)
                    .padding()
            }
        } onRefresh: {
            await Task.sleep(1_000_000_000)
            self.text = "Refreshed"
        }
        .padding(.top, 16)
    }
}

struct ExampleScreen_Previews: PreviewProvider {
    static var previews: some View {
        ExampleScreen()
    }
}
