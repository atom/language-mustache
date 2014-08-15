describe 'Mustache grammar', ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage('language-mustache')

    runs ->
      grammar = atom.syntax.grammarForScopeName('text.html.mustache')

  it 'parses the grammar', ->
    expect(grammar).toBeTruthy()
    expect(grammar.scopeName).toBe 'text.html.mustache'
