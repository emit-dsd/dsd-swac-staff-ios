//
//  CustomNavBarView.swift
//
//
//  Created by User on 18/7/2025.
//

import SwiftUI

enum NavBarType: Equatable {
    case none
    case normal     // notification
    case home
    case backOnly   // back
    case backWithAction
    case filterDate
    case searchBar
    case searchBarWithnotification
    case searchBarWithFilter
    case searchBarWithFilterDate
}

struct CustomNavBarView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var tabStore: TabNavigationStore
    @EnvironmentObject var notificationManager: NotificationManager
    @ObservedObject var userSession = UserSession.shared
    
    @Binding var searchText: String
    
    @State private var notificationCount: Int = 3
    
    let type: NavBarType
    let title: String?
    let searchPlaceholder: String?
    let actionIconName: String?
    
    var onBackTapped: (() -> Void)? = nil
    var onSearchTapped: (() -> Void)? = nil
    var onFilterTapped: (() -> Void)? = nil
    var onNotificationTapped: (() -> Void)? = nil
    var onActionTapped: (() -> Void)? = nil
    
    
    init(
        type: NavBarType,
        title: String? = nil,
        searchPlaceholder: String? = nil,
        actionIconName: String? = "",
        searchText: Binding<String> = .constant(""),
        onBackTapped: (() -> Void)? = nil,
        onSearchTapped: (() -> Void)? = nil,
        onFilterTapped: (() -> Void)? = nil,
        onNotificationTapped: (() -> Void)? = nil,
        onActionTapped: (() -> Void)? = nil
    ) {
        self.type = type
        self.title = title
        self.searchPlaceholder = searchPlaceholder
        self.actionIconName = actionIconName
        self._searchText = searchText
        self.onBackTapped = onBackTapped
        self.onSearchTapped = onSearchTapped
        self.onFilterTapped = onFilterTapped
        self.onNotificationTapped = onNotificationTapped
        self.onActionTapped = onActionTapped
    }
    
    var body: some View {
        ZStack{
            HStack {
                switch type {
                case .none:
                    noneBar
                case .normal:
                    normalBar
                case .home:
                    homeBar
                case .filterDate:
                    filterDateBar
                case .searchBar:
                    searchBarNav
                case .searchBarWithnotification:
                    searchBarNavWithnotification
                case .searchBarWithFilter:
                    searchBarNavWithFilter
                case .searchBarWithFilterDate:
                    searchBarWithFilterDate
                case .backOnly:
                    backOnlyBar
                case .backWithAction: 
                    backWithActionBar
                }
            }
            .padding(.top, 0).background(.clear)
        }
        .frame(maxWidth: .infinity,minHeight: 44, maxHeight: 44, alignment: .leading)
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .foregroundColor(Color.Primary700)
        .font(.headline)
        .background(
            Image("header-background")
                .resizable()
                .frame(height: (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 44) + 60)
                .clipped()
                .ignoresSafeArea(edges: .top)
        )
    }
}

struct CustomNavBarView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView{
            VStack(spacing: 80) {
                CustomNavBarView(type: .normal, title: "TItle here")  .environmentObject(TabNavigationStore())
                
                CustomNavBarView(type: .backOnly, title: "TItle here")  .environmentObject(TabNavigationStore())
                
                CustomNavBarView(type: .filterDate, title: "TItle here")  .environmentObject(TabNavigationStore())
                
                CustomNavBarView(type: .searchBar, title: "TItle here")  .environmentObject(TabNavigationStore())
                
                CustomNavBarView(type: .searchBarWithnotification, title: "TItle here")  .environmentObject(TabNavigationStore())
                
                CustomNavBarView(type: .searchBarWithFilter, title: "TItle here")  .environmentObject(TabNavigationStore())
                
                CustomNavBarView(type: .searchBarWithFilterDate, title: "TItle here")  .environmentObject(TabNavigationStore())
                
                CustomNavBarView(type: .none, title: "TItle here")  .environmentObject(TabNavigationStore())
                
            }
        }
    }
}

extension CustomNavBarView {
    
    private var noneBar: some View {
        ZStack {
            HStack(spacing: 16){
                titleSection
            }
        }
    }
    
    private var normalBar: some View {
        ZStack {
            //            titleSection
            HStack(spacing: 16){
//                if !tabStore.getCurrentPath().isEmpty{
//                    backButton
//                }
                Spacer()
                notificationButton
            }
        }
    }
    
    private var backOnlyBar: some View {
        ZStack {
            HStack(spacing: 16){
                backButton
                titleSection
            }
        }
    }
    
    private var backWithActionBar: some View {
        ZStack {
            HStack(spacing: 16) {
                backButton
                titleSection
//                Spacer()
                actionButton
            }
        }
    }
    
    private var homeBar: some View {
        ZStack {
            HStack(alignment: .center) {
                HStack(alignment: .center, spacing: 8) {
                    HStack(alignment: .center, spacing: 0) {
                        Image("icon-home-dsd-logo")
                    }
                    .frame(width: 40, height: 40, alignment: .center)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("home_label_welecome_back".localized())
                            .appFont(.robotoRegular, size: 14)
                            .foregroundColor(Color.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        if let user = userSession.profile {
                            Text(user.nameEng)
                                .appFont(.robotoBold, size: 16)
                                .foregroundColor(Color.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(0)
                }
                .padding(0)
                .frame(maxWidth: .infinity, alignment: .leading)
               
                Spacer()
                notificationButton
            }
        }
    }
    
    private var filterDateBar: some View {
        ZStack {
            HStack(spacing: 16){
                if !tabStore.getCurrentPath().isEmpty{
                    backButton
                }
                titleSection
                Spacer()
                filterDateButton
            }
        }
    }
    
    private var searchBarNav: some View {
        ZStack {
            HStack(spacing: 16){
                if !tabStore.getCurrentPath().isEmpty{
                    backButton
                }
                SearchBarView(searchText: $searchText, placeholder: searchPlaceholder ?? "")
                searchButton
            }
        }
    }
    
    private var searchBarNavWithnotification: some View {
        ZStack {
            HStack(spacing: 16){
                if !tabStore.getCurrentPath().isEmpty{
                    backButton
                }
                SearchBarView(searchText: $searchText, placeholder: searchPlaceholder ?? "")
                notificationButton
            }
        }
    }
    
    private var searchBarNavWithFilter: some View {
        ZStack {
            HStack(spacing: 16){
                if !tabStore.getCurrentPath().isEmpty{
                    backButton
                }
                SearchBarView(searchText: $searchText, placeholder: searchPlaceholder ?? "")
                filterButton
            }
        }
    }
    
    private var searchBarWithFilterDate: some View {
        ZStack {
            HStack(spacing: 16){
                if !tabStore.getCurrentPath().isEmpty{
                    backButton
                }
                SearchBarView(searchText: $searchText, placeholder: searchPlaceholder ?? "")
                filterDateButton
            }
        }
    }
    
    private var backButton: some View {
        Button(action: {
            if let onBackTapped = onBackTapped {
                onBackTapped()
            }else{
                presentationMode.wrappedValue.dismiss()
            }
        }, label: {
            Image("back-button")
        })
        .frame(width: 36, height: 36, alignment: .center)
    }
    
    private var actionButton: some View {
        Button(action: {
            if let onActionTapped = onActionTapped {
                onActionTapped()
            }
        }, label: {
            Image(actionIconName ?? "")
        })
        .frame(width: 36, height: 36, alignment: .center)
    }
    
    private var searchButton: some View {
        Button(action: {
            if let onSearchTapped = onSearchTapped {
                onSearchTapped()
            }
        }, label: {
            Image("search-icon")
        })
        .frame(width: 36, height: 36, alignment: .center)
    }
    
    private var filterButton: some View {
        Button(action: {
            if let onFilterTapped = onFilterTapped {
                onFilterTapped()
            }
        }, label: {
            Image("filter-icon")
        })
        .frame(width: 36, height: 36, alignment: .center)
    }

    private var filterDateButton: some View {
        Button(action: {
            if let onFilterTapped = onFilterTapped {
                onFilterTapped()
            }
        }, label: {
            Image("calendar-icon")
        })
        .frame(width: 36, height: 36, alignment: .center)
    }
    
    private var notificationButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            NotificationButton(action: {
                if let onNotificationTapped = onNotificationTapped {
                    onNotificationTapped()
                }
            }, badgeCount: notificationManager.unreadCount)
        })
        .frame(width: 36, height: 36, alignment: .center)
    }
    
    private var titleSection: some View {
        VStack(spacing: 4) {
            if let title = title {
                Text(title)
                    .appFont(.robotoBold, size: 18)
                    .foregroundColor(Color.white)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(0)
            }
        }
    }
}
