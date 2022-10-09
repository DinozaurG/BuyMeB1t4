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
    private var categories = ["Food", "Home chemistry", "Other"]
    var body: some View {
        if items.count != 0 {
            NavigationView {
                List {
                    ForEach(0..<3) { i in
                        Section(header: Text(categories[i]).italic()) {
                            ForEach(items) { item in
                                if (categories[i] == item.category) {
                                label: do {
                                    HStack() {
                                        Text("\(item.name!), \(item.count) \(item.counttype!)")
                                        Spacer()
                                        Button(action: {
                                            item.complete = !item.complete
                                        }) {
                                            Image(systemName: item.complete ? "checkmark.square" : "square")
                                        }
                                    }
                                }
                                }
                            }.onDelete(perform: deleteItems)
                                .swipeActions(edge: .leading) {
                                    Button {
                                        changeItem()
                                    } label: {
                                        Label("Change", systemImage: "rectangle.and.pencil.and.ellipsis")
                                    }
                                    .tint(.orange)
                                }
                        }
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
                //Text("Select an item")
            }
        } else {
            Spacer()
            Image("placeholder")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(50)
            Divider()
            Text("Nothing to do here... Press button at bottom to add product to buy").multilineTextAlignment(.center)
                .padding(.horizontal, 25)
            Divider()
            Spacer()
            Button(action: {
                self.showModal = true
            }) {
                Label("Add Product", systemImage: "plus")
            }.sheet(isPresented: $showModal) {
                ModalView()
            }.padding(30)
                .background(LinearGradient(gradient: Gradient(colors: [Color.red, Color.yellow]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .cornerRadius(40)
                .foregroundColor(.black)
            Spacer()
        }
    }
    
    private func changeItem() {
        print("Pressed")
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

struct DataTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(15)
            .background(LinearGradient(gradient: Gradient(colors: [Color.red, Color.orange]), startPoint: .topLeading, endPoint: .bottomTrailing))
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
    @State private var category: String = ""
    
    enum Category: String, CaseIterable, Identifiable {
        case food, hc, other
        var id: Self { self }
    }

    enum CountType: String, CaseIterable, Identifiable {
        case Shtuk, Kg, g, L
        var id: Self { self }
    }
    @State private var selectedCountType: CountType = .Shtuk
    @State private var selectedCategory: Category = .food
    var body: some View {
        VStack {
            VStack {
                Spacer()
                Spacer()
                Text("Write product data")
                Divider()
                VStack {
                    Picker("Category", selection: $selectedCategory) {
                        Text("Food").tag(ModalView.Category.food)
                        Text("Home chemistry").tag(ModalView.Category.hc)
                        Text("Other").tag(ModalView.Category.other)
                    }.pickerStyle(SegmentedPickerStyle())
                    TextField("Name", text: $name)
                    HStack() {
                        TextField("Count", text: $count).keyboardType(.numbersAndPunctuation)
                        Picker("CountType", selection: $selectedCountType) {
                            Text("Pieces").tag(ModalView.CountType.Shtuk)
                            Text("Kilograms").tag(ModalView.CountType.Kg)
                            Text("Grams").tag(ModalView.CountType.g)
                            Text("Liters").tag(ModalView.CountType.L)
                        }
                    }
                }.foregroundColor(.black)
                .textFieldStyle(DataTextFieldStyle())
                Divider()
                Spacer()
                Button("Save           ") {
                    let newItem = Item(context: viewContext)
                    newItem.name = name
                    newItem.count = Int64(count) ?? 1
                    switch selectedCountType {
                    case .Kg:
                        counttype = "Kg."
                    case .g:
                        counttype = "g."
                    case .L:
                        counttype = "L."
                    default:
                        counttype = "Pieces."
                    }
                    newItem.counttype = counttype
                    switch selectedCategory{
                    case .hc:
                        category = "Home chemistry"
                    case .other:
                        category = "Other"
                    default:
                        category = "Food"
                    }
                    newItem.category = category
                    newItem.complete = false
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
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                Spacer()
            }.padding()
        }
    }
}
