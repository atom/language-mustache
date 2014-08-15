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

  it 'parses comments', ->
    {tokens} = grammar.tokenizeLine("{{!comment}}")

    expect(tokens[0]).toEqual value: '{{!', scopes: ['text.html.mustache', 'comment.block.mustache']
    expect(tokens[1]).toEqual value: 'comment', scopes: ['text.html.mustache', 'comment.block.mustache']
    expect(tokens[2]).toEqual value: '}}', scopes: ['text.html.mustache', 'comment.block.mustache']
