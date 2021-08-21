import Hooks
import SwiftUI

typealias TodoContext = Context<Binding<[String]>>

struct TodoPage: HookView {
    var hookBody: some View {
        let todos = useState(["Contribute to SwiftUI Hooks"])

        return NavigationView {
            ScrollView {
                TodoContext.Provider(value: todos) {
                    VStack {
                        todoInput
                        todoContent
                    }
                    .padding(.vertical, 16)
                }
                .navigationBarTitle("TODO")
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    var todoInput: some View {
        let todos = useContext(TodoContext.self)
        let text = useState("")

        return Row {
            TextField(
                "Enter new task",
                text: text,
                onCommit: {
                    guard !text.wrappedValue.isEmpty else { return }
                    todos.wrappedValue.append(text.wrappedValue)
                    text.wrappedValue = ""
                }
            )
            .accessibility(identifier: "input")
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(lineWidth: 1)
            )
        }
    }

    var todoContent: some View {
        let todos = useContext(TodoContext.self)

        return ForEach(0..<todos.wrappedValue.count, id: \.self) { offset in
            let todo = todos.wrappedValue[offset]

            Row {
                Text(todo)
                    .accessibility(identifier: "todo:" + todo)
                Spacer()
                Button(
                    action: { todos.wrappedValue.remove(at: offset) },
                    label: {
                        Image(systemName: "trash.fill")
                            .resizable()
                            .foregroundColor(.red)
                            .frame(width: 20, height: 20)
                    }
                )
                .accessibility(identifier: "delete:" + todo)
            }
        }
    }
}

private struct Row<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                content
            }
            .padding(.vertical, 16)

            Divider()
        }
        .padding(.horizontal, 24)
    }
}
