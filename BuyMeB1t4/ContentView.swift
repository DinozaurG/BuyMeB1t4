//
//  ContentView.swift
//  BuyMeB1t4
//
//  Created by Алексей Шумейко on 06.10.2022.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showModal = false
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.name, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
        NavigationView {
            List {
                if items.count != 0 {
                    ForEach(items) { item in
                    label: do {
                        Text("\(item.name!), \(item.count), \(item.counttype!)")
                    }
                    }
                    .onDelete(perform: deleteItems)
                } else {
                    Text("Nothing to do here... Press Plus to add product to buy").multilineTextAlignment(.center)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: {
                        self.showModal = true
                    }) {
                        Label("Add Item", systemImage: "plus")
                    }.sheet(isPresented: $showModal) {
                        ModalView()
                    }
                }
            }
            Text("Select an item")
        }
    }


    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct OvalTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(15)
            .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
            .cornerRadius(10)
            .shadow(color: .gray, radius: 10)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

struct ModalView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @State private var name: String = ""
    @State private var count: String = ""
    @State private var counttype: String = ""
    var body: some View {
        VStack {
            VStack {
                Text("Введите данные о покупке")
                Divider()
                VStack {
                    TextField("Наименование", text: $name)
                    TextField("Количество", text: $count).keyboardType(.numbersAndPunctuation)
                    TextField("КГ, ШТ?", text: $counttype)
                }.foregroundColor(.black)
                .textFieldStyle(OvalTextFieldStyle())
                Divider()
                Button("Сохранить") {
                    let newItem = Item(context: viewContext)
                    newItem.name = name
                    newItem.count = Int64(count) ?? 1
                    newItem.counttype = counttype
                    do {
                        try viewContext.save()
                    } catch {
                        // Replace this implementation with code to handle the error appropriately.
                        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                        let nsError = error as NSError
                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                    }
                    self.presentationMode.wrappedValue.dismiss()
                }.padding(15)
                .background(LinearGradient(gradient: Gradient(colors: [Color.red, Color.yellow]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .cornerRadius(40)
            }.padding()
        }
    }
}
