//
//  Fluent+Mustache.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 27/12/2024.
//
import FluentKit
import Mustache

/// Extend @propertyWrapper FieldProperty to enable mustache transform functions and add one
/// to access the wrappedValue. In the mustache template you would access this with
/// `{{wrappedValue(_myProperty)}}`. Note the `_` prefix on the property name. This is
/// required as this is how property wrappers appear in the Mirror reflection data.
public extension FieldProperty {
    func transform(_ name: String) -> Any? {
        switch name {
        case "wrappedValue":
            return wrappedValue
        default:
            return nil
        }
    }
}

/// Extend @propertyWrapper IDProperty to enable mustache transform functions and add one
/// to access the wrappedValue. In the mustache template you would access this with
/// `{{wrappedValue(_myID)}}`. Note the `_` prefix on the property name. This is
/// required as this is how property wrappers appear in the Mirror reflection data.
public extension IDProperty {
    func transform(_ name: String) -> Any? {
        switch name {
        case "wrappedValue":
            return wrappedValue
        default:
            return nil
        }
    }
}

#if hasFeature(RetroactiveAttribute)
    extension FieldProperty: @retroactive MustacheTransformable {}
    extension IDProperty: @retroactive MustacheTransformable {}
#else
    extension FieldProperty: MustacheTransformable {}
    extension IDProperty: MustacheTransformable {}
#endif
