//
//  APIResponse.swift
//  dsd-swacs-staff
//
//  Created by Andy on 12/8/2025.
//

struct APIResponse<DataType: Decodable>: Decodable {
    let data: DataType
    // TODO: code / message
    // let code: Int
    // let message: String
}
