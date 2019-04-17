import UIKit

enum Weather: String, CaseIterable, Codable {
    case cloudy = "☁️"
    case drizzling = "🌧"
    case raining = "☔️"
}

struct Forecast: Codable {
    let zipCode: Int
    let date: Date
    let description: Weather

    static func fetch() -> Forecast {
        sleep(5)
        let weather = Weather.allCases.randomElement() ?? Weather.cloudy
        let date = Date()
        let zipCode = 98121
        return Forecast(zipCode: zipCode, date: date, description: weather)
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var weatherEmoji: UILabel!
    @IBOutlet weak var forecastDateLabel: UILabel!
    @IBOutlet weak var forecastLocationLabel: UILabel!

    var lastKnownForecast: Forecast? {
        didSet {
            if let newForecast = lastKnownForecast {
                weatherEmoji.text = newForecast.description.rawValue
                forecastDateLabel.text = dateFormatter.string(from: newForecast.date)
                forecastLocationLabel.text = "\(newForecast.zipCode)"
            } else {
                weatherEmoji.text = "⁉️"
                forecastDateLabel.text = "...fetching..."
                forecastLocationLabel.text = " "
            }
        }
    }
    let dateFormatter: DateFormatter = DateFormatter()

    @IBAction func fetchForecast(_ sender: UIButton) {
        lastKnownForecast = Forecast.fetch()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        self.lastKnownForecast = nil
    }

    // MARK: - Codable
    private enum Keys: String {
        case forecast
    }

    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        guard let forecast = lastKnownForecast,
            let coder = coder as? NSKeyedArchiver else { return }
        try? coder.encodeEncodable(forecast, forKey: Keys.forecast.rawValue)
    }

    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        guard let coder = coder as? NSKeyedUnarchiver else { return }
        lastKnownForecast = coder.decodeDecodable(Forecast.self, forKey: Keys.forecast.rawValue)
    }

    // MARK: - NSCoding
//    private enum Keys: String {
//        case forecastZipCode
//        case forecastDate
//        case forecastDescription
//    }
//
//    override func encodeRestorableState(with coder: NSCoder) {
//        super.encodeRestorableState(with: coder)
//        guard let forecast = lastKnownForecast else { return }
//        coder.encode(forecast.zipCode, forKey: Keys.forecastZipCode.rawValue)
//        coder.encode(forecast.date, forKey: Keys.forecastDate.rawValue)
//        coder.encode(forecast.description, forKey: Keys.forecastDescription.rawValue)
//    }
//
//    override func decodeRestorableState(with coder: NSCoder) {
//        super.decodeRestorableState(with: coder)
//        let zipCode = coder.decodeInteger(forKey: Keys.forecastZipCode.rawValue)
//        guard zipCode > 0 else { return }
//        guard let objcDate = coder.decodeObject(of: NSDate.self, forKey: Keys.forecastDate.rawValue),
//            let date = objcDate as Date? else { return }
//        guard let objcWeather = coder.decodeObject(of: NSString.self, forKey: Keys.forecastDescription.rawValue),
//            let rawWeather = objcWeather as String?,
//            let description = Weather(rawValue: rawWeather) else { return }
//        lastKnownForecast = Forecast(zipCode: zipCode, date: date, description: description)
//    }
}

