#!/bin/sh

swiftgen storyboards --templatePath "templates/storyboards.stencil" --sceneEnumName XAPStoryboard --segueEnumName XAPStoryboardSegue --output "../XAP/Definitions/Storyboard.swift" ../XAP/
