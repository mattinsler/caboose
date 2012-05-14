module.exports =
  javascript_include: (scripts...) ->
    (for s in scripts
      s = "/javascripts/#{s}" if !/^http/.test(s)
      s += '.js' if !/\.js$/.test(s)
      '<script type="text/javascript" src="' + s + '"></script>'
    ).join('\n')

  stylesheet_include: (sheets...) ->
    (for s in sheets
      s = "/stylesheets/#{s}" if !/^http/.test(s)
      s += '.css' if !/\.css$/.test(s)
      '<link href="' + s + '" rel="stylesheet">'
    ).join('\n')
