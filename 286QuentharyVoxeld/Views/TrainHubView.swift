import SwiftUI

struct TrainHubView: View {
    @State private var segment = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Train", selection: $segment) {
                    Text("Builder").tag(0)
                    Text("Stats").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 10)
                .onChange(of: segment) { _ in
                    HapticsService.light()
                }

                Group {
                    if segment == 0 {
                        WorkoutBuilderView()
                    } else {
                        PerformanceSnapshotView()
                    }
                }
            }
            .appScreenBackground()
            .navigationTitle("Train")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}
