// ----------------------------------------------------------------------------
//
//  AbstractValidatableModelConverter.swift
//
//  @author     Denis Kolyasev <KolyasevDA@ekassir.com>
//  @copyright  Copyright (c) 2016, eKassir Ltd. All rights reserved.
//  @link       http://www.ekassir.com/
//
// ----------------------------------------------------------------------------

import Foundation
import NetworkingApi
import SwiftCommons
import SwiftyJSON

// ----------------------------------------------------------------------------

open class AbstractValidatableModelConverter<T: ValidatableModel>: AbstractCallResultConverter<T>
{
// MARK: - Construction

    public override init() {
        super.init()
    }

// MARK: - Functions

    open override func convert(_ entity: ResponseEntity<Ti>) throws -> ResponseEntity<To>
    {
        var newEntity: ResponseEntity<To>
        var newBody: T?

        if let body = entity.body, body.isNotEmpty
        {
            // Try to parse response as JSON string
            let json: JSON
            do {
                json = try JSON(data: body, options: .allowFragments)
            }
            catch {
                throw ConversionError(entity: entity, cause: error)
            }

            do {
                if let json = (json.object as? JsonObject) {
                    newBody = try T.init(JSON: json)
                }
                else {
                    throw JsonSyntaxError(message: "Could not transform model.")
                }
            }
            catch let error as JsonSyntaxError {
                throw ConversionError(entity: entity, cause: error)
            }

        }

        newEntity = BasicResponseEntityBuilder(entity: entity, body: newBody).build()
        return newEntity
    }

}

// ----------------------------------------------------------------------------
