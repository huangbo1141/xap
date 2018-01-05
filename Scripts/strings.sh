#!/bin/sh

swiftgen strings --templatePath "templates/strings.stencil" --enumName L10n --output "../JobinRecruiter/Definitions/Strings.swift" ../JobinRecruiter/en.lproj/Localizable.strings
