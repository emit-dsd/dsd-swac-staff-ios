//
//  SiteDiaryDetailViewModel.swift
//  dsd-swacs-staff
//
//  Created by Andy on 7/11/2025.
//

import Foundation
import Combine
import UIKit

@MainActor
class SiteDiaryDetailViewModel: ObservableObject {
    @Published var swacDetail: SWACDetail?
    @Published var diary: SiteDiary?
    @Published var isLoading = false
    @Published var isRefreshing = false
    @Published var errorMessage: String?
    
    @Published var imageAssets: [ImageAsset] = []
    @Published var isLoadingAttachments = false
    
    let swacNumber: String
    let diaryId: Int
    
    init(swacNumber: String, diaryId: Int) {
        self.swacNumber = swacNumber
        self.diaryId = diaryId
    }
    
    /// init (SWAC + Diary Detail)
    func loadData() async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            // ✅ Fetch both SWAC detail and diary in parallel
            async let swacResponse = APIService.fetchSWACProfile(swacNumber: swacNumber)
            async let diaryResponse = APIService.getSiteDiaryDetail(id: diaryId)
            
            let (swac, diaryDetail) = try await (swacResponse, diaryResponse)
            
            self.swacDetail = SWACDetail(from: swac)
            self.diary = SiteDiary(from: diaryDetail)
            
            isLoading = false
            
            Task {
                await loadAttachments()
            }
            
        } catch {
            self.errorMessage = error.localizedDescription
            print("❌ loadData error:", error)
        }
    }
    
    /// loadAttachments
    func loadAttachments() async {
        guard let diary = self.diary, !diary.attachment.isEmpty else {
            self.imageAssets = []
            return
        }
        
        guard !isLoadingAttachments else { return }
        isLoadingAttachments = true
        defer { isLoadingAttachments = false }
        
        do {
            let items = try await APIService.getDocumentContentItems(attachmentIds: diary.attachment)
            
            // to ImageAsset
            self.imageAssets = items.compactMap { item in
                guard let data = item.data.fileData,
                      let uiImage = UIImage(data: data) else {
                    print("⚠️ 無法轉換附件為圖片: \(item.data.fileName)")
                    return nil
                }

                let caption = item.profile.remarks ?? ""

                return ImageAsset(image: uiImage, caption: caption)
            }
            
            print("✅ 成功載入 \(imageAssets.count) 個附件圖片")
            
        } catch {
            print("❌ 載入附件失敗:", error)
            self.errorMessage = error.localizedDescription
            self.imageAssets = []
        }
    }
    
    func refresh() async {
        isRefreshing = true
        defer { isRefreshing = false }
        await loadData()
    }
}
