//
//  ContactRecord.swift
//  Contactor
//
//  Created by Tyler Peterson on 4/19/18.
//
import Foundation
import Contacts

/// ContactRecord mutates CNContact instances into various output formats
public struct ContactRecord: IterableProperties {

	/// Identifier
	public var id: String! = ""

	/// Contact type (business vs individual)
	public var type: String! = ""

	/// Contact name prefix
	public var namePrefix: String! = ""

	/// Contact first name
	public var givenName: String! = ""

	/// Contact middle name
	public var middleName: String! = ""

	/// Contact last name
	public var familyName: String! = ""

	/// Maiden name
	public var previousFamilyName: String! = ""

	/// Suffix
	public var nameSuffix: String! = ""

	/// Nickname
	public var nickname: String! = ""

	/// Address
	public var postalAddress: String! = ""

	/// Company
	public var organization: String! = ""

	/// Department
	public var department: String! = ""

	/// Title
	public var jobTitle: String! = ""

	/// Birthday
	public var birthday: String! = ""

	/// Notes
	public var notes: String! = ""

	/// Pic image data
	public var imageData: Data?

	/// Pic thumbnail image data
	public var thumbnailImageData: Data?

	/// Pic data available
	public var hasImageData: Bool! = false

	/// Collection of phone numbers
	public var phoneNumbers: String! = ""

	/// Collection of email addresses
	public var emailAddresses: String! = ""

	/// Collection of URLs
	public var urlAddresses: String! = ""

	/// Collection of social profiles
	public var socialProfiles: String! = ""

	/// Collection of IM addresses
	public var instantMessageAddresses: String! = ""

	/// Base constructor for static prop retrieval
	public init() {
	}

	/// Instantiate instance by passing CNContact instance
	///
	/// - Parameter contactInstance: CNContact instance
	public init(contactInstance: CNContact) {
		self.id = contactInstance.identifier
		self.type = contactInstance.contactType.rawValue == 1 ? "Business" : "Individual"
		self.namePrefix = contactInstance.namePrefix
		self.givenName = contactInstance.givenName
		self.middleName = contactInstance.middleName
		self.familyName = contactInstance.familyName
		self.previousFamilyName = contactInstance.previousFamilyName
		self.nameSuffix = contactInstance.nameSuffix
		self.nickname = contactInstance.nickname

		self.postalAddress = ""

		for row in contactInstance.postalAddresses {
			if row.value.street.count > 0 && row.value.city.count > 0 && row.value.state.count > 0 && row.value.postalCode.count > 0 {
				self.postalAddress = "\n\(row.value.street)\n\(row.value.city), \(row.value.state) \(row.value.postalCode) \(row.value.country)"
			}
		}

		self.organization = contactInstance.organizationName
		self.department = contactInstance.departmentName
		self.jobTitle = contactInstance.jobTitle

		if (contactInstance.birthday != nil) {
			let f = DateFormatter()
			f.dateFormat = "MMMM d"
			self.birthday = f.string(from: (contactInstance.birthday?.date!)!)
		}

		self.notes = contactInstance.note
		self.hasImageData = contactInstance.imageDataAvailable

		if self.hasImageData {
			self.imageData = contactInstance.imageData
			self.thumbnailImageData = contactInstance.thumbnailImageData
		}

		var phoneNumbers: [String] = []
		var emailAddresses: [String] = []
		var urlAddresses: [String] = []
		var socialProfiles: [String] = []
		var instantMessageAddresses: [String] = []

		for num in contactInstance.phoneNumbers {
			phoneNumbers.append("\(num.label?.description ?? ""): \(num.value.stringValue)")
		}

		for num in contactInstance.emailAddresses {
			emailAddresses.append("\(num.label?.description ?? ""): \(num.value)")
		}

		for num in contactInstance.urlAddresses {
			urlAddresses.append("\(num.label?.description ?? ""): \(num.value)")
		}

		for num in contactInstance.socialProfiles {
			socialProfiles.append("\(num.label?.description ?? ""): \(num.value)")
		}

		for num in contactInstance.instantMessageAddresses {
			instantMessageAddresses.append("\(num.value.username)")
		}

		self.phoneNumbers = phoneNumbers.joined(separator: "\n")
		self.emailAddresses = emailAddresses.joined(separator: "\n")
		self.urlAddresses = urlAddresses.joined(separator: "\n")
		self.socialProfiles = socialProfiles.joined(separator: "\n")
		self.instantMessageAddresses = instantMessageAddresses.joined(separator: "\n")
	}

	/// Converts a contact's properties to a string
	///
	/// - Returns: Properties as string
	public func contactToString() -> String {
		var output: String = ""

		do {
			let props = try self.allProperties()

			for prop in props {
				let outputValue = (prop.value as! String)
					.replacingOccurrences(of: "_$!<", with: "")
					.replacingOccurrences(of: ">!$_", with: "")

				output += prop.key
				output += ": "
				output += outputValue
				output += "\n"
				output = output.replacingOccurrences(of: "\n\n", with: "\n")
			}
		} catch _ {
		}

		return output
	}

	/// Returns instance properties as a CSV row
	///
	/// - Returns: String CSV row of properties
	public func contactToCSV() -> String {
		var row: [String] = []

		do {
			let props = try self.allProperties()

			for prop in props {
				let outputValue = (prop.value as! String)
					.replacingOccurrences(of: "_$!<", with: "")
					.replacingOccurrences(of: ">!$_", with: "")
					.trimmingCharacters(in: .whitespacesAndNewlines)

				row.append(outputValue)
			}
		} catch _ {
		}

		return "\"" + row.joined(separator: "\",\"") + "\""
	}

	/// Returns instance properties as a CSV row
	///
	/// - Returns: String CSV row of properties
	public func somePropertyContains(search: String) -> Bool {
		do {
			let props = try self.allProperties()

			for prop in props {
				if (prop.value as! String).range(of: search, options: .caseInsensitive) != nil {
					return true
				}
			}
		} catch _ {
		}

		return false
	}

	/// Returns property keys for use as a CSV header row
	///
	/// - Returns: String of properties as CSV header
	public static func CSVHeader() -> String {
		var row: [String] = []

		do {
			let props = try ContactRecord().allProperties()
			for prop in props {
				row.append(prop.key)
			}
		} catch _ {
		}

		return "\"" + row.joined(separator: "\",\"") + "\""
	}
}

// MARK: - Protocols

/// Retrieve all properties in a struct
protocol IterableProperties {
	/// Retrieve a dictionary of all properties
	///
	/// - Returns: Dictionary of properties/values
	/// - Throws: Error
	func allProperties() throws -> [String: Any]
}

// MARK: - Extensions

/// Extension to loop properties
extension IterableProperties {

	/// Retrieves a dict of all properties and values
	///
	/// - Returns: Dictionary of properties and their values
	/// - Throws: Error
	public func allProperties() throws -> [String: Any] {
		var result: [String: String] = [:]
		let mirror = Mirror(reflecting: self)

		guard let
			style = mirror.displayStyle,
			style == .struct ||
				style == .class else {
					throw NSError(domain: "hris.to", code: 777, userInfo: nil)
		}

		for (labelMaybe, valueMaybe) in mirror.children {
			guard let label = labelMaybe else {
				continue
			}

			if let val = valueMaybe as? NSString {
				result[label] = String.init(val)
			}
		}

		return result
	}
}
