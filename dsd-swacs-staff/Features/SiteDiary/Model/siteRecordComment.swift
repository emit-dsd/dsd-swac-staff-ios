//
//  siteRecordComment.swift
//  dsd-swacs-staff
//
//  Created by Andy Lee on 30/10/2025.
//

struct SiteRecordComment: Identifiable, Codable {
    let id: Int
    let siteRecordId: Int
    let content: String
    let createdDate: String
    let createdBy: String
    let lastUpdatedDate: String
    let lastUpdatedBy: String
}

let mockSiteRecordComments: [SiteRecordComment] = [
    SiteRecordComment(
        id: 30001,
        siteRecordId: 1,
        content: "Completed inspection.",
        createdDate: "2025-08-22T15:00:00",
        createdBy: "SWACS ASL 1",
        lastUpdatedDate: "2025-08-22T15:30:00",
        lastUpdatedBy: "SWACS ASL 1"
    ),
    SiteRecordComment(
        id: 30002,
        siteRecordId: 1,
        content: "Plastering done. Waiting for materials.",
        createdDate: "2025-08-22T17:30:00",
        createdBy: "Sam Wong",
        lastUpdatedDate: "2025-08-22T18:00:00",
        lastUpdatedBy: "Sam Wong"
    ),
    SiteRecordComment(
        id: 30003,
        siteRecordId: 2,
        content: "Site access approved by supervisor.",
        createdDate: "2025-08-23T12:00:00",
        createdBy: "SWACS ASL 1",
        lastUpdatedDate: "2025-08-23T13:15:00",
        lastUpdatedBy: "SWACS ASL 1"
    )
]
