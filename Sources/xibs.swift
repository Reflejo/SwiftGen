//
// SwiftGen
// Copyright (c) 2015 Olivier Halligon
// MIT Licence
//

import Commander
import PathKit
import StencilSwiftKit
import SwiftGenKit

let xibsCommand = command(
  outputOption, templateNameOption, templatePathOption, paramsOption,
  VariadicArgument<Path>("PATH",
                         description: "Directory to scan for .xib files. Can also be a path to a single .xib",
                         validator: pathsExist)
) { output, templateName, templatePath, parameters, paths in
  let parser = XIBParser()

  do {
    for path in paths {
      if path.extension == "xib" {
        try parser.addXIB(at: path)
      } else {
        try parser.parseDirectory(at: path)
      }
    }

    let templateRealPath = try findTemplate(
      subcommand: "xibs",
      templateShortName: templateName,
      templateFullPath: templatePath
    )
    let template = try StencilSwiftTemplate(templateString: templateRealPath.read(),
                                            environment: stencilSwiftEnvironment())
    let context = parser.stencilContext()
    let enriched = try StencilContext.enrich(context: context, parameters: parameters)
    let rendered = try template.render(enriched)
    output.write(content: rendered, onlyIfChanged: true)
  } catch {
    printError(string: "error: \(error.localizedDescription)")
  }
}
