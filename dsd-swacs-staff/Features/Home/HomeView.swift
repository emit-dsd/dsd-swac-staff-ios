import SwiftUI
import Localize_Swift

struct HomeView: View {
    @EnvironmentObject var languageManager: AppLanguageManager
    @EnvironmentObject var tabStore: TabNavigationStore
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var notificationManager: NotificationManager
    
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedID: String? = nil
    
    @State private var activeBottomSheet: ActiveBottomSheet = .none
    @State private var sheetContentHeight: CGFloat = 300
    @State private var isPaused = false
    
    enum ActiveBottomSheet {
        case none
        case signInOut
        case siteDiary
        case safetyInspection
    }
    
    private let cardWidth: CGFloat = 361
    private let cardSpacing: CGFloat = 8

    // MARK: - button Action
    func notificationMain() {
        tabStore.appendToCurrentPath(Screen.notificationMain)
    }
    
    func showErrorPopup(title:String = "scan_qr_code_failed_alertTitle_msg".localized() ,
                        msg: String = "scan_qr_code_failed_alertMessage_msg".localized()) {
        alertManager.show(
            title: title ,
            message: msg ,
            image: "icon-alert-fail",
            buttons: [
                CommonButtonModel(
                    title: "general_retry".localized(),
                    style: .contained,
                    enabled: true,
                    maxWidth: .infinity,
                    action: {
                        isPaused = false
                    }
                ),
                CommonButtonModel(
                    title: "general_back".localized(),
                    style: .outlined,
                    enabled: true,
                    maxWidth: .infinity,
                    action: {
                        tabStore.popLastOnCurrentPath()
                    }
                )
            ]
        )
    }
    
    func signInOut() {
        print("Scan QR Code pressed")
        activeBottomSheet = .signInOut
    }
    
    func signIn() {
        print("Sign In pressed")
    
        activeBottomSheet = .none
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            tabStore.appendToCurrentPath(
                Screen.scan(.signIn, false, $isPaused, onComplete: { code in
                    print("回到 HomeView 收到掃描結果: \(code)")
                    isPaused = true
                    Task {
                        isPaused = true
                        let response = await viewModel.signIn(accessCode: code)
                        switch response {
                        case .success(let response):
                            goToSignInOutResult(staffSignInOutResponse: response, scanMode: .signIn)
                        case .failure(let error):
                            showErrorPopup(title: error.userTitle, msg: error.userMessage)
                        }
                    }
                }, onFail: {
                    //                showErrorPopup()
                })
            )
        }
    }
    
    func signOut() {
        print("Sign Out pressed")
        activeBottomSheet = .none
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            tabStore.appendToCurrentPath(
                Screen.scan(.signOut, false, $isPaused, onComplete: { code in
                    print("回到 HomeView 收到掃描結果: \(code)")
                    isPaused = true
                    Task {
                        let response = await viewModel.signOut(accessCode: code)
                        switch response {
                        case .success(let response):
                            goToSignInOutResult(staffSignInOutResponse: response, scanMode: .signOut)
                        case .failure(let error):
                            showErrorPopup(title: error.userTitle, msg: error.userMessage)
                        }
                    }
                }, onFail: {
                    //                showErrorPopup()
                })
            )
        }
    }
    
    func newSiteDiary() {
        print("New Site Diary pressed")
        activeBottomSheet = .siteDiary
    }
    
    func safetyInspection() {
        print("Safety Inspection pressed")
        activeBottomSheet = .safetyInspection
    }
    
    func briefIncidentReport() {
        tabStore.appendToCurrentPath(Screen.IncidentReportList)
        print("Brief Incident Report pressed")
    }
    
    func qrCodeCheck() {
        print("Brief Incident Report pressed")
        tabStore.appendToCurrentPath(
            Screen.scan(.verify, false, $isPaused, onComplete: { code in
                print("回到 HomeView 收到掃描結果: \(code)")
                isPaused = true
                Task {
                    let response = await viewModel.inspectAccessCode(accessCode: code)
                    switch response {
                    case .success(let successResponse):
                        goToScreenResult(result: .success(successResponse))
                    case .failure(let failure):
                        goToScreenResult(result: .failure(failure))
                    }
                }
            }, onFail: {})
        )
    }
    
    func startWork(title: String){
        alertManager.show(
            title: "start_work_alertTitle_msg".localized() + "\n" + title,
            message: "start_work_alertMessage_msg".localized(),
            buttons: [
                CommonButtonModel(
                    title: "today_swac_button_start_work".localized(),
                    style: .contained,
                    enabled: true,
                    maxWidth: .infinity,
                    textColor: .white,
                    backgroundColor: .red,
                    action: {
                        //TODO Start Work API
                    }
                ),
                CommonButtonModel(
                    title: "general_cancel".localized(),
                    style: .outlined,
                    enabled: true,
                    maxWidth: .infinity,
                    action: {
                        
                    }
                )
            ]
        )
    }
    
    // MARK: - Route to View
    func goToSignInOutResult(staffSignInOutResponse:StaffSignInOutResponse, scanMode: ScanMode) {
        tabStore.appendToCurrentPath(Screen.signInOutResult(staffSignInOutResponse, scanMode))
    }
    
    func goToScreenResult(result: Result<InspectAccessCodeResponse, APIError>) {
        switch result {
        case .success(let response):
            tabStore.appendToCurrentPath(Screen.scanResult(response, nil, true))
        case .failure(let error):
            tabStore.appendToCurrentPath(Screen.scanResult(nil, error.userMessage, false))
        }
    }

    
    // MARK: - View
    var QuickActionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("quick_action_label_title".localized())
                    .appFont(.robotoBold, size: 18)
                    .foregroundColor(.Neutral800)
                Spacer()
            }
            
            QuickActionView(actions: [
                (imageName: "quick-action-scan-qrcode",
                 caption: "quick_action_button_scan_qr_code", action: signInOut),
                (imageName: "quick-action-new-site-diary",
                 caption: "quick_action_button_new_site_diary", action: newSiteDiary),
                (imageName: "quick-action-safety-inspection",
                 caption: "quick_action_button_safety_inspection", action: safetyInspection),
                (imageName: "quick-action-incident-report",
                 caption: "quick_action_button_brief_incident_report", action: briefIncidentReport),
                (imageName: "quick-action-qrcode-check",
                 caption: "quick_action_button_scan_qr_code_check", action: qrCodeCheck),
            ])
        }
        .padding(.horizontal, 16)
    }
    
    var SWACSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("today_swac_sectionTitle_main".localized())
                    .appFont(.robotoBold, size: 18)
                    .foregroundColor(.Neutral800)
            }
            .padding(.horizontal, 16)
            
            LazyVStack(spacing: 8) {
                if viewModel.isLoading && viewModel.todaySWACList.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                } else if viewModel.todaySWACList.isEmpty {
                    VStack(spacing: 12) {
                        Text("general_no_results".localized())
                            .appFont(.robotoBold, size: 16)
                            .foregroundColor(.Neutral500)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                } else {
                    ForEach(viewModel.todaySWACList, id: \.uniqueID) { swac in
                        HomeSWACCard(
                            swac: swac,
                            showActionButton: false,
                            onActionButtonTapped: { swac in
                                NSLog("onActionButtonTapped")
                                startWork(title: swac.contractTitle)
                            }
                        )
                        .padding(.horizontal, 16)
                        .onTapGesture {
                            tabStore.appendToCurrentPath(Screen.swacDetail(swac.number))
                        }
                        .onAppear {
                            // ✅ Pagination 邏輯保持不變，LazyVStack 會正確觸發
                            if swac.id == viewModel.todaySWACList.last?.id {
                                Task {
                                    await viewModel.loadMoreItems()
                                }
                            }
                        }
                    }
                    
                    if viewModel.isLoadingMore {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    
                    if !viewModel.hasMorePages && !viewModel.todaySWACList.isEmpty && !viewModel.isLoadingMore {
                        Text("general_no_more_data".localized())
                            .appFont(.robotoRegular, size: 14)
                            .foregroundColor(.Neutral500)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                }
            }
        }
    }
    
    // MARK: - Bottom Sheet View
    var currentDetents: Set<PresentationDetent> {
        switch activeBottomSheet {
        case .signInOut:
            return [.height(248)]
        case .siteDiary, .safetyInspection:
            return [.height(sheetContentHeight)]
        default:
            return []
        }
    }
    
    
    // MARK: - body
    var body: some View {
        VStack(spacing: 0){
            CustomNavBarView(
                type: .home,
                onNotificationTapped: notificationMain
            )
            
            ZStack(alignment: .top) {
                ScrollView {
                    VStack(spacing: 24) {
                        QuickActionSection
                        SWACSection
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 72)
                }
                .scrollIndicators(.hidden)
                .refreshable {
                    await viewModel.refreshList()
                }
                .background(Color.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
        .commonBottomSheet(isPresented: Binding<Bool>(
            get: { activeBottomSheet != .none },
            set: { isPresented in
                if !isPresented {
                    activeBottomSheet = .none
                    selectedID = nil
                }
            }
        ), detents: currentDetents) {
            switch activeBottomSheet {
            case .signInOut:
                SignInOutBottomSheetView(
                    isPresented: Binding(
                        get: { activeBottomSheet != .none },
                        set: { isPresented in
                            if !isPresented { activeBottomSheet = .none }
                        })
                    , onSignIn: { signIn() }
                    , onSignOut: { signOut() }
                )
            case .siteDiary:
                if viewModel.isLoading{
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                    }
                    .frame(height: 200)
                } else {
                    HomeSelectSWACBottomSheetView(
                        selectedID: $selectedID,
                        usageType: .siteDiary
                    ) { selectedSWAC in
                        guard let swac = selectedSWAC else { return }
                        tabStore.appendToCurrentPath(Screen.SiteDiaryNewEntry(swac.number))
                        activeBottomSheet = .none
                    }
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .onAppear {
                                    sheetContentHeight = geo.size.height
                                }
                                .onChange(of: geo.size.height, initial: true) { oldValue, newValue in
                                    sheetContentHeight = newValue
                                }
                        }
                    )
                }
            case .safetyInspection:
                if viewModel.isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                    }
                    .frame(height: 200)
                } else {
                    HomeSelectSWACBottomSheetView(
                        selectedID: $selectedID,
                        usageType: .safetyInspection
                    ) { selectedSWAC in
                        guard let swac = selectedSWAC else { return }
                        tabStore.appendToCurrentPath(Screen.SafetyInspectionNewEntry(swac.number,.partA))
                        activeBottomSheet = .none
                    }
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .onAppear {
                                    sheetContentHeight = geo.size.height
                                }
                                .onChange(of: geo.size.height, initial: true) { oldValue, newValue in
                                    sheetContentHeight = newValue
                                }
                        }
                    )
                }
                
            default:
                EmptyView()
            }
        }
        .task {
            guard tabStore.tabSelection == .home, viewModel.todaySWACList.isEmpty else { return }
            await viewModel.fetchSWACList(reset: true)
            await notificationManager.fetchUnreadCount()
        }
        .background(Color.white)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            HomeView()
                .environmentObject(TabNavigationStore())
            
        }
    }
}
