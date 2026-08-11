//
//  WeatherSelector.swift
//  dsd-swacs-staff
//
//  Created by Andy Lee on 29/10/2025.
//
import SwiftUI

enum WeatherSelectorStatus: Int, CaseIterable {
    case fine = 0
    case cloudy = 1
    case rainy = 2
    case thunder = 3
    
    var title: String {
          switch self {
          case .fine: return "site_diary_detail_label_weather_fine".localized()
          case .cloudy: return "site_diary_detail_label_weather_cloudy".localized()
          case .rainy: return "site_diary_detail_label_weather_rainy".localized()
          case .thunder: return "site_diary_detail_label_weather_thunder".localized()
          }
    }
    
    var icon: String {
          switch self {
          case .fine: return "icon-weather-sun"
          case .cloudy: return "icon-weather-cloud"
          case .rainy: return "icon-weather-rainy"
          case .thunder: return "icon-weather-thunder"
          }
    }
    
    var selectedIcon: String {
          switch self {
          case .fine: return "icon-weather-sun-selected"
          case .cloudy: return "icon-weather-cloud-selected"
          case .rainy: return "icon-weather-rainy-selected"
          case .thunder: return "icon-weather-thunder-selected"
          }
    }
    
    var color: Color {
          switch self {
          case .fine: return Color(hex: "FF9D00")
          case .cloudy: return Color.Neutral500
          case .rainy: return Color.Primary600
          case .thunder: return Color.yellow
          }
    }
    
    var apiValue: Int {
          switch self {
          case .fine: return 1
          case .cloudy: return 2
          case .rainy: return 3
          case .thunder: return 4
          }
      }
}

struct WeatherSelector: View {
    @Binding var selectedWeatherAM: WeatherSelectorStatus?
    @Binding var selectedWeatherPM: WeatherSelectorStatus?

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                Text("site_diary_detail_label_weather_status".localized())
                    .appFont(.robotoRegular, size: 14)
                    .foregroundColor(Color.Primary800)
                
                Text("*")
                    .appFont(.robotoRegular, size: 14)
                    .foregroundColor(.red)
                
                Text("site_diary_detail_label_at_least_either_one".localized())
                    .appFont(.robotoRegular, size: 14)
                    .foregroundColor(.red)
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("site_diary_detail_label_am".localized())
                    .appFont(.robotoRegular, size: 14)
                    .foregroundColor(Color.Primary800)
                HStack(alignment: .center, spacing: 12) {
                    ForEach(WeatherSelectorStatus.allCases, id: \.self) { weather in
                        WeatherButton(
                            weather: weather,
                            isSelected: selectedWeatherAM == weather,
                            action: {
                                withAnimation {
                                    if selectedWeatherAM == weather {
                                        selectedWeatherAM = nil
                                    } else {
                                        selectedWeatherAM = weather
                                    }
                                }
                            }
                        )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("site_diary_detail_label_pm".localized())
                    .appFont(.robotoRegular, size: 14)
                    .foregroundColor(Color.Primary800)
                HStack(alignment: .center, spacing: 12) {
                    ForEach(WeatherSelectorStatus.allCases, id: \.self) { weather in
                        WeatherButton(
                            weather: weather,
                            isSelected: selectedWeatherPM == weather,
                            action: {
                                withAnimation {
                                    if selectedWeatherPM == weather {
                                        selectedWeatherPM = nil
                                    } else {
                                        selectedWeatherPM = weather
                                    }
                                }
                            }
                        )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

// MARK: - Weather Button Component
struct WeatherButton: View {
    let weather: WeatherSelectorStatus
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .center, spacing: 4) {
                Image(isSelected ? weather.selectedIcon : weather.icon)
                    .renderingMode(.template)
                    .foregroundColor(weather.color)
                    .frame(width: 24, height: 24)
                
                Text(weather.title)
                    .appFont(.robotoBold, size: 18)
                    .foregroundColor(weather.color)
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, minHeight: 74, maxHeight: 74, alignment: .center)
            .background(isSelected ? Color(hex: "F0F5FF") : Color.Neutral100)
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .inset(by: 1)
                    .stroke(isSelected ? Color.Primary500 : Color.Neutral300, lineWidth: 2)
            )
        }
    }
}

// MARK: - Preview
#if DEBUG
struct WeatherSelector_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var selectedWeatherAM: WeatherSelectorStatus? = nil
        @State private var selectedWeatherPM: WeatherSelectorStatus? = nil

        var body: some View {
            WeatherSelector(selectedWeatherAM: $selectedWeatherAM, selectedWeatherPM: $selectedWeatherPM)
        }
    }
    static var previews: some View {
        PreviewWrapper()
    }
}
#endif
